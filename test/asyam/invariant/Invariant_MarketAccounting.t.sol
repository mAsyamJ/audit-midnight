// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";

contract InvariantMarketAccountingTest is Config {
    function testInvariant_TotalUnitsCoversWithdrawableAfterTakeRepay() public {
        uint256 units = 200;
        _openBorrowerDebt(units);

        assertGe(midnight.totalUnits(marketId), midnight.withdrawable(marketId));

        uint256 repayAmount = 50;
        vm.prank(borrower);
        midnight.repay(market, repayAmount, borrower, address(0), hex"");

        _assertMarketAccounting(marketId);
    }
}
