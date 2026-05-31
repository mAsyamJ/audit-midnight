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

/// @dev COMP-012 — a later reduce-only route leg must be recomputed after earlier legs change maker exposure.
contract PoCCompReduceOnlyBundleRouteTest is Config {
    bytes32 internal constant GROUP_NORMAL = keccak256("reduce-only-route-normal");
    bytes32 internal constant GROUP_EXACT = keccak256("reduce-only-route-exact");
    bytes32 internal constant GROUP_CROSSING = keccak256("reduce-only-route-crossing");
    bytes32 internal constant GROUP_FALLBACK = keccak256("reduce-only-route-fallback");

    function testComp_RouteSkipsReduceOnlyLegThatWouldCrossCreditIntoDebt() public {
        uint256 initialLenderCredit = 50e18;
        uint256 initialFallbackCredit = 20e18;
        uint256 targetUnits = 60e18;

        collateralize(market, borrower, initialLenderCredit + initialFallbackCredit);
        Offer memory borrowerDebt = _basicSellOffer(borrower, market);
        borrowerDebt.maxUnits = initialLenderCredit + initialFallbackCredit;

        vm.prank(lender);
        midnight.take(borrowerDebt, hex"", initialLenderCredit, lender, borrower, address(0), hex"");
        _fundLoanToken(otherLender, initialFallbackCredit);
        vm.prank(otherLender);
        midnight.take(borrowerDebt, hex"", initialFallbackCredit, otherLender, borrower, address(0), hex"");

        Take[] memory takes = new Take[](4);
        takes[0] = Take({offer: _sellOffer(lender, GROUP_NORMAL, 40e18, false), units: 40e18, ratifierData: hex""});
        takes[1] = Take({offer: _sellOffer(lender, GROUP_EXACT, 10e18, true), units: 10e18, ratifierData: hex""});
        takes[2] = Take({offer: _sellOffer(lender, GROUP_CROSSING, 1, true), units: 1, ratifierData: hex""});
        takes[3] =
            Take({offer: _sellOffer(otherLender, GROUP_FALLBACK, 10e18, false), units: 10e18, ratifierData: hex""});

        vm.prank(borrower);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            targetUnits,
            targetUnits,
            borrower,
            TokenPermit({kind: PermitKind.None, data: hex""}),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            0,
            address(0)
        );

        assertEq(midnight.creditOf(marketId, lender), 0, "accepted reduce-only units only close lender credit");
        assertEq(midnight.debtOf(marketId, lender), 0, "reduce-only route never creates maker debt");
        assertEq(midnight.consumed(lender, GROUP_CROSSING), 0, "crossing reduce-only leg reverted atomically");
        assertEq(midnight.consumed(otherLender, GROUP_FALLBACK), 10e18, "fallback leg completes exact route target");
        assertEq(midnight.debtOf(marketId, borrower), 10e18, "borrower debt reduced by exact routed units");
        _assertBundlerEmpty();
        _assertMarketAccounting(marketId);
    }

    function _sellOffer(address maker, bytes32 group, uint256 maxUnits, bool reduceOnly)
        internal
        view
        returns (Offer memory offer)
    {
        offer = _basicSellOffer(maker, market);
        offer.group = group;
        offer.maxUnits = maxUnits;
        offer.reduceOnly = reduceOnly;
    }
}
