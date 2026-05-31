// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Market, Offer, CollateralParams} from "../../../../src/interfaces/IMidnight.sol";
import {CBP, WAD} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev INV-BB-001 — shared-token custody covers market-local exits, token-global fees, and token-as-collateral.
contract InvariantCrossMarketAggregateAccountingTest is Config {
    uint256 internal constant UNITS = 100e18;

    Market internal sameTokenMarket;
    bytes32 internal sameTokenId;
    uint256 internal sameTokenCollateral;
    uint256 internal settlementFeeClaim;

    function testFuzz_Invariant_AllExitOrderingsRemainAggregateBacked(uint256 seed) public {
        _setupAggregateLiabilities();

        uint8[4] memory actions = [uint8(0), uint8(1), uint8(2), uint8(3)];
        uint256 remaining = actions.length;
        while (remaining > 0) {
            uint256 index = seed % remaining;
            seed = uint256(keccak256(abi.encode(seed, remaining)));
            _execute(actions[index]);
            actions[index] = actions[remaining - 1];
            remaining--;
            _assertAggregateBacking();
        }

        assertEq(loanToken.balanceOf(address(midnight)), 0, "all shared-token liabilities fully exit");
    }

    function _setupAggregateLiabilities() internal {
        midnight.setFeeClaimer(address(this));
        midnight.setMarketSettlementFee(marketId, 0, 14 * CBP);
        midnight.setMarketSettlementFee(marketId, 1, 14 * CBP);
        _openBorrowerDebt(UNITS);
        vm.prank(borrower);
        midnight.repay(market, UNITS, borrower, address(0), hex"");
        settlementFeeClaim = midnight.claimableSettlementFee(address(loanToken));
        assertGt(settlementFeeClaim, 0, "market A accrues a token-global fee");

        sameTokenMarket = _sameTokenMarket();
        sameTokenId = _touchMarket(sameTokenMarket);
        sameTokenCollateral = UNITS * WAD / sameTokenMarket.collateralParams[0].lltv + 1;
        deal(address(loanToken), otherBorrower, sameTokenCollateral);
        vm.startPrank(otherBorrower);
        loanToken.approve(address(midnight), type(uint256).max);
        midnight.supplyCollateral(sameTokenMarket, 0, sameTokenCollateral, otherBorrower);
        vm.stopPrank();

        _fundLoanToken(otherLender, UNITS);
        Offer memory offer = _basicBuyOffer(otherLender, sameTokenMarket);
        offer.maxUnits = UNITS;
        vm.prank(otherBorrower);
        midnight.take(offer, hex"", UNITS, otherBorrower, otherBorrower, address(0), hex"");
        vm.prank(otherBorrower);
        midnight.repay(sameTokenMarket, UNITS, otherBorrower, address(0), hex"");

        _assertAggregateBacking();
    }

    function _execute(uint8 action) internal {
        if (action == 0) {
            vm.prank(lender);
            midnight.withdraw(market, UNITS, lender, lender);
        } else if (action == 1) {
            vm.prank(otherLender);
            midnight.withdraw(sameTokenMarket, UNITS, otherLender, otherLender);
        } else if (action == 2) {
            vm.prank(otherBorrower);
            midnight.withdrawCollateral(sameTokenMarket, 0, sameTokenCollateral, otherBorrower, otherBorrower);
        } else {
            midnight.claimSettlementFee(address(loanToken), settlementFeeClaim, REFERRAL);
        }
    }

    function _sameTokenMarket() internal view returns (Market memory sameTokenMarket_) {
        CollateralParams[] memory collateralParams = new CollateralParams[](1);
        collateralParams[0] = CollateralParams({
            token: address(loanToken), lltv: 0.77e18, maxLif: maxLif(0.77e18, 0.25e18), oracle: address(oracle1)
        });
        sameTokenMarket_ = Market({
            loanToken: address(loanToken),
            collateralParams: collateralParams,
            maturity: market.maturity + 1,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(0)
        });
    }

    function _assertAggregateBacking() internal view {
        assertGe(
            loanToken.balanceOf(address(midnight)),
            uint256(midnight.collateral(sameTokenId, otherBorrower, 0)) + uint256(midnight.withdrawable(marketId))
                + uint256(midnight.withdrawable(sameTokenId)) + midnight.claimableSettlementFee(address(loanToken)),
            "custody covers aggregate shared-token liabilities"
        );
    }
}
