// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Offer} from "../../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../../helpers/Oracle.sol";

/// @dev COMP-008 / COMP-012 — post-maturity bad debt, backed repayment, stale lender sync, and withdrawal ordering.
contract PoCCompPostMaturityBadDebtWithdrawTest is Config {
    uint256 internal constant UNITS = 50e18;

    function testComp_RepayBeforePostMaturityBadDebtWithdrawalOrderLenderFirst() public {
        _setupRepayAndSocialLoss(true);
        _withdrawInOrder(lender, otherLender);
    }

    function testComp_PostMaturityBadDebtBeforeRepayWithdrawalOrderOtherLenderFirst() public {
        _setupRepayAndSocialLoss(false);
        _withdrawInOrder(otherLender, lender);
    }

    function _setupRepayAndSocialLoss(bool repayBeforeSocialLoss) internal {
        market.maturity = block.timestamp + 2 days;
        marketId = _touchMarket(market);
        _fundLoanToken(otherLender, UNITS);

        _openBorrowerDebt(UNITS);
        _openOtherBorrowerDebt(UNITS);

        if (repayBeforeSocialLoss) _repayBorrower();

        vm.warp(market.maturity + 1);
        Oracle(market.collateralParams[0].oracle).setPrice(0);
        midnight.liquidate(market, 0, 0, 0, otherBorrower, true, address(0), address(0), hex"");

        assertEq(midnight.debtOf(marketId, otherBorrower), 0, "second borrower's bad debt is realized");
        assertEq(midnight.totalUnits(marketId), UNITS, "social loss removes only the defaulted units");
        assertGt(midnight.lossFactor(marketId), 0, "bad debt updates lender loss factor");

        if (!repayBeforeSocialLoss) _repayBorrower();

        assertEq(midnight.withdrawable(marketId), UNITS, "repaid cash remains withdrawable after social loss");
        _assertCustodyCoversWithdrawable();
        _assertMarketAccounting(marketId);
    }

    function _openOtherBorrowerDebt(uint256 units) internal {
        collateralize(market, otherBorrower, units);
        Offer memory sellOffer = _basicSellOffer(otherBorrower, market);
        sellOffer.maxUnits = units;

        vm.prank(otherLender);
        midnight.take(sellOffer, hex"", units, otherLender, otherBorrower, address(0), hex"");
    }

    function _repayBorrower() internal {
        vm.prank(borrower);
        midnight.repay(market, UNITS, borrower, address(0), hex"");
        assertEq(midnight.debtOf(marketId, borrower), 0, "first borrower repays in full");
    }

    function _withdrawInOrder(address first, address second) internal {
        uint256 firstClaim = _syncAndWithdraw(first);
        _assertCustodyCoversWithdrawable();

        uint256 secondClaim = _syncAndWithdraw(second);
        _assertCustodyCoversWithdrawable();

        assertApproxEqAbs(firstClaim, UNITS / 2, 1, "first lender receives its socialized share");
        assertApproxEqAbs(secondClaim, UNITS / 2, 1, "second lender receives its socialized share");
        assertLe(midnight.withdrawable(marketId), 2, "only per-lender down-rounding dust remains");
        assertLe(midnight.totalUnits(marketId), 2, "withdrawal order cannot strand material total units");
        _assertMarketAccounting(marketId);
    }

    function _syncAndWithdraw(address account) internal returns (uint256 claim) {
        midnight.updatePosition(market, account);
        claim = midnight.creditOf(marketId, account);

        uint256 balanceBefore = loanToken.balanceOf(account);
        vm.prank(account);
        midnight.withdraw(market, claim, account, account);
        assertEq(loanToken.balanceOf(account), balanceBefore + claim, "withdraw pays the synced credit");
    }

    function _assertCustodyCoversWithdrawable() internal view {
        assertGe(
            loanToken.balanceOf(address(midnight)),
            midnight.withdrawable(marketId),
            "loan-token custody must cover withdrawable"
        );
    }
}
