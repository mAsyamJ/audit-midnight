// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Oracle} from "../../helpers/Oracle.sol";
import {ORACLE_PRICE_SCALE, WAD, TIME_TO_MAX_LIF} from "../../../src/libraries/ConstantsLib.sol";
import {UtilsLib} from "../../../src/libraries/UtilsLib.sol";

/// @dev AP-006 / POC-INTENT-006 — post-maturity liquidation must not over-seize vs collateral or diverge from LIF math.
contract PoCPostMaturityLiquidationTest is Config {
    using UtilsLib for uint256;
    function testPoC_PostMaturitySeizeRespectsCollateral() public {
        uint256 units = 150e18;
        _openBorrowerDebt(units);
        _warpAfterMaturity(market);
        vm.warp(market.maturity + TIME_TO_MAX_LIF);

        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 3);

        uint256 collateralBefore = midnight.collateral(marketId, borrower, 0);
        uint256 seizeAmount = collateralBefore / 2;

        _fundLoanToken(LIQUIDATOR_ACTOR, units);
        vm.prank(LIQUIDATOR_ACTOR);
        (uint256 seized,) =
            midnight.liquidate(market, 0, seizeAmount, 0, borrower, true, LIQUIDATOR_ACTOR, address(0), hex"");

        assertLe(seized, collateralBefore);
        _assertMarketAccounting(marketId);
    }

    function testPoC_PostMaturityLifBoundedByMaxLif(uint256 delay) public {
        uint256 units = 100e18;
        _openBorrowerDebt(units);
        delay = bound(delay, 1, TIME_TO_MAX_LIF);

        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 4);
        _warpAfterMaturity(market);
        vm.warp(market.maturity + delay);

        uint256 maxLif = market.collateralParams[0].maxLif;
        uint256 collateral = midnight.collateral(marketId, borrower, 0);
        uint256 price = ORACLE_PRICE_SCALE / 4;
        uint256 seized = collateral / 3;
        if (seized == 0) seized = 1;

        _fundLoanToken(LIQUIDATOR_ACTOR, units);
        vm.prank(LIQUIDATOR_ACTOR);
        (, uint256 repaid) =
            midnight.liquidate(market, 0, seized, 0, borrower, true, LIQUIDATOR_ACTOR, address(0), hex"");

        uint256 lifAtDelay = WAD + (maxLif - WAD) * delay / TIME_TO_MAX_LIF;
        uint256 repaidUpper =
            seized.mulDivUp(price, ORACLE_PRICE_SCALE).mulDivUp(WAD, lifAtDelay);
        assertLe(repaid, repaidUpper + 1, "repaid units follow post-maturity LIF cap");
    }

    function testPoC_HealthyBorrowerPostMaturityNormalModeReverts() public {
        uint256 units = 80e18;
        _openBorrowerDebt(units);
        _warpAfterMaturity(market);
        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE);

        vm.prank(LIQUIDATOR_ACTOR);
        vm.expectRevert();
        midnight.liquidate(market, 0, 0, 10e18, borrower, false, LIQUIDATOR_ACTOR, address(0), hex"");
    }
}
