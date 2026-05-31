// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Oracle} from "../../helpers/Oracle.sol";
import {LiquidateReentrantAttacker} from "../mocks/LiquidateReentrantAttacker.sol";
import {ORACLE_PRICE_SCALE, TIME_TO_MAX_LIF} from "../../../src/libraries/ConstantsLib.sol";

/// @dev AP-026 slice — nested `liquidate` during `onLiquidate` must not profit the attacker.
contract PoCLiquidateCallbackReentrancyTest is Config {
    function testPoC_LiquidateCallbackNestedLiquidateDoesNotProfitAttacker() public {
        uint256 units = 100e18;
        _openBorrowerDebt(units);
        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 10);
        _warpAfterMaturity(market);
        vm.warp(market.maturity + TIME_TO_MAX_LIF);

        LiquidateReentrantAttacker attackerContract = new LiquidateReentrantAttacker();
        attackerContract.configure(midnight, ATTACKER);
        attackerContract.setNestedLiquidate(market, 3e18, borrower);

        _fundLoanToken(address(attackerContract), units);
        _fundLoanToken(LIQUIDATOR_ACTOR, units);

        uint256 attackerBefore = loanToken.balanceOf(ATTACKER);
        uint256 midnightBefore = loanToken.balanceOf(address(midnight));

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(
            market, 0, 0, 10e18, borrower, true, LIQUIDATOR_ACTOR, address(attackerContract), hex"01"
        );

        assertTrue(attackerContract.reenteredLiquidate(), "nested liquidate attempted");
        assertEq(attackerContract.stolen(), 0, "no loan-token profit to attacker EOA");
        assertEq(loanToken.balanceOf(ATTACKER), attackerBefore, "attacker balance unchanged");
        assertGe(loanToken.balanceOf(address(midnight)), midnightBefore, "midnight custody not drained");
        _assertMarketAccounting(marketId);
    }
}
