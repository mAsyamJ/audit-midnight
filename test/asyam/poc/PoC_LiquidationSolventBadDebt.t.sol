// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {IMidnight} from "../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../helpers/Oracle.sol";
import {IOracle} from "../../../src/interfaces/IOracle.sol";
import {UtilsLib} from "../../../src/libraries/UtilsLib.sol";
import {ORACLE_PRICE_SCALE, WAD} from "../../../src/libraries/ConstantsLib.sol";

/// @dev AP-004 / POC-INTENT-004 — bad-debt realization must track underwater collateral, not healthy borrowers.
contract PoCLiquidationSolventBadDebtTest is Config {
    using UtilsLib for uint256;
    using UtilsLib for uint128;

    function testPoC_HealthyBorrowerZeroLiquidationReverts() public {
        uint256 units = 100e18;
        _openBorrowerDebt(units);
        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE);

        _assertPositionHealthy(marketId, market, borrower);

        vm.expectRevert(IMidnight.NotLiquidatable.selector);
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");
    }

    function testPoC_BadDebtRealizationMatchesCollateralShortfall() public {
        uint256 units = 100e18;
        _openBorrowerDebt(units);

        uint256 price = _badDebtPriceDown(units);
        Oracle(market.collateralParams[0].oracle).setPrice(price);

        uint256 debtBefore = midnight.debtOf(marketId, borrower);
        uint256 totalUnitsBefore = midnight.totalUnits(marketId);
        uint256 expectedBadDebt = _computeBadDebtAtPrice(price);

        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        assertEq(midnight.debtOf(marketId, borrower), debtBefore - expectedBadDebt, "debt reduced by bad debt");
        assertEq(midnight.totalUnits(marketId), totalUnitsBefore - expectedBadDebt, "totalUnits socializes loss");
        _assertMarketAccounting(marketId);
    }

    function testPoC_LiquidatorCannotExtractLoanTokensViaBadDebtOnly() public {
        uint256 units = 100e18;
        _openBorrowerDebt(units);

        Oracle(market.collateralParams[0].oracle).setPrice(_badDebtPriceDown(units));

        uint256 liquidatorBefore = loanToken.balanceOf(LIQUIDATOR_ACTOR);
        uint256 midnightBefore = loanToken.balanceOf(address(midnight));

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        assertEq(loanToken.balanceOf(LIQUIDATOR_ACTOR), liquidatorBefore, "bad-debt-only liquidation pays no loan tokens");
        assertLe(loanToken.balanceOf(address(midnight)), midnightBefore, "midnight loan balance does not increase");
    }

    function _badDebtPriceDown(uint256 units) internal view returns (uint256) {
        uint256 lltv = market.collateralParams[0].lltv;
        uint256 maxLif = market.collateralParams[0].maxLif;
        uint256 collateral = units.mulDivUp(WAD, lltv);
        return (units - 1).mulDivDown(maxLif, WAD).mulDivDown(ORACLE_PRICE_SCALE, collateral);
    }

    function _computeBadDebtAtPrice(uint256 price) internal view returns (uint256 badDebt) {
        badDebt = midnight.debtOf(marketId, borrower);
        uint128 bitmap = midnight.collateralBitmap(marketId, borrower);
        while (bitmap != 0) {
            uint256 i = UtilsLib.msb(bitmap);
            uint256 maxLif = market.collateralParams[i].maxLif;
            badDebt = badDebt.zeroFloorSub(
                uint256(midnight.collateral(marketId, borrower, i)).mulDivUp(price, ORACLE_PRICE_SCALE)
                    .mulDivUp(WAD, maxLif)
            );
            bitmap = bitmap.clearBit(i);
        }
    }
}
