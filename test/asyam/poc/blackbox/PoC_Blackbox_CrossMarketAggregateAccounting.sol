// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Market, Offer} from "../../../../src/interfaces/IMidnight.sol";
import {CBP} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev BB-POC-006 — token-global settlement fees and market-local withdrawable must remain aggregate-backed.
contract PoCBlackboxCrossMarketAggregateAccountingTest is Config {
    uint256 internal constant UNITS = 100e18;

    function testBlackbox_ClaimSettlementFeeThenWithdrawOtherMarketRemainsBacked() public {
        (Market memory marketB, bytes32 marketBId, uint256 fee) = _setupFeeAndRepaidMarket();
        _assertAggregateBacking(marketBId);

        midnight.claimSettlementFee(address(loanToken), fee, REFERRAL);
        _assertAggregateBacking(marketBId);

        vm.prank(otherLender);
        midnight.withdraw(marketB, UNITS, otherLender, otherLender);
        _assertAggregateBacking(marketBId);
    }

    function testBlackbox_WithdrawOtherMarketThenClaimSettlementFeeRemainsBacked() public {
        (Market memory marketB, bytes32 marketBId, uint256 fee) = _setupFeeAndRepaidMarket();

        vm.prank(otherLender);
        midnight.withdraw(marketB, UNITS, otherLender, otherLender);
        _assertAggregateBacking(marketBId);

        midnight.claimSettlementFee(address(loanToken), fee, REFERRAL);
        _assertAggregateBacking(marketBId);
    }

    function _setupFeeAndRepaidMarket() internal returns (Market memory marketB, bytes32 marketBId, uint256 fee) {
        midnight.setFeeClaimer(address(this));
        midnight.setMarketSettlementFee(marketId, 0, 14 * CBP);
        midnight.setMarketSettlementFee(marketId, 1, 14 * CBP);

        _openBorrowerDebt(UNITS);
        fee = midnight.claimableSettlementFee(address(loanToken));
        assertGt(fee, 0, "market A accrues a token-global fee");

        marketB = _defaultMarket();
        marketB.maturity += 1;
        marketBId = _touchMarket(marketB);
        _fundLoanToken(otherLender, UNITS);
        collateralize(marketB, otherBorrower, UNITS);

        Offer memory offer = _basicSellOffer(otherBorrower, marketB);
        offer.maxUnits = UNITS;
        vm.prank(otherLender);
        midnight.take(offer, hex"", UNITS, otherLender, otherBorrower, address(0), hex"");

        vm.prank(otherBorrower);
        midnight.repay(marketB, UNITS, otherBorrower, address(0), hex"");
        assertEq(midnight.withdrawable(marketBId), UNITS, "market B has a backed lender exit");
    }

    function _assertAggregateBacking(bytes32 marketBId) internal view {
        assertGe(
            loanToken.balanceOf(address(midnight)),
            uint256(midnight.withdrawable(marketId)) + uint256(midnight.withdrawable(marketBId))
                + midnight.claimableSettlementFee(address(loanToken)),
            "custody covers aggregate withdrawable and global settlement fee"
        );
    }
}
