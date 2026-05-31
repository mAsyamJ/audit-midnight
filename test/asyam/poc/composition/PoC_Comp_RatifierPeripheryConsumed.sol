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

/// @dev COMP-001 / COMP-016 — stale ratifier roots and direct/routed fills must still share one consumed cap.
contract PoCCompRatifierPeripheryConsumedTest is Config {
    bytes32 internal constant GROUP = keccak256("composition-shared-group");

    function testComp_CanceledRootSkipsAndValidSameGroupFallbackRespectsCap() public {
        uint256 targetUnits = 20e18;
        collateralize(market, borrower, targetUnits);

        Offer memory canceledOffer = _signedSellOffer(GROUP, targetUnits, "canceled");
        Offer memory fallbackOffer = _signedSellOffer(GROUP, targetUnits, "fallback");
        (bytes32 canceledRoot, bytes memory canceledData) = _ratifierData(canceledOffer);
        (, bytes memory fallbackData) = _ratifierData(fallbackOffer);

        vm.prank(borrower);
        ecrecoverRatifier.cancelRoot(borrower, canceledRoot);

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: canceledOffer, units: targetUnits, ratifierData: canceledData});
        takes[1] = Take({offer: fallbackOffer, units: targetUnits, ratifierData: fallbackData});

        vm.prank(lender);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            targetUnits,
            targetUnits * 2,
            lender,
            _noPermit(),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            0,
            address(0)
        );

        assertEq(midnight.consumed(borrower, GROUP), targetUnits, "fallback fill consumes only target");
        assertEq(midnight.debtOf(marketId, borrower), targetUnits, "borrower debt matches accepted fallback");
        _assertConsumedCap(borrower, GROUP, targetUnits);
        _assertBundlerEmpty();
        _assertMarketAccounting(marketId);
    }

    function testComp_DirectFillThenCanceledRootFallbackCannotExceedSharedCap() public {
        uint256 cap = 30e18;
        uint256 directUnits = 10e18;
        uint256 routedUnits = cap - directUnits;
        collateralize(market, borrower, cap);

        Offer memory directOffer = _signedSellOffer(GROUP, cap, "direct");
        Offer memory canceledOffer = _signedSellOffer(GROUP, cap, "canceled-after-direct");
        Offer memory fallbackOffer = _signedSellOffer(GROUP, cap, "fallback-after-direct");
        (, bytes memory directData) = _ratifierData(directOffer);
        (bytes32 canceledRoot, bytes memory canceledData) = _ratifierData(canceledOffer);
        (, bytes memory fallbackData) = _ratifierData(fallbackOffer);

        vm.prank(lender);
        midnight.take(directOffer, directData, directUnits, lender, borrower, address(0), hex"");

        vm.prank(borrower);
        ecrecoverRatifier.cancelRoot(borrower, canceledRoot);

        Take[] memory takes = new Take[](2);
        takes[0] = Take({offer: canceledOffer, units: routedUnits, ratifierData: canceledData});
        takes[1] = Take({offer: fallbackOffer, units: routedUnits, ratifierData: fallbackData});

        vm.prank(lender);
        midnightBundles.buyWithUnitsTargetAndWithdrawCollateral(
            routedUnits,
            routedUnits * 2,
            lender,
            _noPermit(),
            takes,
            new CollateralWithdrawal[](0),
            address(0),
            0,
            address(0)
        );

        assertEq(midnight.consumed(borrower, GROUP), cap, "direct and routed fills share cap");
        assertEq(midnight.debtOf(marketId, borrower), cap, "accepted units match debt");
        _assertConsumedCap(borrower, GROUP, cap);
        _assertBundlerEmpty();
        _assertMarketAccounting(marketId);
    }

    function _signedSellOffer(bytes32 group, uint256 cap, bytes memory marker)
        internal
        view
        returns (Offer memory offer)
    {
        offer = _basicSellOffer(borrower, market);
        offer.ratifier = address(ecrecoverRatifier);
        offer.group = group;
        offer.maxUnits = cap;
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
