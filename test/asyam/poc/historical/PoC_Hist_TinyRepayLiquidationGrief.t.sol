// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {IMidnight} from "../../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../../helpers/Oracle.sol";
import {ORACLE_PRICE_SCALE, TIME_TO_MAX_LIF} from "../../../../src/libraries/ConstantsLib.sol";
import {stdError} from "../../../../lib/forge-std/src/StdError.sol";

import {console2} from "forge-std/console2.sol";

/// @dev HPH-POC-001 — tiny borrower repayments must not escalate stale liquidation quotes into lender loss.
contract PoCHistTinyRepayLiquidationGriefTest is Config {
    uint256 internal constant UNITS = 100e18;

    function testHist_TinyRepayInvalidatesStaleExactLiquidationButAdaptiveRetryRecoversEquivalentValue() public {
        console2.log("");
        console2.log("======================================================================");
        console2.log("PoC 1: Tiny repayment invalidates stale exact liquidation");
        console2.log("======================================================================");

        console2.log("[1] Opening borrower debt");
        console2.log("    target debt units:", UNITS);
        _openBorrowerDebt(UNITS);

        console2.log("    borrower:", borrower);
        console2.log("    lender:", lender);
        console2.log("    liquidator:", LIQUIDATOR_ACTOR);
        console2.log("    marketId:");
        console2.logBytes32(marketId);
        console2.log("    borrower debt after opening:", midnight.debtOf(marketId, borrower));
        console2.log("    market totalUnits:", midnight.totalUnits(marketId));
        console2.log("    market withdrawable:", midnight.withdrawable(marketId));
        console2.log("    market lossFactor:", midnight.lossFactor(marketId));

        console2.log("[2] Funding liquidator with loan tokens");
        _fundLoanToken(LIQUIDATOR_ACTOR, UNITS);
        console2.log("    liquidator loanToken balance:", loanToken.balanceOf(LIQUIDATOR_ACTOR));

        console2.log("[3] Warping to maturity + TIME_TO_MAX_LIF");
        console2.log("    current timestamp before warp:", block.timestamp);
        console2.log("    market maturity:", market.maturity);
        console2.log("    TIME_TO_MAX_LIF:", TIME_TO_MAX_LIF);

        vm.warp(market.maturity + TIME_TO_MAX_LIF);

        console2.log("    current timestamp after warp:", block.timestamp);

        console2.log("[4] Taking snapshot before control liquidation");
        uint256 snapshot = vm.snapshotState();
        console2.log("    snapshot id:", snapshot);

        console2.log("[5] Control path: liquidator repays exact full debt");
        console2.log("    liquidate repaidUnits:", UNITS);
        console2.log("    borrower debt before control liquidation:", midnight.debtOf(marketId, borrower));

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(
            market,
            0,
            0,
            UNITS,
            borrower,
            true,
            LIQUIDATOR_ACTOR,
            address(0),
            hex""
        );

        uint256 controlWithdrawable = midnight.withdrawable(marketId);

        console2.log("    borrower debt after control liquidation:", midnight.debtOf(marketId, borrower));
        console2.log("    control withdrawable:", controlWithdrawable);
        console2.log("    control lossFactor:", midnight.lossFactor(marketId));
        console2.log("    control totalUnits:", midnight.totalUnits(marketId));

        assertEq(
            midnight.debtOf(marketId, borrower),
            0,
            "control liquidation repays all debt"
        );
        console2.log("    OK: control liquidation repays all borrower debt");

        assertEq(
            midnight.lossFactor(marketId),
            0,
            "control liquidation realizes no bad debt"
        );
        console2.log("    OK: control liquidation realizes no bad debt");

        console2.log("[6] Reverting to snapshot");
        vm.revertToState(snapshot);

        console2.log("    borrower debt after revert:", midnight.debtOf(marketId, borrower));
        console2.log("    withdrawable after revert:", midnight.withdrawable(marketId));
        console2.log("    lossFactor after revert:", midnight.lossFactor(marketId));

        console2.log("[7] Borrower front-runs with one-wei repayment");
        console2.log("    borrower debt before tiny repay:", midnight.debtOf(marketId, borrower));
        console2.log("    repay units:", uint256(1));

        vm.prank(borrower);
        midnight.repay(market, 1, borrower, address(0), hex"");

        console2.log("    borrower debt after tiny repay:", midnight.debtOf(marketId, borrower));
        console2.log("    withdrawable after tiny repay:", midnight.withdrawable(marketId));

        console2.log("[8] Stale exact liquidation attempts to repay old full debt");
        console2.log("    stale repaidUnits:", UNITS);
        console2.log("    current borrower debt:", midnight.debtOf(marketId, borrower));
        console2.log("    expected behavior: arithmetic underflow revert");

        vm.prank(LIQUIDATOR_ACTOR);
        vm.expectRevert(stdError.arithmeticError);
        midnight.liquidate(
            market,
            0,
            0,
            UNITS,
            borrower,
            true,
            LIQUIDATOR_ACTOR,
            address(0),
            hex""
        );

        console2.log("    OK: stale exact liquidation reverted with arithmetic error");

        uint256 currentDebt = midnight.debtOf(marketId, borrower);

        console2.log("[9] Validating current debt after tiny repayment");
        console2.log("    currentDebt:", currentDebt);
        console2.log("    expected currentDebt:", UNITS - 1);

        assertEq(
            currentDebt,
            UNITS - 1,
            "tiny repayment lowers debt by one wei"
        );
        console2.log("    OK: tiny repayment lowered debt by exactly one wei");

        console2.log("[10] Adaptive retry: liquidator repays recomputed current debt");
        console2.log("    adaptive repaidUnits:", currentDebt);

        vm.prank(LIQUIDATOR_ACTOR);
        midnight.liquidate(
            market,
            0,
            0,
            currentDebt,
            borrower,
            true,
            LIQUIDATOR_ACTOR,
            address(0),
            hex""
        );

        console2.log("    borrower debt after adaptive liquidation:", midnight.debtOf(marketId, borrower));
        console2.log("    lossFactor after adaptive liquidation:", midnight.lossFactor(marketId));
        console2.log("    withdrawable after adaptive liquidation:", midnight.withdrawable(marketId));
        console2.log("    expected withdrawable:", controlWithdrawable);

        assertEq(
            midnight.debtOf(marketId, borrower),
            0,
            "adaptive liquidation repays current debt"
        );
        console2.log("    OK: adaptive liquidation repays current borrower debt");

        assertEq(
            midnight.lossFactor(marketId),
            0,
            "tiny repayment does not create bad debt"
        );
        console2.log("    OK: tiny repayment does not create bad debt");

        assertEq(
            midnight.withdrawable(marketId),
            controlWithdrawable,
            "adaptive retry restores equivalent recovery"
        );
        console2.log("    OK: adaptive retry restores equivalent withdrawable recovery");

        console2.log("[11] Lender withdraws recovered claim");
        uint256 lenderBefore = loanToken.balanceOf(lender);
        console2.log("    lender loanToken balance before:", lenderBefore);

        vm.prank(lender);
        midnight.withdraw(market, UNITS, lender, lender);

        uint256 lenderAfter = loanToken.balanceOf(lender);
        console2.log("    lender loanToken balance after:", lenderAfter);
        console2.log("    lender balance delta:", lenderAfter - lenderBefore);

        assertEq(
            lenderAfter,
            lenderBefore + UNITS,
            "lender can withdraw the full recovered claim"
        );
        console2.log("    OK: lender can withdraw the full recovered claim");

        console2.log("[12] RESULT");
        console2.log("    Tiny borrower repayment invalidates stale exact liquidation.");
        console2.log("    Adaptive liquidation using current debt succeeds.");
        console2.log("    No bad debt is created.");
        console2.log("    Lender recovery remains equivalent to control.");
        console2.log("======================================================================");
        console2.log("");
    }

    function testHist_TinyRepayDoesNotIncreaseBadDebtUnderIdenticalLowerPrice() public {
        console2.log("");
        console2.log("======================================================================");
        console2.log("PoC 2: Tiny repayment does not increase bad debt at same lower price");
        console2.log("======================================================================");

        console2.log("[1] Opening borrower debt");
        console2.log("    target debt units:", UNITS);
        _openBorrowerDebt(UNITS);

        uint256 totalUnitsBefore = midnight.totalUnits(marketId);

        console2.log("    borrower debt:", midnight.debtOf(marketId, borrower));
        console2.log("    totalUnitsBefore:", totalUnitsBefore);
        console2.log("    initial lossFactor:", midnight.lossFactor(marketId));
        console2.log("    initial lender credit:", midnight.creditOf(marketId, lender));

        console2.log("[2] Taking snapshot before lower-price control liquidation");
        uint256 snapshot = vm.snapshotState();
        console2.log("    snapshot id:", snapshot);

        console2.log("[3] Control path: lower oracle price and realize bad debt");
        console2.log("    original oracle price scale:", ORACLE_PRICE_SCALE);
        console2.log("    new oracle price:", ORACLE_PRICE_SCALE / 2);

        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 2);

        console2.log("    borrower debt before control bad-debt liquidation:", midnight.debtOf(marketId, borrower));

        midnight.liquidate(
            market,
            0,
            0,
            0,
            borrower,
            false,
            address(0),
            address(0),
            hex""
        );

        uint256 controlSlash = totalUnitsBefore - midnight.totalUnits(marketId);

        console2.log("    totalUnits after control liquidation:", midnight.totalUnits(marketId));
        console2.log("    controlSlash:", controlSlash);
        console2.log("    control lossFactor:", midnight.lossFactor(marketId));

        console2.log("[4] Updating lender position after control liquidation");
        midnight.updatePosition(market, lender);
        uint256 controlLenderCredit = midnight.creditOf(marketId, lender);

        console2.log("    control lender credit:", controlLenderCredit);

        console2.log("[5] Reverting to snapshot");
        vm.revertToState(snapshot);

        console2.log("    borrower debt after revert:", midnight.debtOf(marketId, borrower));
        console2.log("    totalUnits after revert:", midnight.totalUnits(marketId));
        console2.log("    lossFactor after revert:", midnight.lossFactor(marketId));

        console2.log("[6] Adversarial path: borrower repays one wei first");
        console2.log("    borrower debt before tiny repay:", midnight.debtOf(marketId, borrower));

        vm.prank(borrower);
        midnight.repay(market, 1, borrower, address(0), hex"");

        console2.log("    borrower debt after tiny repay:", midnight.debtOf(marketId, borrower));
        console2.log("    withdrawable after tiny repay:", midnight.withdrawable(marketId));

        console2.log("[7] Apply identical lower oracle price");
        console2.log("    new oracle price:", ORACLE_PRICE_SCALE / 2);

        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 2);

        console2.log("[8] Adversarial path: realize bad debt under same price");
        midnight.liquidate(
            market,
            0,
            0,
            0,
            borrower,
            false,
            address(0),
            address(0),
            hex""
        );

        uint256 adversarialSlash = totalUnitsBefore - midnight.totalUnits(marketId);

        console2.log("    totalUnits after adversarial liquidation:", midnight.totalUnits(marketId));
        console2.log("    adversarialSlash:", adversarialSlash);
        console2.log("    adversarial lossFactor:", midnight.lossFactor(marketId));

        console2.log("[9] Updating lender position after adversarial liquidation");
        midnight.updatePosition(market, lender);
        uint256 adversarialLenderCredit = midnight.creditOf(marketId, lender);

        console2.log("    adversarial lender credit:", adversarialLenderCredit);

        console2.log("[10] Comparing control vs adversarial results");
        console2.log("    controlSlash:", controlSlash);
        console2.log("    adversarialSlash:", adversarialSlash);
        console2.log("    controlLenderCredit:", controlLenderCredit);
        console2.log("    adversarialLenderCredit:", adversarialLenderCredit);

        assertGt(
            controlSlash,
            0,
            "control realizes non-dust bad debt"
        );
        console2.log("    OK: control realizes non-dust bad debt");

        assertLe(
            adversarialSlash,
            controlSlash,
            "tiny repayment cannot increase socialized loss"
        );
        console2.log("    OK: tiny repayment does not increase socialized loss");

        assertGe(
            adversarialLenderCredit,
            controlLenderCredit,
            "tiny repayment cannot worsen lender recovery"
        );
        console2.log("    OK: tiny repayment does not worsen lender recovery");

        console2.log("[11] RESULT");
        console2.log("    Under the identical lower oracle price:");
        console2.log("    Tiny repayment does not increase bad debt.");
        console2.log("    Tiny repayment does not reduce lender credit.");
        console2.log("======================================================================");
        console2.log("");
    }

    function testHist_UnauthorizedThirdPartyCannotDustRepayBorrower() public {
        console2.log("");
        console2.log("======================================================================");
        console2.log("PoC 3: Unauthorized third party cannot dust-repay borrower");
        console2.log("======================================================================");

        console2.log("[1] Opening borrower debt");
        console2.log("    target debt units:", UNITS);
        _openBorrowerDebt(UNITS);

        console2.log("    borrower:", borrower);
        console2.log("    attacker:", ATTACKER);
        console2.log("    borrower debt:", midnight.debtOf(marketId, borrower));

        console2.log("[2] Funding attacker with one loan-token unit");
        _fundLoanToken(ATTACKER, 1);

        console2.log("    attacker loanToken balance:", loanToken.balanceOf(ATTACKER));

        console2.log("[3] Attacker attempts to repay one wei on behalf of borrower");
        console2.log("    expected behavior: IMidnight.Unauthorized revert");

        vm.prank(ATTACKER);
        vm.expectRevert(IMidnight.Unauthorized.selector);
        midnight.repay(market, 1, borrower, address(0), hex"");

        console2.log("    OK: unauthorized third-party repay reverted");

        console2.log("[4] Validating borrower debt unchanged");
        console2.log("    borrower debt after failed attacker repay:", midnight.debtOf(marketId, borrower));

        assertEq(
            midnight.debtOf(marketId, borrower),
            UNITS,
            "unauthorized third party cannot mutate borrower debt"
        );

        console2.log("    OK: unauthorized third party cannot mutate borrower debt");

        console2.log("[5] RESULT");
        console2.log("    Only borrower or authorized operator can perform the dust repayment.");
        console2.log("======================================================================");
        console2.log("");
    }
}