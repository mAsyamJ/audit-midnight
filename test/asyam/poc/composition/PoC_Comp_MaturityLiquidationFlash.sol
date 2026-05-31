// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Market, CollateralParams, Offer} from "../../../../src/interfaces/IMidnight.sol";
import {MaturityLiquidationFlashAttacker} from "../../mocks/MaturityLiquidationFlashAttacker.sol";
import {TIME_TO_MAX_LIF} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev COMP-004 / COMP-014 / COMP-024 — temporary balances may fund unwind, but cannot create excess extraction.
contract PoCCompMaturityLiquidationFlashTest is Config {
    function testComp_SameTokenFlashLiquidationProfitIsOnlyLiquidationIncentive() public {
        uint256 debtUnits = 100e18;
        uint256 repayUnits = 20e18;
        Market memory sameTokenMarket = _sameTokenMarket();
        bytes32 id = _touchMarket(sameTokenMarket);
        _openDebt(sameTokenMarket, debtUnits);
        vm.warp(sameTokenMarket.maturity + TIME_TO_MAX_LIF);

        MaturityLiquidationFlashAttacker callback = new MaturityLiquidationFlashAttacker(midnight, ATTACKER);
        callback.configure(sameTokenMarket, borrower, repayUnits);

        uint256 midnightBefore = loanToken.balanceOf(address(midnight));
        uint256 attackerBefore = loanToken.balanceOf(ATTACKER);
        callback.executeFlashLiquidation(repayUnits);

        uint256 seized = callback.lastSeized();
        uint256 repaid = callback.lastRepaid();
        uint256 profit = loanToken.balanceOf(ATTACKER) - attackerBefore;

        assertTrue(callback.enteredFlash(), "flash callback entered");
        assertTrue(callback.enteredLiquidation(), "liquidation callback entered");
        assertEq(repaid, repayUnits, "outer liquidation repayment exact");
        assertEq(profit, seized - repaid, "profit is exactly disclosed liquidation incentive");
        assertEq(
            loanToken.balanceOf(address(midnight)),
            midnightBefore - seized + repaid,
            "flash principal is restored; only liquidation net flow remains"
        );
        assertEq(loanToken.balanceOf(address(callback)), 0, "callback retains no temporary balance");
        assertEq(midnight.debtOf(id, borrower), debtUnits - repaid, "borrower debt decreases once");
        _assertMarketAccounting(id);
    }

    function testComp_LiquidationPrecreditCannotExternalizeAuthorizedLenderClaimBeforePull() public {
        uint256 debtUnits = 100e18;
        uint256 repayUnits = 20e18;
        _openBorrowerDebt(debtUnits);
        vm.warp(market.maturity + TIME_TO_MAX_LIF);

        MaturityLiquidationFlashAttacker callback = new MaturityLiquidationFlashAttacker(midnight, ATTACKER);
        callback.configure(market, borrower, repayUnits);
        callback.configureWithdrawDuringLiquidation(lender, repayUnits, true);

        vm.prank(lender);
        midnight.setIsAuthorized(address(callback), true, lender);

        uint256 lenderCreditBefore = midnight.creditOf(marketId, lender);
        uint256 borrowerDebtBefore = midnight.debtOf(marketId, borrower);
        vm.expectRevert();
        callback.executeCallbackFundedLiquidation(ATTACKER);

        assertEq(
            midnight.creditOf(marketId, lender),
            lenderCreditBefore,
            "authorized claim cannot externalize absent custody"
        );
        assertEq(midnight.debtOf(marketId, borrower), borrowerDebtBefore, "outer liquidation rolls back");
        assertEq(midnight.withdrawable(marketId), 0, "precredited withdrawable rolls back");
    }

    function testComp_LiquidationPrecreditCannotConsumeUnauthorizedLenderClaim() public {
        uint256 debtUnits = 100e18;
        uint256 repayUnits = 20e18;
        _openBorrowerDebt(debtUnits);
        vm.warp(market.maturity + TIME_TO_MAX_LIF);

        MaturityLiquidationFlashAttacker callback = new MaturityLiquidationFlashAttacker(midnight, ATTACKER);
        callback.configure(market, borrower, repayUnits);
        callback.configureWithdrawDuringLiquidation(lender, repayUnits, true);

        uint256 lenderCreditBefore = midnight.creditOf(marketId, lender);
        uint256 borrowerDebtBefore = midnight.debtOf(marketId, borrower);
        vm.expectRevert();
        callback.executeCallbackFundedLiquidation(ATTACKER);

        assertEq(midnight.creditOf(marketId, lender), lenderCreditBefore, "unauthorized lender credit unchanged");
        assertEq(midnight.debtOf(marketId, borrower), borrowerDebtBefore, "outer liquidation rolls back");
        assertEq(midnight.withdrawable(marketId), 0, "precredited withdrawable rolls back");
    }

    function _sameTokenMarket() internal view returns (Market memory sameTokenMarket) {
        CollateralParams[] memory params = new CollateralParams[](1);
        params[0] = CollateralParams({
            token: address(loanToken),
            lltv: market.collateralParams[0].lltv,
            maxLif: market.collateralParams[0].maxLif,
            oracle: market.collateralParams[0].oracle
        });
        sameTokenMarket = Market({
            loanToken: address(loanToken),
            collateralParams: params,
            maturity: block.timestamp + 1 days,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(0)
        });
    }

    function _openDebt(Market memory debtMarket, uint256 units) internal {
        collateralize(debtMarket, borrower, units);
        Offer memory offer = _basicSellOffer(borrower, debtMarket);
        offer.maxUnits = units;
        vm.prank(lender);
        midnight.take(offer, hex"", units, lender, borrower, address(0), hex"");
    }
}
