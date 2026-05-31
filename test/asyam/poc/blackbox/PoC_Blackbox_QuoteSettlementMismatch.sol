// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Offer} from "../../../../src/interfaces/IMidnight.sol";
import {Take, CollateralSupply} from "../../../../src/periphery/interfaces/IMidnightBundles.sol";
import {MAX_SETTLEMENT_FEE_0_DAYS, MAX_SETTLEMENT_FEE_1_DAY} from "../../../../src/libraries/ConstantsLib.sol";
import {TickLib, MAX_TICK} from "../../../../src/libraries/TickLib.sol";

/// @dev BB-POC-005 — a current fee change may skip stale legs, but a successful fallback remains inside call bounds.
contract PoCBlackboxQuoteSettlementMismatchTest is Config {
    uint256 internal constant UNITS = 20e18;
    uint256 internal constant LOWER_TICK = 600;

    function testBlackbox_FeeChangeSkipsStalePreferredLegAndKeepsFallbackInsideBounds() public {
        _fundLoanToken(otherLender, UNITS);
        collateralize(market, borrower, UNITS);

        Offer memory stale = _basicBuyOffer(lender, market);
        stale.group = keccak256("blackbox-fee-stale");
        stale.tick = LOWER_TICK;
        stale.maxUnits = UNITS;

        Offer memory fallbackOffer = _basicBuyOffer(otherLender, market);
        fallbackOffer.group = keccak256("blackbox-fee-fallback");
        fallbackOffer.maxUnits = UNITS;

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: stale, units: UNITS, ratifierData: hex""});
        takes[1] = Take({offer: fallbackOffer, units: UNITS, ratifierData: hex""});

        midnight.setMarketSettlementFee(marketId, 0, MAX_SETTLEMENT_FEE_0_DAYS);
        midnight.setMarketSettlementFee(marketId, 1, MAX_SETTLEMENT_FEE_1_DAY);
        uint256 currentFee = midnight.settlementFee(marketId, market.maturity - block.timestamp);
        assertGt(currentFee, TickLib.tickToPrice(LOWER_TICK), "fee transition invalidates preferred leg");

        uint256 fallbackProceeds = UNITS * (TickLib.tickToPrice(MAX_TICK) - currentFee) / 1e18;
        uint256 borrowerBefore = loanToken.balanceOf(borrower);
        vm.prank(borrower);
        midnightBundles.supplyCollateralAndSellWithUnitsTarget(
            UNITS, fallbackProceeds, borrower, borrower, new CollateralSupply[](0), takes, 0, address(0)
        );

        assertEq(midnight.consumed(lender, stale.group), 0, "stale low-price leg is skipped atomically");
        assertEq(midnight.consumed(otherLender, fallbackOffer.group), UNITS, "fallback consumes exact units");
        assertEq(midnight.debtOf(marketId, borrower), UNITS, "fallback debt stays inside target");
        assertEq(loanToken.balanceOf(borrower), borrowerBefore + fallbackProceeds, "minimum proceeds enforced");
        _assertBundlerEmpty();
    }
}
