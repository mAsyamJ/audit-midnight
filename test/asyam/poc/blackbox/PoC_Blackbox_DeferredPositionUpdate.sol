// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Offer} from "../../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../../helpers/Oracle.sol";
import {ORACLE_PRICE_SCALE} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev BB-POC-001 — a first touch must apply lazy loss before a lender can withdraw.
contract PoCBlackboxDeferredPositionUpdateTest is Config {
    uint256 internal constant UNITS = 100e18;

    function testBlackbox_StoredCreditCannotBeWithdrawnBeforeLazyLossIsApplied() public {
        _fundLoanToken(otherLender, UNITS);
        _openBorrowerDebt(UNITS);
        _openOtherBorrowerDebt(UNITS);

        vm.prank(borrower);
        midnight.repay(market, UNITS, borrower, address(0), hex"");

        Oracle(market.collateralParams[0].oracle).setPrice(ORACLE_PRICE_SCALE / 4);
        midnight.liquidate(market, 0, 0, 0, otherBorrower, false, address(0), address(0), hex"");

        uint256 storedCredit = midnight.creditOf(marketId, lender);
        (uint128 effectiveCredit,,) = midnight.updatePositionView(market, marketId, lender);
        assertGt(storedCredit, effectiveCredit, "lender remains stale before first touch");

        vm.prank(lender);
        vm.expectRevert();
        midnight.withdraw(market, storedCredit, lender, lender);

        uint256 lenderBefore = loanToken.balanceOf(lender);
        vm.prank(lender);
        midnight.withdraw(market, effectiveCredit, lender, lender);

        assertEq(loanToken.balanceOf(lender), lenderBefore + effectiveCredit, "effective claim exits exactly once");
        assertEq(midnight.creditOf(marketId, lender), 0, "lender credit fully exited");
        _assertMarketAccounting(marketId);
    }

    function _openOtherBorrowerDebt(uint256 units) internal {
        collateralize(market, otherBorrower, units);
        Offer memory offer = _basicSellOffer(otherBorrower, market);
        offer.maxUnits = units;
        vm.prank(otherLender);
        midnight.take(offer, hex"", units, otherLender, otherBorrower, address(0), hex"");
    }
}
