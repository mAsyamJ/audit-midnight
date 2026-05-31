// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Market, Offer} from "../../../../src/interfaces/IMidnight.sol";
import {CrossMarketBuyCallback} from "../../mocks/CrossMarketBuyCallback.sol";

/// @dev COMP-007 / COMP-009 / COMP-018 — shared token custody must preserve market-local claims during nested use.
contract PoCCompCrossMarketSharedTokenTest is Config {
    function testComp_NestedWithdrawalRollsOnlyBackedClaimAcrossSharedTokenMarkets() public {
        uint256 units = 30e18;
        Market memory marketB = _secondSharedTokenMarket();
        bytes32 marketBId = _touchMarket(marketB);

        collateralize(marketB, otherBorrower, units);
        Offer memory debtOfferB = _basicSellOffer(otherBorrower, marketB);
        debtOfferB.maxUnits = units;
        vm.prank(lender);
        midnight.take(debtOfferB, hex"", units, lender, otherBorrower, address(0), hex"");
        vm.prank(otherBorrower);
        midnight.repay(marketB, units, otherBorrower, address(0), hex"");

        assertEq(midnight.creditOf(marketBId, lender), units, "market B lender claim exists");
        assertEq(midnight.withdrawable(marketBId), units, "market B repay cash is backed");

        CrossMarketBuyCallback callback = new CrossMarketBuyCallback(midnight);
        vm.prank(lender);
        midnight.setIsAuthorized(address(callback), true, lender);

        collateralize(market, borrower, units);
        Offer memory debtOfferA = _basicSellOffer(borrower, market);
        debtOfferA.maxUnits = units;
        callback.configure(marketB, lender, units, debtOfferA, units);

        uint256 borrowerBefore = loanToken.balanceOf(borrower);
        callback.execute();

        assertTrue(callback.entered(), "cross-market buy callback entered");
        assertEq(midnight.creditOf(marketBId, lender), 0, "market B lender exchanged its backed claim");
        assertEq(midnight.withdrawable(marketBId), 0, "market B cash was withdrawn once");
        assertEq(midnight.creditOf(marketId, address(callback)), units, "market A receives a new lender claim");
        assertEq(midnight.debtOf(marketId, borrower), units, "market A borrower debt created once");
        assertEq(loanToken.balanceOf(borrower), borrowerBefore + units, "market A borrower receives the rolled cash");
        assertEq(loanToken.balanceOf(address(callback)), 0, "callback retains no shared-token float");
        _assertAggregateCustody(marketBId);
    }

    function testComp_MarketACreditCannotWithdrawFromProductionDistinctMarketB() public {
        uint256 units = 11e18;
        Market memory marketB = _secondSharedTokenMarket();
        bytes32 marketBId = _touchMarket(marketB);

        _openBorrowerDebt(units);
        vm.prank(borrower);
        midnight.repay(market, units, borrower, address(0), hex"");

        vm.prank(lender);
        vm.expectRevert();
        midnight.withdraw(marketB, units, lender, lender);

        assertEq(midnight.creditOf(marketId, lender), units, "market A lender claim stays local");
        assertEq(midnight.withdrawable(marketId), units, "market A cash stays local");
        assertEq(midnight.creditOf(marketBId, lender), 0, "market B cannot consume market A credit");
        assertEq(midnight.withdrawable(marketBId), 0, "market B has no withdrawable cash");
        _assertAggregateCustody(marketBId);
    }

    function _secondSharedTokenMarket() internal view returns (Market memory marketB) {
        marketB = _defaultMarket();
        marketB.maturity += 1;
    }

    function _assertAggregateCustody(bytes32 marketBId) internal view {
        assertGe(
            loanToken.balanceOf(address(midnight)),
            uint256(midnight.withdrawable(marketId)) + uint256(midnight.withdrawable(marketBId)),
            "shared custody covers aggregate withdrawable"
        );
        _assertMarketAccounting(marketId);
        _assertMarketAccounting(marketBId);
    }
}
