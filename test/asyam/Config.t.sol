// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {BaseTest} from "../BaseTest.sol";
import {Market, Offer, CollateralParams} from "../../src/interfaces/IMidnight.sol";
import {MidnightBundles} from "../../src/periphery/MidnightBundles.sol";
import {TickLib, MAX_TICK} from "../../src/libraries/TickLib.sol";
import {WAD} from "../../src/libraries/ConstantsLib.sol";

/// @notice Shared harness for asyam audit PoCs and invariants.
abstract contract Config is BaseTest {
    address internal constant ALICE = address(0xA11CE000000000000000000000000000000001);
    address internal constant BOB = address(0xB0B00000000000000000000000000000000001);
    address internal constant MAKER = address(0x0000000000000000000000000000000000000001);
    address internal constant TAKER = address(0x0000000000000000000000000000000000007001);
    address internal constant LIQUIDATOR_ACTOR = address(0x0000000000000000000000000000000000007002);
    address internal constant ATTACKER = address(0x000000000000000000000000000000000000a771);
    address internal constant RELAYER = address(0x000000000000000000000000000000000000E1A1);
    address internal constant REFERRAL = address(0x000000000000000000000000000000000000eEf1);

    MidnightBundles internal midnightBundles;

    Market internal market;
    bytes32 internal marketId;

    struct BalanceSnapshot {
        uint256 loanToken;
        uint256 collateral1;
        uint256 collateral2;
        uint256 midnightLoan;
        uint256 bundlerLoan;
    }

    function setUp() public virtual override {
        super.setUp();
        midnightBundles = new MidnightBundles(address(midnight));

        vm.label(ALICE, "ALICE");
        vm.label(BOB, "BOB");
        vm.label(MAKER, "MAKER");
        vm.label(TAKER, "TAKER");
        vm.label(borrower, "BORROWER");
        vm.label(lender, "LENDER");
        vm.label(LIQUIDATOR_ACTOR, "LIQUIDATOR");
        vm.label(ATTACKER, "ATTACKER");
        vm.label(RELAYER, "RELAYER");
        vm.label(REFERRAL, "REFERRAL");
        vm.label(address(midnightBundles), "MidnightBundles");

        market = _defaultMarket();
        marketId = _touchMarket(market);
        _fundLoanToken(lender, 1e30);
        _fundLoanToken(borrower, 1e30);
        _authorizeBundler(borrower);
        _authorizeBundler(lender);
    }

    function _defaultMarket() internal view returns (Market memory m) {
        CollateralParams[] memory collateralParams = new CollateralParams[](1);
        collateralParams[0] = CollateralParams({
            token: address(collateralToken1),
            lltv: 0.77e18,
            maxLif: maxLif(0.77e18, 0.25e18),
            oracle: address(oracle1)
        });
        m = Market({
            loanToken: address(loanToken),
            collateralParams: collateralParams,
            maturity: vm.getBlockTimestamp() + 100,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(0)
        });
    }

    function _touchMarket(Market memory m) internal returns (bytes32 id) {
        id = midnight.touchMarket(m);
        midnight.setMarketTickSpacing(id, 1);
    }

    function _fundLoanToken(address account, uint256 amount) internal {
        deal(address(loanToken), account, amount);
        vm.prank(account);
        loanToken.approve(address(midnight), type(uint256).max);
        vm.prank(account);
        loanToken.approve(address(midnightBundles), type(uint256).max);
    }

    function _warpBeforeMaturity(Market memory m) internal {
        vm.warp(m.maturity - 1 days);
    }

    function _warpAfterMaturity(Market memory m) internal {
        vm.warp(m.maturity + 1 days);
    }

    function _snapshotBalances(address account) internal view returns (BalanceSnapshot memory snap) {
        snap.loanToken = loanToken.balanceOf(account);
        snap.collateral1 = collateralToken1.balanceOf(account);
        snap.collateral2 = collateralToken2.balanceOf(account);
        snap.midnightLoan = loanToken.balanceOf(address(midnight));
        snap.bundlerLoan = loanToken.balanceOf(address(midnightBundles));
    }

    function _assertPositionHealthy(bytes32 id, Market memory m, address user) internal view {
        assertTrue(midnight.isHealthy(m, id, user), "position should be healthy");
    }

    function _assertConsumedCap(address maker, bytes32 group, uint256 maxCap) internal view {
        assertLe(midnight.consumed(maker, group), maxCap, "consumed exceeds cap");
    }

    function _assertNoUnexpectedProfit(address actor, uint256 balanceBefore, uint256 allowedProfit) internal view {
        assertLe(loanToken.balanceOf(actor), balanceBefore + allowedProfit, "unexpected profit");
    }

    function _assertMarketAccounting(bytes32 id) internal view {
        assertGe(midnight.totalUnits(id), midnight.withdrawable(id), "totalUnits must cover withdrawable");
    }

    function _assertBundlerEmpty() internal view {
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "bundler loan balance leak");
        assertEq(collateralToken1.balanceOf(address(midnightBundles)), 0, "bundler collateral1 leak");
        assertEq(collateralToken2.balanceOf(address(midnightBundles)), 0, "bundler collateral2 leak");
    }

    function _authorizeBundler(address user) internal {
        vm.prank(user);
        midnight.setIsAuthorized(address(midnightBundles), true, user);
    }

    function _basicBuyOffer(address maker, Market memory m) internal view returns (Offer memory offer) {
        offer.market = m;
        offer.buy = true;
        offer.maker = maker;
        offer.start = block.timestamp;
        offer.expiry = block.timestamp + 200 days;
        offer.ratifier = address(dummyRatifier);
        offer.tick = MAX_TICK;
        offer.maxUnits = type(uint256).max;
    }

    function _basicSellOffer(address maker, Market memory m) internal view returns (Offer memory offer) {
        offer.market = m;
        offer.buy = false;
        offer.maker = maker;
        offer.receiverIfMakerIsSeller = maker;
        offer.start = block.timestamp;
        offer.expiry = block.timestamp + 200 days;
        offer.ratifier = address(dummyRatifier);
        offer.tick = MAX_TICK;
        offer.maxUnits = type(uint256).max;
    }

    function _openBorrowerDebt(uint256 units) internal {
        collateralize(market, borrower, units);
        Offer memory sellOffer = _basicSellOffer(borrower, market);
        sellOffer.maxUnits = units;
        vm.prank(lender);
        midnight.take(sellOffer, hex"", units, lender, borrower, address(0), hex"");
    }
}
