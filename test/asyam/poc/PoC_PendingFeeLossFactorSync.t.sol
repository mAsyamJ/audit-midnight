// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Oracle} from "../../helpers/Oracle.sol";
import {IMidnight, Market, Offer} from "../../../src/interfaces/IMidnight.sol";
import {UtilsLib} from "../../../src/libraries/UtilsLib.sol";
import {MAX_CONTINUOUS_FEE, ORACLE_PRICE_SCALE, WAD} from "../../../src/libraries/ConstantsLib.sol";

/// @dev AP-010 / C-021 / C-034 — `pendingFee` must stay aligned with `lossFactor` slash via `updatePositionView`.
contract PoCPendingFeeLossFactorSyncTest is Config {
    using UtilsLib for uint256;

    uint256 internal constant CREDIT = 50e18;
    uint32 internal constant FEE_RATE = MAX_CONTINUOUS_FEE;
    uint256 internal constant TTM = 90 days;

    function testPoC_UpdatePositionMatchesViewAfterSlash() public {
        _setupFeeMarket();
        vm.warp(block.timestamp + 7 days);

        Oracle(market.collateralParams[0].oracle).setPrice(_badDebtPriceDown(CREDIT));
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        (uint128 viewCredit, uint128 viewPending, uint128 viewAccrued) =
            midnight.updatePositionView(market, marketId, lender);

        (uint128 storedCredit, uint128 storedPending, uint128 storedAccrued) =
            midnight.updatePosition(market, lender);

        assertEq(storedCredit, viewCredit, "credit matches view");
        assertEq(storedPending, viewPending, "pendingFee matches view");
        assertEq(storedAccrued, viewAccrued, "accrued fee matches view");
        assertEq(midnight.lastLossFactor(marketId, lender), midnight.lossFactor(marketId), "lastLossFactor synced");
        assertLe(midnight.pendingFee(marketId, lender), midnight.creditOf(marketId, lender), "pendingFee <= credit");
    }

    function testPoC_TakeRevertsWhenLossFactorMaxed() public {
        _setupFeeMarket();

        Oracle(market.collateralParams[0].oracle).setPrice(0);
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        assertEq(midnight.lossFactor(marketId), type(uint128).max, "terminal lossFactor");

        Offer memory buyOffer = _basicBuyOffer(lender, market);
        buyOffer.maxUnits = 1e18;
        vm.prank(borrower);
        vm.expectRevert(IMidnight.MarketLossFactorMaxedOut.selector);
        midnight.take(buyOffer, hex"", 1e18, borrower, lender, address(0), hex"");
    }

    function testPoC_StaleLastLossFactorSyncedOnTakeWithCredit() public {
        _setupFeeMarket();

        Oracle(market.collateralParams[0].oracle).setPrice(_badDebtPriceDown(CREDIT));
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        assertGt(midnight.lossFactor(marketId), midnight.lastLossFactor(marketId, lender), "stale before touch");

        uint256 creditBefore = midnight.creditOf(marketId, lender);
        Offer memory buyOffer = _basicBuyOffer(otherLender, market);
        buyOffer.maxUnits = 1e18;
        _fundLoanToken(otherLender, 1e30);
        vm.prank(lender);
        midnight.take(buyOffer, hex"", 1e18, lender, otherLender, address(0), hex"");

        assertEq(midnight.lastLossFactor(marketId, lender), midnight.lossFactor(marketId), "synced on take");
        assertLe(midnight.creditOf(marketId, lender), creditBefore, "credit not inflated by stale factor");
        _assertMarketAccounting(marketId);
    }

    function testPoC_DoubleUpdatePositionIdempotentAfterSlash() public {
        _setupFeeMarket();

        Oracle(market.collateralParams[0].oracle).setPrice(_badDebtPriceDown(CREDIT));
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        midnight.updatePosition(market, lender);
        uint256 creditOnce = midnight.creditOf(marketId, lender);
        uint128 pendingOnce = midnight.pendingFee(marketId, lender);

        midnight.updatePosition(market, lender);

        assertEq(midnight.creditOf(marketId, lender), creditOnce, "second update does not re-slash");
        assertEq(midnight.pendingFee(marketId, lender), pendingOnce, "pendingFee stable");
    }

    function _setupFeeMarket() internal {
        market.maturity = block.timestamp + TTM;
        marketId = midnight.touchMarket(market);
        midnight.setMarketTickSpacing(marketId, 1);
        midnight.setDefaultContinuousFee(address(loanToken), uint256(FEE_RATE));

        collateralize(market, borrower, CREDIT);
        setupMarket(market, CREDIT);
    }

    function _badDebtPriceDown(uint256 units) internal view returns (uint256) {
        uint256 lltv = market.collateralParams[0].lltv;
        uint256 maxLif = market.collateralParams[0].maxLif;
        uint256 collateral = units.mulDivUp(WAD, lltv);
        return (units - 1).mulDivDown(maxLif, WAD).mulDivDown(ORACLE_PRICE_SCALE, collateral);
    }
}
