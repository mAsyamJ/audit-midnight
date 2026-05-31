// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Oracle} from "../../../helpers/Oracle.sol";
import {MAX_CONTINUOUS_FEE} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev COMP-003 / COMP-011 — repay cash, social loss, stale lender sync, fee claim, and withdraw stay backed.
contract PoCCompLossFactorWithdrawableFeeTest is Config {
    uint256 internal constant CREDIT = 100e18;
    uint256 internal constant REPAY_UNITS = 30e18;

    function testComp_ClaimThenWithdrawAfterSlashRemainsBacked() public {
        _setupRepaySlashAccrual();

        uint256 feeClaim = midnight.continuousFeeCredit(marketId);
        assertGt(feeClaim, 0, "fee accrued after stale lender update");
        assertLe(feeClaim, midnight.withdrawable(marketId), "fee claim must be cash backed");

        uint256 midnightBefore = loanToken.balanceOf(address(midnight));
        uint256 referralBefore = loanToken.balanceOf(REFERRAL);
        midnight.claimContinuousFee(market, feeClaim, REFERRAL);

        assertEq(loanToken.balanceOf(REFERRAL), referralBefore + feeClaim, "fee receiver paid");
        assertEq(loanToken.balanceOf(address(midnight)), midnightBefore - feeClaim, "fee transfer debits custody");

        _withdrawAllBackedLenderCredit();
        _assertCustodyCoversWithdrawable();
        _assertMarketAccounting(marketId);
    }

    function testComp_WithdrawThenClaimAfterSlashRemainsBacked() public {
        _setupRepaySlashAccrual();

        uint256 feeClaim = midnight.continuousFeeCredit(marketId);
        assertGt(feeClaim, 0, "fee accrued after stale lender update");

        _withdrawAllBackedLenderCredit();
        assertLe(feeClaim, midnight.withdrawable(marketId), "cash reserved for accrued fee remains withdrawable");

        midnight.claimContinuousFee(market, feeClaim, REFERRAL);

        assertLe(midnight.withdrawable(marketId), 1, "only bounded rounding dust remains");
        _assertCustodyCoversWithdrawable();
        _assertMarketAccounting(marketId);
    }

    function _setupRepaySlashAccrual() internal {
        market.maturity = block.timestamp + 90 days;
        midnight.setDefaultContinuousFee(address(loanToken), MAX_CONTINUOUS_FEE);
        marketId = _touchMarket(market);
        midnight.setFeeClaimer(address(this));

        _openBorrowerDebt(CREDIT);
        vm.warp(block.timestamp + 30 days);

        vm.prank(borrower);
        midnight.repay(market, REPAY_UNITS, borrower, address(0), hex"");
        assertEq(midnight.withdrawable(marketId), REPAY_UNITS, "partial repay creates backed cash");

        Oracle(market.collateralParams[0].oracle).setPrice(0);
        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");

        assertGt(midnight.lossFactor(marketId), 0, "remaining debt is socialized");
        assertEq(midnight.totalUnits(marketId), REPAY_UNITS, "only repaid cash units remain");

        midnight.updatePosition(market, lender);
        assertEq(midnight.lastLossFactor(marketId, lender), midnight.lossFactor(marketId), "stale lender synced");
        _assertCustodyCoversWithdrawable();
    }

    function _withdrawAllBackedLenderCredit() internal {
        uint256 lenderCredit = midnight.creditOf(marketId, lender);
        uint256 backed = midnight.withdrawable(marketId);
        uint256 amount = lenderCredit < backed ? lenderCredit : backed;
        if (amount > 0) {
            vm.prank(lender);
            midnight.withdraw(market, amount, lender, lender);
        }
    }

    function _assertCustodyCoversWithdrawable() internal view {
        assertGe(
            loanToken.balanceOf(address(midnight)),
            midnight.withdrawable(marketId),
            "loan-token custody must cover withdrawable"
        );
    }
}
