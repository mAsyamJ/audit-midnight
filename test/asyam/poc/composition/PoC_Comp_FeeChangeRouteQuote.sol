// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Offer} from "../../../../src/interfaces/IMidnight.sol";
import {IMidnightBundles, Take, CollateralSupply} from "../../../../src/periphery/interfaces/IMidnightBundles.sol";
import {TickLib, MAX_TICK} from "../../../../src/libraries/TickLib.sol";
import {WAD, MAX_SETTLEMENT_FEE_0_DAYS, MAX_SETTLEMENT_FEE_1_DAY} from "../../../../src/libraries/ConstantsLib.sol";
import {UtilsLib} from "../../../../src/libraries/UtilsLib.sol";

/// @dev COMP-010 / COMP-021 / COMP-025 — fee updates may stale a quote, but route bounds and fallback settlement must
/// hold.
contract PoCCompFeeChangeRouteQuoteTest is Config {
    using UtilsLib for uint256;

    bytes32 internal constant GROUP_STALE = keccak256("fee-change-stale-leg");
    bytes32 internal constant GROUP_FALLBACK = keccak256("fee-change-fallback-leg");
    uint256 internal constant LOW_NONZERO_TICK = 600;

    function testComp_FeeUpdateSkipsStaleLegAndSettlesFallbackAtCurrentFee() public {
        uint256 units = 20e18;
        Offer memory staleOffer = _buyOffer(lender, GROUP_STALE, LOW_NONZERO_TICK, units);
        Offer memory fallbackOffer = _buyOffer(otherLender, GROUP_FALLBACK, MAX_TICK, units);
        assertGt(TickLib.tickToPrice(staleOffer.tick), 0, "stale offer is valid before fee update");
        _fundLoanToken(otherLender, units);

        _raiseNearMaturitySettlementFee();
        collateralize(market, borrower, units);

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: staleOffer, units: units, ratifierData: hex""});
        takes[1] = Take({offer: fallbackOffer, units: units, ratifierData: hex""});

        uint256 fee = midnight.settlementFee(marketId, market.maturity - block.timestamp);
        uint256 borrowerBefore = loanToken.balanceOf(borrower);
        vm.prank(borrower);
        midnightBundles.supplyCollateralAndSellWithUnitsTarget(
            units, 0, borrower, borrower, new CollateralSupply[](0), takes, 0, address(0)
        );

        assertEq(midnight.consumed(lender, GROUP_STALE), 0, "stale underflowing leg is skipped atomically");
        assertEq(midnight.consumed(otherLender, GROUP_FALLBACK), units, "fallback fills exact units");
        assertEq(
            loanToken.balanceOf(borrower),
            borrowerBefore + units.mulDivDown(TickLib.tickToPrice(MAX_TICK) - fee, WAD),
            "seller receives fallback value under current fee"
        );
        assertEq(midnight.debtOf(marketId, borrower), units, "only fallback debt is accepted");
        _assertBundlerEmpty();
        _assertMarketAccounting(marketId);
    }

    function testComp_AllStaleFeeRouteRevertsAndRollsBack() public {
        uint256 units = 7e18;
        Offer memory staleOffer = _buyOffer(lender, GROUP_STALE, LOW_NONZERO_TICK, units);
        _raiseNearMaturitySettlementFee();
        collateralize(market, borrower, units);

        Take[] memory takes = new Take[](1);
        takes[0] = Take({offer: staleOffer, units: units, ratifierData: hex""});

        uint256 borrowerBefore = loanToken.balanceOf(borrower);
        vm.prank(borrower);
        vm.expectRevert(IMidnightBundles.OutOfOffers.selector);
        midnightBundles.supplyCollateralAndSellWithUnitsTarget(
            units, 0, borrower, borrower, new CollateralSupply[](0), takes, 0, address(0)
        );

        assertEq(midnight.consumed(lender, GROUP_STALE), 0, "failed stale route consumes nothing");
        assertEq(midnight.debtOf(marketId, borrower), 0, "failed stale route creates no debt");
        assertEq(loanToken.balanceOf(borrower), borrowerBefore, "failed stale route transfers no loan token");
        _assertBundlerEmpty();
    }

    function _raiseNearMaturitySettlementFee() internal {
        midnight.setMarketSettlementFee(marketId, 0, MAX_SETTLEMENT_FEE_0_DAYS);
        midnight.setMarketSettlementFee(marketId, 1, MAX_SETTLEMENT_FEE_1_DAY);
        assertGt(
            midnight.settlementFee(marketId, market.maturity - block.timestamp), TickLib.tickToPrice(LOW_NONZERO_TICK)
        );
    }

    function _buyOffer(address maker, bytes32 group, uint256 tick, uint256 maxUnits)
        internal
        view
        returns (Offer memory offer)
    {
        offer = _basicBuyOffer(maker, market);
        offer.group = group;
        offer.tick = tick;
        offer.maxUnits = maxUnits;
    }
}
