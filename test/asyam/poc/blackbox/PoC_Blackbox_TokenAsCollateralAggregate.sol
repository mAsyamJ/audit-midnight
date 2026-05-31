// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Market, Offer, CollateralParams} from "../../../../src/interfaces/IMidnight.sol";
import {CBP, WAD} from "../../../../src/libraries/ConstantsLib.sol";

/// @dev BB-POC-019 — one ERC20 can simultaneously back collateral, withdrawable liquidity, and token-global fees.
contract PoCBlackboxTokenAsCollateralAggregateTest is Config {
    uint256 internal constant UNITS = 100e18;

    function testBlackbox_ClaimFeeThenExitSameTokenCollateralMarketRemainsBacked() public {
        (Market memory sameTokenMarket, bytes32 sameTokenId, uint256 collateral, uint256 fee) =
            _setupSameTokenCollateralAndFeeLiabilities();

        midnight.claimSettlementFee(address(loanToken), fee, REFERRAL);
        _assertAggregateBacking(sameTokenId);

        vm.prank(otherLender);
        midnight.withdraw(sameTokenMarket, UNITS, otherLender, otherLender);
        _assertAggregateBacking(sameTokenId);

        vm.prank(otherBorrower);
        midnight.withdrawCollateral(sameTokenMarket, 0, collateral, otherBorrower, otherBorrower);
        _assertAggregateBacking(sameTokenId);
    }

    function testBlackbox_ExitSameTokenCollateralMarketThenClaimFeeRemainsBacked() public {
        (Market memory sameTokenMarket, bytes32 sameTokenId, uint256 collateral, uint256 fee) =
            _setupSameTokenCollateralAndFeeLiabilities();

        vm.prank(otherBorrower);
        midnight.withdrawCollateral(sameTokenMarket, 0, collateral, otherBorrower, otherBorrower);
        _assertAggregateBacking(sameTokenId);

        vm.prank(otherLender);
        midnight.withdraw(sameTokenMarket, UNITS, otherLender, otherLender);
        _assertAggregateBacking(sameTokenId);

        midnight.claimSettlementFee(address(loanToken), fee, REFERRAL);
        _assertAggregateBacking(sameTokenId);
    }

    function _setupSameTokenCollateralAndFeeLiabilities()
        internal
        returns (Market memory sameTokenMarket, bytes32 sameTokenId, uint256 collateral, uint256 fee)
    {
        midnight.setFeeClaimer(address(this));
        midnight.setMarketSettlementFee(marketId, 0, 14 * CBP);
        midnight.setMarketSettlementFee(marketId, 1, 14 * CBP);
        _openBorrowerDebt(UNITS);
        fee = midnight.claimableSettlementFee(address(loanToken));
        assertGt(fee, 0, "market A accrues a token-global fee");

        sameTokenMarket = _sameTokenMarket();
        sameTokenId = _touchMarket(sameTokenMarket);
        collateral = UNITS * WAD / sameTokenMarket.collateralParams[0].lltv + 1;
        deal(address(loanToken), otherBorrower, collateral);
        vm.startPrank(otherBorrower);
        loanToken.approve(address(midnight), type(uint256).max);
        midnight.supplyCollateral(sameTokenMarket, 0, collateral, otherBorrower);
        vm.stopPrank();

        _fundLoanToken(otherLender, UNITS);
        Offer memory offer = _basicBuyOffer(otherLender, sameTokenMarket);
        offer.maxUnits = UNITS;
        vm.prank(otherBorrower);
        midnight.take(offer, hex"", UNITS, otherBorrower, otherBorrower, address(0), hex"");
        vm.prank(otherBorrower);
        midnight.repay(sameTokenMarket, UNITS, otherBorrower, address(0), hex"");

        assertEq(midnight.debtOf(sameTokenId, otherBorrower), 0, "same-token borrower debt repaid");
        assertEq(midnight.withdrawable(sameTokenId), UNITS, "same-token lender exit is backed");
        _assertAggregateBacking(sameTokenId);
    }

    function _sameTokenMarket() internal view returns (Market memory sameTokenMarket) {
        CollateralParams[] memory collateralParams = new CollateralParams[](1);
        collateralParams[0] = CollateralParams({
            token: address(loanToken), lltv: 0.77e18, maxLif: maxLif(0.77e18, 0.25e18), oracle: address(oracle1)
        });
        sameTokenMarket = Market({
            loanToken: address(loanToken),
            collateralParams: collateralParams,
            maturity: market.maturity + 1,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(0)
        });
    }

    function _assertAggregateBacking(bytes32 sameTokenId) internal view {
        assertGe(
            loanToken.balanceOf(address(midnight)),
            uint256(midnight.collateral(sameTokenId, otherBorrower, 0)) + uint256(midnight.withdrawable(marketId))
                + uint256(midnight.withdrawable(sameTokenId)) + midnight.claimableSettlementFee(address(loanToken)),
            "custody covers same-token collateral, local exits, and token-global fees"
        );
    }
}
