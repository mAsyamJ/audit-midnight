// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {IMidnight} from "../../../src/interfaces/IMidnight.sol";
import {ReentrantSellCallback} from "../mocks/ReentrantCallback.sol";

/// @dev AP-026 — sell-callback composition (liquidation lock + flash) must not break take or profit attacker.
contract PoCSellCallbackCompositionTest is Config {
    function testPoC_LiquidationBlockedDuringSellCallback() public {
        ReentrantSellCallback callback = new ReentrantSellCallback();
        callback.configure(midnight, borrower);

        vm.prank(borrower);
        midnight.setIsAuthorized(address(callback), true, borrower);

        uint256 units = 50e18;
        collateralize(market, borrower, units);

        Offer memory sellOffer = _basicSellOffer(borrower, market);
        sellOffer.maxUnits = units;
        sellOffer.callback = address(callback);

        _fundLoanToken(lender, units);
        uint256 attackerBefore = loanToken.balanceOf(ATTACKER);

        vm.prank(lender);
        midnight.take(sellOffer, hex"", units, lender, borrower, address(0), hex"");

        assertTrue(callback.reentered(), "sell callback ran");
        assertTrue(callback.attemptedLiquidate(), "probed liquidate during lock");
        assertEq(loanToken.balanceOf(ATTACKER), attackerBefore, "no attacker profit");
        _assertMarketAccounting(marketId);
    }

    function testPoC_PostMaturitySellCannotIncreaseDebt() public {
        _warpAfterMaturity(market);

        Offer memory sellOffer = _basicSellOffer(borrower, market);
        sellOffer.maxUnits = 10e18;
        collateralize(market, borrower, 10e18);
        _fundLoanToken(lender, 10e18);

        vm.prank(lender);
        vm.expectRevert(IMidnight.CannotIncreaseDebtPostMaturity.selector);
        midnight.take(sellOffer, hex"", 10e18, lender, borrower, address(0), hex"");
    }
}
