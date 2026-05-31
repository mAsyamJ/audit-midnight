// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Offer} from "../../../../src/interfaces/IMidnight.sol";
import {Oracle} from "../../../helpers/Oracle.sol";

/// @dev COMP-013 / COMP-030 — lender fragmentation must not turn slash rounding dust into withdrawable extraction.
contract PoCCompDustDriftToNonDustLossTest is Config {
    uint256 internal constant EACH = 1e18;
    uint256 internal constant FRAGMENTED_LENDERS = 32;

    function testComp_SingleLenderSocialLossLeavesAtMostOneWeiDust() public {
        _runFragmentationScenario(1);
    }

    function testComp_FragmentedLendersSocialLossDustIsLinearAndNotExtractable() public {
        _runFragmentationScenario(FRAGMENTED_LENDERS);
    }

    function _runFragmentationScenario(uint256 lenderCount) internal {
        uint256 total = lenderCount * EACH;
        market.maturity = block.timestamp + 2 days;
        marketId = _touchMarket(market);

        collateralize(market, borrower, total);
        collateralize(market, otherBorrower, total);

        Offer memory repaidDebt = _basicSellOffer(borrower, market);
        repaidDebt.maxUnits = total;
        Offer memory defaultedDebt = _basicSellOffer(otherBorrower, market);
        defaultedDebt.maxUnits = total;

        for (uint256 i; i < lenderCount; i++) {
            address fragmentedLender = _fragmentedLender(i);
            _fundLoanToken(fragmentedLender, 2 * EACH);

            vm.prank(fragmentedLender);
            midnight.take(repaidDebt, hex"", EACH, fragmentedLender, borrower, address(0), hex"");
            vm.prank(fragmentedLender);
            midnight.take(defaultedDebt, hex"", EACH, fragmentedLender, otherBorrower, address(0), hex"");
        }

        vm.prank(borrower);
        midnight.repay(market, total, borrower, address(0), hex"");

        vm.warp(market.maturity + 1);
        Oracle(market.collateralParams[0].oracle).setPrice(0);
        midnight.liquidate(market, 0, 0, 0, otherBorrower, true, address(0), address(0), hex"");

        assertEq(midnight.totalUnits(marketId), total, "default removes half the market units");
        assertEq(midnight.withdrawable(marketId), total, "repaid cash remains available after slash");

        uint256 totalWithdrawn;
        for (uint256 i; i < lenderCount; i++) {
            address fragmentedLender = _fragmentedLender(i);
            midnight.updatePosition(market, fragmentedLender);
            uint256 claim = midnight.creditOf(marketId, fragmentedLender);
            assertApproxEqAbs(claim, EACH, 1, "each lender loses at most one wei to slash rounding");

            totalWithdrawn += claim;
            vm.prank(fragmentedLender);
            midnight.withdraw(market, claim, fragmentedLender, fragmentedLender);
        }

        uint256 residue = total - totalWithdrawn;
        assertEq(midnight.withdrawable(marketId), residue, "unclaimed cash equals lender rounding residue");
        assertEq(midnight.totalUnits(marketId), residue, "rounding residue cannot be externalized");
        assertLe(residue, lenderCount, "slash dust grows at most linearly by one wei per lender");
        assertGe(loanToken.balanceOf(address(midnight)), residue, "remaining residue stays custody backed");
        _assertMarketAccounting(marketId);
    }

    function _fragmentedLender(uint256 index) internal pure returns (address) {
        // forge-lint: disable-next-line(unsafe-typecast) bounded test index is at most FRAGMENTED_LENDERS - 1.
        return address(uint160(0x10000 + index));
    }
}
