// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {FlashLoanReentrantAttacker} from "../mocks/FlashLoanReentrantAttacker.sol";

/// @dev AP-019 / MC-04 — flash loan callback composition must not steal Midnight loan tokens or break accounting.
contract PoCFlashLoanReentrancyTest is Config {
    function testPoC_FlashLoanReentrancyIntoTakeDoesNotProfitAttacker() public {
        FlashLoanReentrantAttacker attackerContract = new FlashLoanReentrantAttacker();
        attackerContract.configure(midnight, ATTACKER, lender);

        uint256 flashAmount = 100e18;
        deal(address(loanToken), address(midnight), flashAmount);

        Offer memory offer = _basicBuyOffer(lender, market);
        offer.maxUnits = 50;
        attackerContract.setNestedTake(offer, hex"", 50, borrower);

        uint256 midnightBefore = loanToken.balanceOf(address(midnight));
        uint256 attackerBefore = loanToken.balanceOf(ATTACKER);

        address[] memory tokens = _singleToken();
        uint256[] memory amounts = _singleAmount(flashAmount);
        bytes memory data = hex"01";

        vm.prank(ATTACKER);
        midnight.flashLoan(tokens, amounts, address(attackerContract), data);

        assertTrue(attackerContract.reenteredTake(), "should attempt nested take");
        assertEq(attackerContract.stolen(), 0, "no steal via nested take");
        assertEq(loanToken.balanceOf(ATTACKER), attackerBefore, "attacker balance unchanged");
        assertEq(loanToken.balanceOf(address(midnight)), midnightBefore, "midnight custody restored");
    }

    function testPoC_FlashLoanRepayCallbackWithdrawDoesNotProfitAttacker() public {
        uint256 debtUnits = 80e18;
        _openBorrowerDebt(debtUnits);

        FlashLoanReentrantAttacker attackerContract = new FlashLoanReentrantAttacker();
        attackerContract.configure(midnight, ATTACKER, lender);

        uint256 flashAmount = 40e18;
        uint256 repayAmount = 20e18;
        uint256 lenderWithdrawProbe = 10e18;
        deal(address(loanToken), address(midnight), flashAmount);

        attackerContract.setNestedRepay(marketId, market, repayAmount, borrower, lenderWithdrawProbe);
        deal(address(loanToken), address(attackerContract), repayAmount);

        vm.prank(borrower);
        midnight.setIsAuthorized(address(attackerContract), true, borrower);

        uint256 midnightBefore = loanToken.balanceOf(address(midnight));
        uint256 attackerBefore = loanToken.balanceOf(ATTACKER);
        uint256 withdrawableBefore = midnight.withdrawable(marketId);

        address[] memory tokens = _singleToken();
        uint256[] memory amounts = _singleAmount(flashAmount);
        bytes memory data = hex"02";

        vm.prank(ATTACKER);
        midnight.flashLoan(tokens, amounts, address(attackerContract), data);

        assertTrue(attackerContract.reenteredRepayWithdraw(), "should run repay with callback");
        assertEq(attackerContract.stolen(), 0, "no profit from repay/withdraw reentry");
        assertEq(loanToken.balanceOf(ATTACKER), attackerBefore, "attacker unchanged");
        assertEq(
            loanToken.balanceOf(address(midnight)),
            midnightBefore + repayAmount,
            "repay during flash increases custody by payer-funded units"
        );
        assertGe(midnight.withdrawable(marketId), withdrawableBefore, "withdrawable may increase only with repayment");
        _assertMarketAccounting(marketId);
    }

    function testPoC_FlashLoanNotReimbursedReverts() public {
        deal(address(loanToken), address(midnight), 50e18);

        address[] memory tokens = _singleToken();
        uint256[] memory amounts = _singleAmount(50e18);

        vm.expectRevert();
        midnight.flashLoan(tokens, amounts, ATTACKER, hex"");
    }

    function _singleToken() internal view returns (address[] memory tokens) {
        tokens = new address[](1);
        tokens[0] = address(loanToken);
    }

    function _singleAmount(uint256 amount) internal pure returns (uint256[] memory amounts) {
        amounts = new uint256[](1);
        amounts[0] = amount;
    }
}
