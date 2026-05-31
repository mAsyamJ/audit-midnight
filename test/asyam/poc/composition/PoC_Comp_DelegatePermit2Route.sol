// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Offer} from "../../../../src/interfaces/IMidnight.sol";
import {
    Take,
    TokenPermit,
    PermitKind,
    CollateralWithdrawal
} from "../../../../src/periphery/interfaces/IMidnightBundles.sol";
import {Permit2 as VendorPermit2} from "../../../vendor/Permit2.sol";

/// @dev COMP-005 — Permit2 owner is the route caller even when Midnight execution is delegated for another taker.
contract PoCCompDelegatePermit2RouteTest is Config {
    address internal constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    function setUp() public override {
        super.setUp();
        deployCodeTo("Permit2", PERMIT2);
    }

    function testComp_DelegatedTakerRouteChargesCallerPermitAndPaysReferralExactly() public {
        (address delegate, uint256 delegateKey) = makeAddrAndKey("compositionDelegate");
        uint256 units = 9e18;
        uint256 budget = 10e18;
        uint256 referralFeePct = 0.1e18;

        vm.prank(lender);
        midnight.setIsAuthorized(delegate, true, lender);
        deal(address(loanToken), delegate, budget);
        vm.prank(delegate);
        loanToken.approve(PERMIT2, type(uint256).max);

        collateralize(market, borrower, units);
        Offer memory offer = _basicSellOffer(borrower, market);
        offer.maxUnits = units;

        Take[] memory takes = _oneTake(offer, units);
        TokenPermit memory permit = _permit2(address(loanToken), budget, 0, block.timestamp + 1 days, delegateKey);

        uint256 borrowerBefore = loanToken.balanceOf(borrower);
        uint256 referralBefore = loanToken.balanceOf(REFERRAL);
        vm.prank(delegate);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            units, budget, lender, permit, takes, new CollateralWithdrawal[](0), address(0), referralFeePct, REFERRAL
        );

        assertEq(loanToken.balanceOf(delegate), 0, "delegated route caller pays declared budget");
        assertEq(loanToken.balanceOf(borrower), borrowerBefore + units, "maker receives filled seller assets");
        assertEq(loanToken.balanceOf(REFERRAL), referralBefore + 1e18, "referral receives declared split");
        assertEq(midnight.creditOf(marketId, lender), units, "delegated taker receives credit");
        _assertBundlerEmpty();
        _assertMarketAccounting(marketId);
    }

    function testComp_VictimPermitCannotBeUsedByDifferentDelegatedCaller() public {
        (address delegate,) = makeAddrAndKey("compositionDelegate");
        (address victim, uint256 victimKey) = makeAddrAndKey("compositionPermitVictim");
        uint256 units = 9e18;
        uint256 budget = 10e18;

        vm.prank(lender);
        midnight.setIsAuthorized(delegate, true, lender);
        deal(address(loanToken), victim, budget);
        vm.prank(victim);
        loanToken.approve(PERMIT2, type(uint256).max);

        collateralize(market, borrower, units);
        Offer memory offer = _basicSellOffer(borrower, market);
        offer.maxUnits = units;

        Take[] memory takes = _oneTake(offer, units);
        TokenPermit memory victimPermit = _permit2(address(loanToken), budget, 77, block.timestamp + 1 days, victimKey);

        uint256 victimBefore = loanToken.balanceOf(victim);
        uint256 borrowerDebtBefore = midnight.debtOf(marketId, borrower);
        vm.prank(delegate);
        vm.expectRevert();
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            units, budget, lender, victimPermit, takes, new CollateralWithdrawal[](0), address(0), 0, address(0)
        );

        assertEq(loanToken.balanceOf(victim), victimBefore, "victim funds unchanged");
        assertEq(midnight.debtOf(marketId, borrower), borrowerDebtBefore, "route state rolled back");
        assertEq(loanToken.balanceOf(address(midnightBundles)), 0, "router pull rolled back");
    }

    function _permit2(address token, uint256 amount, uint256 nonce, uint256 deadline, uint256 signerKey)
        internal
        view
        returns (TokenPermit memory)
    {
        bytes32 tokenPermissionsHash =
            keccak256(abi.encode(keccak256("TokenPermissions(address token,uint256 amount)"), token, amount));
        bytes32 permitHash = keccak256(
            abi.encode(
                keccak256(
                    "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
                ),
                tokenPermissionsHash,
                address(midnightBundles),
                nonce,
                deadline
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", VendorPermit2(PERMIT2).DOMAIN_SEPARATOR(), permitHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerKey, digest);
        return TokenPermit({kind: PermitKind.Permit2, data: abi.encode(nonce, deadline, abi.encodePacked(r, s, v))});
    }

    function _oneTake(Offer memory offer, uint256 units) internal pure returns (Take[] memory takes) {
        takes = new Take[](1);
        takes[0] = Take({offer: offer, units: units, ratifierData: hex""});
    }
}
