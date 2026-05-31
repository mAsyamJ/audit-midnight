// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Offer} from "../../../../src/interfaces/IMidnight.sol";
import {Take, CollateralSupply} from "../../../../src/periphery/interfaces/IMidnightBundles.sol";

/// @dev BB-POC-003 — a skipped preferred leg and valid fallback must still satisfy explicit route bounds.
contract PoCBlackboxUserIntentBundleTest is Config {
    uint256 internal constant UNITS = 25e18;

    function testBlackbox_SkippedPreferredSellLegFallsBackWithinExplicitDebtAndProceedsBounds() public {
        _fundLoanToken(otherLender, UNITS);
        collateralize(market, borrower, UNITS);

        Offer memory expired = _basicBuyOffer(lender, market);
        expired.group = keccak256("blackbox-expired");
        expired.maxUnits = UNITS;
        expired.expiry = block.timestamp - 1;

        Offer memory fallbackOffer = _basicBuyOffer(otherLender, market);
        fallbackOffer.group = keccak256("blackbox-fallback");
        fallbackOffer.maxUnits = UNITS;

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: expired, units: UNITS, ratifierData: hex""});
        takes[1] = Take({offer: fallbackOffer, units: UNITS, ratifierData: hex""});

        uint256 borrowerBefore = loanToken.balanceOf(borrower);
        vm.prank(borrower);
        midnightBundles.supplyCollateralAndSellWithUnitsTarget(
            UNITS, UNITS, borrower, borrower, new CollateralSupply[](0), takes, 0, address(0)
        );

        assertEq(midnight.consumed(lender, expired.group), 0, "expired preferred leg has no side effect");
        assertEq(midnight.consumed(otherLender, fallbackOffer.group), UNITS, "fallback consumes exact target");
        assertEq(midnight.debtOf(marketId, borrower), UNITS, "borrower debt is bounded by target units");
        assertEq(loanToken.balanceOf(borrower), borrowerBefore + UNITS, "borrower receives explicit minimum");
        _assertBundlerEmpty();
    }
}
