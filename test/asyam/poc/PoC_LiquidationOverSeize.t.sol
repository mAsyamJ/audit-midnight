// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {IMidnight} from "../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../helpers/Oracle.sol";
import {ORACLE_PRICE_SCALE, WAD, TIME_TO_MAX_LIF} from "../../../src/libraries/ConstantsLib.sol";
import {UtilsLib} from "../../../src/libraries/UtilsLib.sol";

/// @dev AP-005 / POC-INTENT-005 — liquidator must not seize more collateral than the borrower posted.
contract PoCLiquidationOverSeizeTest is Config {
    using UtilsLib for uint256;
    function testPoC_CannotSeizeMoreThanCollateral(uint256 units, uint256 seized) public {
        units = bound(units, 10e18, 500e18);
        _openBorrowerDebt(units);
        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 10);

        uint256 collateralBefore = midnight.collateral(marketId, borrower, 0);
        seized = bound(seized, collateralBefore + 1, collateralBefore + 1e24);

        _fundLoanToken(LIQUIDATOR_ACTOR, units);
        vm.prank(LIQUIDATOR_ACTOR);
        vm.expectRevert();
        midnight.liquidate(market, 0, seized, 0, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");
    }

    function testPoC_RecoveryCloseFactorCapsRepaidUnits() public {
        uint256 units = 100e18;
        _openBorrowerDebt(units);
        uint256 price = ORACLE_PRICE_SCALE / 5;
        Oracle(market.collateralParams[0].oracle).setPrice(price);

        uint256 lltv = market.collateralParams[0].lltv;
        uint256 maxLif = market.collateralParams[0].maxLif;
        uint256 collateral = midnight.collateral(marketId, borrower, 0);
        uint256 maxDebt = collateral.mulDivDown(price, ORACLE_PRICE_SCALE).mulDivDown(lltv, WAD);
        uint256 debt = midnight.debtOf(marketId, borrower);
        uint256 maxRepaid = (debt - maxDebt).mulDivUp(WAD * WAD, WAD * WAD - maxLif * lltv);

        _fundLoanToken(LIQUIDATOR_ACTOR, debt);
        vm.prank(LIQUIDATOR_ACTOR);
        vm.expectRevert(IMidnight.RecoveryCloseFactorConditionsViolated.selector);
        midnight.liquidate(market, 0, 0, maxRepaid + 1, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");
    }

    function testPoC_LiquidationSeizedNeverExceedsCollateral() public {
        uint256 units = 120e18;
        _openBorrowerDebt(units);
        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 5);

        uint256 collateralBefore = midnight.collateral(marketId, borrower, 0);
        uint256 seizeTarget = collateralBefore / 2;
        if (seizeTarget == 0) seizeTarget = 1;

        _fundLoanToken(LIQUIDATOR_ACTOR, units);
        vm.prank(LIQUIDATOR_ACTOR);
        (uint256 seized,) =
            midnight.liquidate(market, 0, seizeTarget, 0, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");

        assertLe(seized, collateralBefore, "seized must not exceed pre-liquidation collateral");
        assertLe(midnight.collateral(marketId, borrower, 0), collateralBefore - seized, "collateral debited");
        _assertMarketAccounting(marketId);
    }

    function testPoC_MultiLiquidationCannotDrainExtraCollateral() public {
        uint256 units = 200e18;
        _openBorrowerDebt(units);
        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 8);

        uint256 collateralStart = midnight.collateral(marketId, borrower, 0);
        uint256 totalSeized;

        _fundLoanToken(LIQUIDATOR_ACTOR, units * 2);
        for (uint256 i = 0; i < 3; i++) {
            uint256 remaining = midnight.collateral(marketId, borrower, 0);
            if (remaining == 0) break;
            uint256 chunk = remaining / 3 + 1;
            if (chunk > remaining) chunk = remaining;

            vm.prank(LIQUIDATOR_ACTOR);
            (uint256 seized,) =
                midnight.liquidate(market, 0, chunk, 0, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");
            totalSeized += seized;
        }

        assertLe(totalSeized, collateralStart, "cumulative seize cannot exceed initial collateral");
        _assertMarketAccounting(marketId);
    }
}
