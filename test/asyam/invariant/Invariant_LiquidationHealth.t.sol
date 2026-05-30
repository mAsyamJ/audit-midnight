// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {IMidnight} from "../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../helpers/Oracle.sol";
import {ORACLE_PRICE_SCALE} from "../../../src/libraries/ConstantsLib.sol";

contract InvariantLiquidationHealthTest is Config {
    function testInvariant_HealthyBorrowerLiquidationReverts() public {
        _openBorrowerDebt(100);
        _assertPositionHealthy(marketId, market, borrower);

        vm.expectRevert(IMidnight.NotLiquidatable.selector);
        midnight.liquidate(market, 0, 0, 10, borrower, false, address(this), address(0), hex"");
    }

    function testInvariant_UnhealthyBorrowerCanBeLiquidated() public {
        _openBorrowerDebt(100);

        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 10);
        assertFalse(midnight.isHealthy(market, marketId, borrower));

        deal(address(loanToken), liquidator, 1000);
        vm.prank(liquidator);
        midnight.liquidate(market, 0, 0, 10, borrower, false, address(0), address(0), hex"");
    }
}
