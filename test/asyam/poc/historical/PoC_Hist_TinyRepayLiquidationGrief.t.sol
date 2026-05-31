// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {IMidnight} from "../../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../../helpers/Oracle.sol";
import {ORACLE_PRICE_SCALE, TIME_TO_MAX_LIF} from "../../../../src/libraries/ConstantsLib.sol";
import {stdError} from "../../../../lib/forge-std/src/StdError.sol";

/// @dev HPH-POC-001 — tiny borrower repayments must not escalate stale liquidation quotes into lender loss.
contract PoCHistTinyRepayLiquidationGriefTest is Config {
    uint256 internal constant UNITS = 100e18;

    function testHist_TinyRepayInvalidatesStaleExactLiquidationButAdaptiveRetryRecoversEquivalentValue() public {
        _openBorrowerDebt(UNITS);
        _fundLoanToken(LIQUIDATOR_ACTOR, UNITS);
        vm.warp(market.maturity + TIME_TO_MAX_LIF);

        uint256 snapshot = vm.snapshotState();

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(market, 0, 0, UNITS, borrower, true, LIQUIDATOR_ACTOR, address(0), hex"");

        uint256 controlWithdrawable = midnight.withdrawable(marketId);
        assertEq(midnight.debtOf(marketId, borrower), 0, "control liquidation repays all debt");
        assertEq(midnight.lossFactor(marketId), 0, "control liquidation realizes no bad debt");

        vm.revertToState(snapshot);

        vm.prank(borrower);
        midnight.repay(market, 1, borrower, address(0), hex"");

        vm.prank(LIQUIDATOR_ACTOR);
        vm.expectRevert(stdError.arithmeticError);
        midnight.liquidate(market, 0, 0, UNITS, borrower, true, LIQUIDATOR_ACTOR, address(0), hex"");

        uint256 currentDebt = midnight.debtOf(marketId, borrower);
        assertEq(currentDebt, UNITS - 1, "tiny repayment lowers debt by one wei");

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(market, 0, 0, currentDebt, borrower, true, LIQUIDATOR_ACTOR, address(0), hex"");

        assertEq(midnight.debtOf(marketId, borrower), 0, "adaptive liquidation repays current debt");
        assertEq(midnight.lossFactor(marketId), 0, "tiny repayment does not create bad debt");
        assertEq(midnight.withdrawable(marketId), controlWithdrawable, "adaptive retry restores equivalent recovery");

        uint256 lenderBefore = loanToken.balanceOf(lender);
        vm.prank(lender);
        midnight.withdraw(market, UNITS, lender, lender);
        assertEq(loanToken.balanceOf(lender), lenderBefore + UNITS, "lender can withdraw the full recovered claim");
    }

    function testHist_TinyRepayDoesNotIncreaseBadDebtUnderIdenticalLowerPrice() public {
        _openBorrowerDebt(UNITS);
        uint256 totalUnitsBefore = midnight.totalUnits(marketId);
        uint256 snapshot = vm.snapshotState();

        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 2);
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");
        uint256 controlSlash = totalUnitsBefore - midnight.totalUnits(marketId);
        midnight.updatePosition(market, lender);
        uint256 controlLenderCredit = midnight.creditOf(marketId, lender);

        vm.revertToState(snapshot);

        vm.prank(borrower);
        midnight.repay(market, 1, borrower, address(0), hex"");
        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 2);
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");
        uint256 adversarialSlash = totalUnitsBefore - midnight.totalUnits(marketId);
        midnight.updatePosition(market, lender);
        uint256 adversarialLenderCredit = midnight.creditOf(marketId, lender);

        assertGt(controlSlash, 0, "control realizes non-dust bad debt");
        assertLe(adversarialSlash, controlSlash, "tiny repayment cannot increase socialized loss");
        assertGe(adversarialLenderCredit, controlLenderCredit, "tiny repayment cannot worsen lender recovery");
    }

    function testHist_UnauthorizedThirdPartyCannotDustRepayBorrower() public {
        _openBorrowerDebt(UNITS);
        _fundLoanToken(ATTACKER, 1);

        vm.prank(ATTACKER);
        vm.expectRevert(IMidnight.Unauthorized.selector);
        midnight.repay(market, 1, borrower, address(0), hex"");

        assertEq(midnight.debtOf(marketId, borrower), UNITS, "unauthorized third party cannot mutate borrower debt");
    }
}
