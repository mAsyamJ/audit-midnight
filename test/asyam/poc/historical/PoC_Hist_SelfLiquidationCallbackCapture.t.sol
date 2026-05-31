// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {SelfLiquidationCallbackAttacker} from "../../mocks/SelfLiquidationCallbackAttacker.sol";
import {Market, Offer} from "../../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../../helpers/Oracle.sol";
import {UtilsLib} from "../../../../src/libraries/UtilsLib.sol";
import {ORACLE_PRICE_SCALE} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev HPH-POC-003 — borrower-controlled liquidation callbacks must not externalize avoidable lender loss.
contract PoCHistSelfLiquidationCallbackCaptureTest is Config {
    using UtilsLib for uint256;

    uint256 internal constant UNITS = 100e18;
    uint256 internal constant LIQUIDATION_PRICE = ORACLE_PRICE_SCALE * 9 / 10;
    uint256 internal constant BAD_DEBT_PRICE = ORACLE_PRICE_SCALE / 2;

    function testHist_SelfLiquidatorRecycleCannotCreateImmediateProfit() public {
        _openBorrowerDebt(UNITS);
        Oracle(market.collateralParams[0].oracle).setPrice(LIQUIDATION_PRICE);

        uint256 repayUnits = 10e18;
        uint256 collateralBefore = midnight.collateral(marketId, borrower, 0);
        uint256 debtBefore = midnight.debtOf(marketId, borrower);
        uint256 totalUnitsBefore = midnight.totalUnits(marketId);
        SelfLiquidationCallbackAttacker callback = _newCallback();
        _fundCallback(callback, repayUnits);

        callback.configure(market, borrower, repayUnits, false, true, 0, _emptyOffer(), 0);
        callback.executeSelfLiquidation();

        assertTrue(callback.enteredCallback(), "liquidation callback entered");
        assertGt(callback.lastSeizedAssets(), repayUnits, "ordinary liquidation exposes a bounded incentive");
        assertEq(callback.lastBadDebt(), 0, "recoverable position realizes no bad debt");
        assertEq(midnight.collateral(marketId, borrower, 0), collateralBefore, "recycled collateral is re-posted");
        assertEq(midnight.debtOf(marketId, borrower), debtBefore - repayUnits, "outer liquidation repays debt");
        assertEq(collateralToken1.balanceOf(address(callback)), 0, "recycling leaves no retained collateral");
        assertEq(loanToken.balanceOf(address(callback)), 0, "outer pull is fully funded");
        assertEq(midnight.withdrawable(marketId), repayUnits, "lender claim matches real repayment");
        assertEq(midnight.totalUnits(marketId), totalUnitsBefore, "liquidation does not mint units");
        assertEq(midnight.lossFactor(marketId), 0, "recoverable liquidation does not socialize loss");
        assertTrue(midnight.isHealthy(market, marketId, borrower), "repaid borrower is healthy");
    }

    function testHist_CallbackCanRepayAndRecycleOnlyWithFullyBackedFunds() public {
        _openBorrowerDebt(UNITS);
        Oracle(market.collateralParams[0].oracle).setPrice(LIQUIDATION_PRICE);

        uint256 outerRepay = 10e18;
        uint256 nestedRepay = 5e18;
        uint256 collateralBefore = midnight.collateral(marketId, borrower, 0);
        uint256 totalUnitsBefore = midnight.totalUnits(marketId);
        SelfLiquidationCallbackAttacker callback = _newCallback();
        _fundCallback(callback, outerRepay + nestedRepay);

        callback.configure(market, borrower, outerRepay, false, true, nestedRepay, _emptyOffer(), 0);
        callback.executeSelfLiquidation();

        assertTrue(callback.nestedRepayExecuted(), "nested repay executed");
        assertEq(midnight.debtOf(marketId, borrower), UNITS - outerRepay - nestedRepay, "both repayments reduce debt");
        assertEq(midnight.collateral(marketId, borrower, 0), collateralBefore, "seized collateral is posted once");
        assertEq(midnight.withdrawable(marketId), outerRepay + nestedRepay, "claims equal funded repayments");
        assertEq(loanToken.balanceOf(address(midnight)), outerRepay + nestedRepay, "custody backs lender claims");
        assertEq(loanToken.balanceOf(address(callback)), 0, "nested and outer pulls consume supplied funds");
        assertEq(collateralToken1.balanceOf(address(callback)), 0, "callback cannot double-use recycled collateral");
        assertEq(midnight.totalUnits(marketId), totalUnitsBefore, "repayment does not mint units");
        assertEq(midnight.lossFactor(marketId), 0, "nested repayment does not socialize loss");
    }

    function testHist_CallbackCanOpenReplacementDebtOnlyAgainstRealPaymentAndHealthyCollateral() public {
        _openBorrowerDebt(UNITS);
        Oracle(market.collateralParams[0].oracle).setPrice(LIQUIDATION_PRICE);

        uint256 outerRepay = 20e18;
        uint256 replacementUnits = 5e18;
        uint256 borrowerLoanBefore = loanToken.balanceOf(borrower);
        uint256 collateralBefore = midnight.collateral(marketId, borrower, 0);
        uint256 totalUnitsBefore = midnight.totalUnits(marketId);
        Offer memory replacementOffer = _basicSellOffer(borrower, market);
        replacementOffer.group = keccak256("self-liquidation-replacement-debt");
        replacementOffer.maxUnits = replacementUnits;
        SelfLiquidationCallbackAttacker callback = _newCallback();
        _fundCallback(callback, outerRepay + replacementUnits);

        callback.configure(market, borrower, outerRepay, false, true, 0, replacementOffer, replacementUnits);
        callback.executeSelfLiquidation();

        assertTrue(callback.replacementTakeExecuted(), "replacement take executed");
        assertEq(midnight.debtOf(marketId, borrower), UNITS - outerRepay + replacementUnits, "new debt is explicit");
        assertEq(midnight.creditOf(marketId, address(callback)), replacementUnits, "callback receives lender credit");
        assertEq(loanToken.balanceOf(borrower), borrowerLoanBefore + replacementUnits, "borrower receives real assets");
        assertEq(midnight.collateral(marketId, borrower, 0), collateralBefore, "collateral recycle is single-use");
        assertEq(midnight.withdrawable(marketId), outerRepay, "outer liquidation claim is backed");
        assertEq(loanToken.balanceOf(address(midnight)), outerRepay, "custody backs withdrawable claim");
        assertEq(loanToken.balanceOf(address(callback)), 0, "replacement and liquidation payments were pulled");
        assertEq(collateralToken1.balanceOf(address(callback)), 0, "callback retains no recycled collateral");
        assertEq(midnight.totalUnits(marketId), totalUnitsBefore + replacementUnits, "new credit expands units once");
        assertEq(midnight.lossFactor(marketId), 0, "replacement exposure creates no socialized loss");
        assertTrue(midnight.isHealthy(market, marketId, borrower), "replacement exposure remains collateralized");
    }

    function testHist_SelfLiquidationCannotAmplifyIndependentBadDebtSocialization() public {
        _openBorrowerDebt(UNITS);
        Oracle(market.collateralParams[0].oracle).setPrice(BAD_DEBT_PRICE);
        uint256 snapshot = vm.snapshotState();

        midnight.liquidate(market, 0, 0, 0, borrower, false, address(0), address(0), hex"");
        midnight.updatePosition(market, lender);
        uint256 controlLossFactor = midnight.lossFactor(marketId);
        uint256 controlTotalUnits = midnight.totalUnits(marketId);
        uint256 controlLenderCredit = midnight.creditOf(marketId, lender);
        vm.revertToState(snapshot);

        uint256 repayUnits = 10e18;
        SelfLiquidationCallbackAttacker callback = _newCallback();
        _fundCallback(callback, repayUnits);
        callback.configure(market, borrower, repayUnits, false, false, 0, _emptyOffer(), 0);
        callback.executeSelfLiquidation();
        midnight.updatePosition(market, lender);

        uint256 seizedValue = callback.lastSeizedAssets().mulDivDown(BAD_DEBT_PRICE, ORACLE_PRICE_SCALE);
        assertGt(callback.lastBadDebt(), 0, "price move creates independently realizable bad debt");
        assertEq(midnight.lossFactor(marketId), controlLossFactor, "callback cannot amplify loss factor");
        assertEq(midnight.totalUnits(marketId), controlTotalUnits, "callback cannot amplify unit slash");
        assertEq(midnight.creditOf(marketId, lender), controlLenderCredit, "callback cannot worsen lender slash");
        assertGt(seizedValue, repayUnits, "self-liquidator may receive disclosed incentive");
        assertLe(
            seizedValue,
            repayUnits.mulDivUp(market.collateralParams[0].maxLif, 1e18),
            "self-liquidator incentive remains bounded by LIF"
        );
        assertEq(loanToken.balanceOf(address(callback)), 0, "outer repayment is actually paid");
    }

    function testHist_CallbackObservationDoesNotEnablePostLiquidationClaimExtraction() public {
        _openBorrowerDebt(UNITS);
        Oracle(market.collateralParams[0].oracle).setPrice(LIQUIDATION_PRICE);

        uint256 repayUnits = 10e18;
        uint256 collateralBefore = midnight.collateral(marketId, borrower, 0);
        SelfLiquidationCallbackAttacker callback = _newCallback();
        _fundCallback(callback, repayUnits);
        callback.configure(market, borrower, repayUnits, false, false, 0, _emptyOffer(), 0);
        callback.executeSelfLiquidation();

        assertEq(callback.observedWithdrawable(), repayUnits, "callback observes pre-pull lender claim");
        assertEq(callback.observedTotalUnits(), UNITS, "callback observes unchanged total units");
        assertEq(callback.observedDebt(), UNITS - repayUnits, "callback observes debited borrower debt");
        assertEq(loanToken.balanceOf(address(midnight)), repayUnits, "outer settlement backs observed claim");

        vm.prank(lender);
        midnight.withdraw(market, repayUnits, lender, lender);
        assertEq(midnight.withdrawable(marketId), 0, "lender consumes only settled claim");
        assertEq(loanToken.balanceOf(address(midnight)), 0, "no stale loan-token custody remains");

        vm.prank(borrower);
        midnight.repay(market, UNITS - repayUnits, borrower, address(0), hex"");
        vm.prank(lender);
        midnight.withdraw(market, UNITS - repayUnits, lender, lender);

        assertEq(midnight.debtOf(marketId, borrower), 0, "borrower fully repays residual debt");
        assertEq(midnight.withdrawable(marketId), 0, "all claims settle exactly once");
        assertEq(midnight.totalUnits(marketId), 0, "all lender units exit");
        assertEq(loanToken.balanceOf(address(midnight)), 0, "no post-liquidation extraction deficit");
        assertEq(
            midnight.collateral(marketId, borrower, 0) + collateralToken1.balanceOf(address(callback)),
            collateralBefore,
            "seized and remaining collateral reconcile"
        );
    }

    function _newCallback() internal returns (SelfLiquidationCallbackAttacker callback) {
        callback = new SelfLiquidationCallbackAttacker(midnight);
        vm.prank(borrower);
        midnight.setIsAuthorized(address(callback), true, borrower);
    }

    function _fundCallback(SelfLiquidationCallbackAttacker callback, uint256 amount) internal {
        deal(address(loanToken), address(callback), amount);
    }

    function _emptyOffer() internal pure returns (Offer memory offer) {}
}
