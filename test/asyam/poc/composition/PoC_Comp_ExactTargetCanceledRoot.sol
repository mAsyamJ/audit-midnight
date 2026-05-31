// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {Offer} from "../../../../src/interfaces/IMidnight.sol";
import {
    Take,
    TokenPermit,
    PermitKind,
    CollateralWithdrawal
} from "../../../../src/periphery/interfaces/IMidnightBundles.sol";
import {HashLib} from "../../../../src/ratifiers/libraries/HashLib.sol";
import {Signature} from "../../../../src/ratifiers/interfaces/IEcrecoverRatifier.sol";
import {WAD} from "../../../../src/libraries/ConstantsLib.sol";
import {UtilsLib} from "../../../../src/libraries/UtilsLib.sol";

/// @dev COMP-002 — caught root failure plus inverse fill math and referral transfer must settle atomically.
contract PoCCompExactTargetCanceledRootTest is Config {
    using UtilsLib for uint256;

    function testComp_ExactAssetsFallbackAfterCanceledRootLeavesNoResidual() public {
        uint256 targetBuyerAssets = 10e18;
        uint256 referralFeePct = 0.1e18;
        uint256 referralFeeAssets = targetBuyerAssets.mulDivDown(referralFeePct, WAD);
        uint256 targetFilledBuyerAssets = targetBuyerAssets - referralFeeAssets;

        Offer memory canceledOffer = _signedSellOffer(keccak256("canceled-exact"), "canceled");
        Offer memory fallbackOffer = _signedSellOffer(keccak256("fallback-exact"), "fallback");
        (bytes32 canceledRoot, bytes memory canceledData) = _ratifierData(canceledOffer);
        (, bytes memory fallbackData) = _ratifierData(fallbackOffer);

        vm.prank(borrower);
        ecrecoverRatifier.cancelRoot(borrower, canceledRoot);

        collateralize(market, borrower, 20e18);

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: canceledOffer, units: type(uint128).max, ratifierData: canceledData});
        takes[1] = Take({offer: fallbackOffer, units: type(uint128).max, ratifierData: fallbackData});

        uint256 lenderBefore = loanToken.balanceOf(lender);
        uint256 borrowerBefore = loanToken.balanceOf(borrower);
        uint256 referralBefore = loanToken.balanceOf(REFERRAL);

        vm.prank(lender);
        midnightBundles.buyWithAssetsTargetAndWithdrawCollateral(
            targetBuyerAssets,
            0,
            lender,
            _noPermit(),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            referralFeePct,
            REFERRAL
        );

        assertEq(loanToken.balanceOf(lender), lenderBefore - targetBuyerAssets, "caller pays exact total budget");
        assertEq(
            loanToken.balanceOf(borrower),
            borrowerBefore + targetFilledBuyerAssets,
            "seller receives actual filled buyer assets when settlement fee is zero"
        );
        assertEq(loanToken.balanceOf(REFERRAL), referralBefore + referralFeeAssets, "referral receives exact fee");
        assertEq(midnight.consumed(borrower, canceledOffer.group), 0, "canceled offer never consumes");
        assertGt(midnight.consumed(borrower, fallbackOffer.group), 0, "fallback offer consumes");
        _assertBundlerEmpty();
        _assertMarketAccounting(marketId);
    }

    function _signedSellOffer(bytes32 group, bytes memory marker) internal view returns (Offer memory offer) {
        offer = _basicSellOffer(borrower, market);
        offer.ratifier = address(ecrecoverRatifier);
        offer.group = group;
        offer.maxUnits = type(uint128).max;
        offer.callbackData = marker;
    }

    function _ratifierData(Offer memory offer) internal view returns (bytes32 root, bytes memory data) {
        root = HashLib.hashOffer(offer);
        Signature memory sig = signature(root, privateKey[borrower], address(ecrecoverRatifier), 0);
        data = abi.encode(sig, root, uint256(0), new bytes32[](0));
    }

    function _noPermit() internal pure returns (TokenPermit memory) {
        return TokenPermit({kind: PermitKind.None, data: hex""});
    }
}
