// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {BaseTest} from "../BaseTest.sol";
import {ERC20} from "../erc20s/ERC20.sol";
import {Oracle} from "../helpers/Oracle.sol";
import {Market, Offer, CollateralParams} from "../../src/interfaces/IMidnight.sol";
import {MidnightBundles} from "../../src/periphery/MidnightBundles.sol";
import {
    Take,
    CollateralWithdrawal,
    CollateralSupply,
    TokenPermit
} from "../../src/periphery/interfaces/IMidnightBundles.sol";
import {UtilsLib} from "../../src/libraries/UtilsLib.sol";
import {MAX_TICK} from "../../src/libraries/TickLib.sol";
import {WAD, ORACLE_PRICE_SCALE, LLTV_2, LIQUIDATION_CURSOR_LOW, maxLif} from "../../src/libraries/ConstantsLib.sol";

/// @notice Shared base for asyam finding PoCs. Keep production contracts untouched.
abstract contract AsyamFindingConfig is BaseTest {
    using UtilsLib for uint256;

    MidnightBundles internal midnightBundles;

    function setUp() public virtual override {
        super.setUp();

        midnightBundles = new MidnightBundles(address(midnight));

        vm.prank(borrower);
        midnight.setIsAuthorized(address(midnightBundles), true, borrower);
        vm.prank(lender);
        midnight.setIsAuthorized(address(midnightBundles), true, lender);
        vm.prank(otherBorrower);
        midnight.setIsAuthorized(address(midnightBundles), true, otherBorrower);
        vm.prank(otherLender);
        midnight.setIsAuthorized(address(midnightBundles), true, otherLender);

        vm.prank(lender);
        loanToken.approve(address(midnightBundles), type(uint256).max);
        vm.prank(borrower);
        loanToken.approve(address(midnightBundles), type(uint256).max);
    }

    function _noPermit() internal pure returns (TokenPermit memory) {}

    function _singleCollateralMarket() internal view returns (Market memory market) {
        CollateralParams[] memory params = new CollateralParams[](1);
        params[0] = CollateralParams({
            token: address(collateralToken1),
            lltv: LLTV_2,
            maxLif: maxLif(LLTV_2, LIQUIDATION_CURSOR_LOW),
            oracle: address(oracle1)
        });

        market = Market({
            loanToken: address(loanToken),
            collateralParams: params,
            maturity: block.timestamp + 30 days,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(0)
        });
    }

    function _sameTokenMarket() internal view returns (Market memory market) {
        CollateralParams[] memory params = new CollateralParams[](1);
        params[0] = CollateralParams({
            token: address(loanToken),
            lltv: LLTV_2,
            maxLif: maxLif(LLTV_2, LIQUIDATION_CURSOR_LOW),
            oracle: address(oracle1)
        });

        market = Market({
            loanToken: address(loanToken),
            collateralParams: params,
            maturity: block.timestamp + 30 days,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(0)
        });
    }

    function _touchWithZeroSettlementFees(Market memory market) internal returns (bytes32 id) {
        id = midnight.touchMarket(market);
        for (uint256 i; i <= 6; i++) {
            midnight.setMarketSettlementFee(id, i, 0);
        }
    }

    function _buyOffer(Market memory market, address maker, uint256 maxUnits)
        internal
        view
        returns (Offer memory offer)
    {
        offer.market = market;
        offer.buy = true;
        offer.maker = maker;
        offer.maxUnits = maxUnits;
        offer.ratifier = address(dummyRatifier);
        offer.start = block.timestamp;
        offer.expiry = block.timestamp + 1 days;
        offer.tick = MAX_TICK;
    }

    function _sellOffer(Market memory market, address maker, uint256 maxUnits)
        internal
        view
        returns (Offer memory offer)
    {
        offer.market = market;
        offer.buy = false;
        offer.maker = maker;
        offer.receiverIfMakerIsSeller = maker;
        offer.maxUnits = maxUnits;
        offer.ratifier = address(dummyRatifier);
        offer.start = block.timestamp;
        offer.expiry = block.timestamp + 1 days;
        offer.tick = MAX_TICK;
    }

    function _take(Offer memory offer, uint256 units, address taker) internal returns (uint256, uint256) {
        vm.prank(taker);
        return midnight.take(offer, hex"", units, taker, taker, address(0), hex"");
    }

    function _bundleTake(Offer memory offer, uint256 units) internal pure returns (Take memory) {
        return Take({offer: offer, units: units, ratifierData: hex""});
    }

    function _emptyWithdrawals() internal pure returns (CollateralWithdrawal[] memory) {
        return new CollateralWithdrawal[](0);
    }

    function _emptySupplies() internal pure returns (CollateralSupply[] memory) {
        return new CollateralSupply[](0);
    }

    function _collateralForDebt(Market memory market, uint256 debt, uint256 collateralIndex)
        internal
        view
        returns (uint256)
    {
        uint256 oraclePrice = Oracle(market.collateralParams[collateralIndex].oracle).price();
        return
            debt.mulDivUp(WAD, market.collateralParams[collateralIndex].lltv).mulDivUp(ORACLE_PRICE_SCALE, oraclePrice);
    }

    function _approveMidnight(address token, address owner, uint256 amount) internal {
        vm.prank(owner);
        ERC20(token).approve(address(midnight), amount);
    }
}
