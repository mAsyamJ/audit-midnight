// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {HashLib} from "../../../src/ratifiers/libraries/HashLib.sol";
import {
    IEcrecoverRatifier,
    Signature as RatifierSignature
} from "../../../src/ratifiers/interfaces/IEcrecoverRatifier.sol";

/// @dev AP-011 / POC-INTENT-011 — canceled Merkle roots must not ratify on `take`.
contract PoCCanceledRootReuseTest is Config {
    function testPoC_TakeRevertsAfterMakerCancelRoot() public {
        Offer memory offer = _ecrecoverOffer(lender);
        bytes32 root = HashLib.hashOffer(offer);
        bytes memory ratifierData = _singleLeafRatifierData(root, lender);

        vm.prank(lender);
        ecrecoverRatifier.cancelRoot(lender, root);
        assertTrue(ecrecoverRatifier.isRootCanceled(lender, root));

        vm.prank(borrower);
        vm.expectRevert(IEcrecoverRatifier.RootCanceled.selector);
        midnight.take(offer, ratifierData, 1e18, borrower, borrower, address(0), hex"");
    }

    function testPoC_TakeRevertsAfterAuthorizedDelegateCancelRoot() public {
        Offer memory offer = _ecrecoverOffer(lender);
        bytes32 root = HashLib.hashOffer(offer);
        bytes memory ratifierData = _singleLeafRatifierData(root, lender);

        vm.prank(lender);
        midnight.setIsAuthorized(ATTACKER, true, lender);

        vm.prank(ATTACKER);
        ecrecoverRatifier.cancelRoot(lender, root);

        vm.prank(borrower);
        vm.expectRevert(IEcrecoverRatifier.RootCanceled.selector);
        midnight.take(offer, ratifierData, 1e18, borrower, borrower, address(0), hex"");
    }

    function testPoC_AttackerCannotCancelForeignRoot() public {
        bytes32 root = keccak256("foreign-root");

        vm.prank(ATTACKER);
        vm.expectRevert(IEcrecoverRatifier.Unauthorized.selector);
        ecrecoverRatifier.cancelRoot(lender, root);

        assertFalse(ecrecoverRatifier.isRootCanceled(lender, root));
    }

    function testPoC_CanceledRootCannotBeUnratifiedByNewSignature() public {
        Offer memory offer = _ecrecoverOffer(lender);
        bytes32 root = HashLib.hashOffer(offer);

        vm.prank(lender);
        ecrecoverRatifier.cancelRoot(lender, root);

        RatifierSignature memory sig = signature(root, privateKey[lender], address(ecrecoverRatifier), 0);
        bytes32[] memory proof = new bytes32[](0);
        bytes memory ratifierData = abi.encode(sig, root, uint256(0), proof);

        vm.prank(address(midnight));
        vm.expectRevert(IEcrecoverRatifier.RootCanceled.selector);
        ecrecoverRatifier.isRatified(offer, ratifierData);
    }

    function _ecrecoverOffer(address maker) internal view returns (Offer memory offer) {
        offer = _basicBuyOffer(maker, market);
        offer.ratifier = address(ecrecoverRatifier);
        offer.maxUnits = 100e18;
    }

    function _singleLeafRatifierData(bytes32 root, address signer) internal view returns (bytes memory) {
        RatifierSignature memory sig = signature(root, privateKey[signer], address(ecrecoverRatifier), 0);
        bytes32[] memory proof = new bytes32[](0);
        return abi.encode(sig, root, uint256(0), proof);
    }
}
