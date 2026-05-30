// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {ReentrantBuyCallback} from "../mocks/ReentrantCallback.sol";

/// @dev MIDNIGHT-CAND-025 — callback reentrancy into take during buy callback.
contract PoCTakeCallbackReentrancyTest is Config {
    function testPoC_NestedTakeDuringBuyCallbackDoesNotCorruptConsumedOrProfitAttacker() public {
        ReentrantBuyCallback reentrant = new ReentrantBuyCallback();
        reentrant.configure(midnight, midnightBundles, ATTACKER);

        vm.prank(lender);
        midnight.setIsAuthorized(address(reentrant), true, lender);
        vm.prank(lender);
        loanToken.approve(address(reentrant), type(uint256).max);

        bytes32 group = keccak256("reentry-group");
        uint256 firstUnits = 60;
        uint256 nestedUnits = 40;

        Offer memory lenderOffer = _basicBuyOffer(lender, market);
        lenderOffer.maxUnits = firstUnits + nestedUnits;
        lenderOffer.group = group;
        lenderOffer.callback = address(reentrant);

        Offer memory nestedOffer = _basicBuyOffer(lender, market);
        nestedOffer.maxUnits = nestedUnits;
        nestedOffer.group = group;

        reentrant.setNestedTake(nestedOffer, hex"", 0, borrower); // nested take disabled; callback-only reentry probe

        collateralize(market, borrower, firstUnits + nestedUnits);

        uint256 attackerBefore = loanToken.balanceOf(ATTACKER);
        uint256 totalUnitsBefore = midnight.totalUnits(marketId);

        vm.prank(borrower);
        midnight.take(lenderOffer, hex"", firstUnits, borrower, borrower, address(0), hex"");

        assertTrue(reentrant.reentered(), "buy callback should have attempted nested take");
        assertEq(reentrant.stolen(), 0, "attacker should not profit from nested take");
        assertEq(loanToken.balanceOf(ATTACKER), attackerBefore, "attacker balance unchanged");
        assertLe(midnight.consumed(lender, group), lenderOffer.maxUnits, "consumed cap respected");
        assertGe(midnight.totalUnits(marketId), totalUnitsBefore, "totalUnits monotonic");
        _assertMarketAccounting(marketId);
    }

    function testPoC_DoubleTakeSameGroupRevertsAfterPartialFill() public {
        bytes32 group = keccak256("double-fill");
        uint256 cap = 100;

        Offer memory offer = _basicBuyOffer(lender, market);
        offer.maxUnits = cap;
        offer.group = group;

        collateralize(market, borrower, cap);

        vm.startPrank(borrower);
        midnight.take(offer, hex"", 60, borrower, borrower, address(0), hex"");
        vm.expectRevert();
        midnight.take(offer, hex"", 50, borrower, borrower, address(0), hex"");
        vm.stopPrank();

        assertEq(midnight.consumed(lender, group), 60, "partial consumed");
    }
}
