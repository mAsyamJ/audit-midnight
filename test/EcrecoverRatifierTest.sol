// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {Signature, AUTHORIZATION_TYPEHASH, EIP712_DOMAIN_TYPEHASH} from "../src/ratifiers/EcrecoverRatifier.sol";
import {BaseTest} from "./BaseTest.sol";

contract EcrecoverRatifierTest is BaseTest {
    function authorizationSig(address authorizer, address authorized, bool isAuthorized, address _signer)
        internal
        view
        returns (Signature memory)
    {
        bytes32 structHash = keccak256(
            abi.encode(
                AUTHORIZATION_TYPEHASH, authorizer, authorized, isAuthorized, ecrecoverRatifier.nonce(authorizer)
            )
        );
        bytes32 domainSeparator =
            keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, block.chainid, address(ecrecoverRatifier)));
        bytes32 digest = keccak256(bytes.concat("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey[_signer], digest);
        return Signature({v: v, r: r, s: s});
    }

    function testSetIsAuthorizedWithSig() public {
        Signature memory sig = authorizationSig(borrower, lender, true, borrower);

        vm.prank(borrower);
        ecrecoverRatifier.setIsAuthorizedWithSig(borrower, lender, true, sig);

        assertEq(midnight.isAuthorized(borrower, lender), true);
        assertEq(ecrecoverRatifier.nonce(borrower), 1);

        sig = authorizationSig(borrower, lender, false, borrower);

        vm.prank(borrower);
        ecrecoverRatifier.setIsAuthorizedWithSig(borrower, lender, false, sig);

        assertEq(midnight.isAuthorized(borrower, lender), false);
        assertEq(ecrecoverRatifier.nonce(borrower), 2);
    }

    function testSetIsAuthorizedWithSigAuthorizedCaller() public {
        vm.prank(borrower);
        midnight.setIsAuthorized(borrower, lender, true);

        Signature memory sig = authorizationSig(borrower, otherLender, true, borrower);

        vm.prank(lender);
        ecrecoverRatifier.setIsAuthorizedWithSig(borrower, otherLender, true, sig);

        assertEq(midnight.isAuthorized(borrower, otherLender), true);
        assertEq(ecrecoverRatifier.nonce(borrower), 1);
    }

    function testSetIsAuthorizedWithSigUnauthorizedCaller() public {
        Signature memory sig = authorizationSig(borrower, lender, true, borrower);

        vm.prank(otherLender);
        vm.expectRevert("unauthorized");
        ecrecoverRatifier.setIsAuthorizedWithSig(borrower, lender, true, sig);

        assertEq(midnight.isAuthorized(borrower, lender), false);
        assertEq(ecrecoverRatifier.nonce(borrower), 0);
    }

    function testSetIsAuthorizedWithSigInvalidSignature() public {
        Signature memory sig = authorizationSig(borrower, lender, true, lender);

        vm.prank(borrower);
        vm.expectRevert("invalid signature");
        ecrecoverRatifier.setIsAuthorizedWithSig(borrower, lender, true, sig);

        assertEq(midnight.isAuthorized(borrower, lender), false);
        assertEq(ecrecoverRatifier.nonce(borrower), 0);
    }

    function testSetIsAuthorizedWithSigNonce(uint8 n) public {
        n = uint8(bound(n, 1, 32));

        for (uint8 i = 0; i < n; i++) {
            bool isAuthorized = i % 2 == 0;
            Signature memory sig = authorizationSig(borrower, lender, isAuthorized, borrower);

            vm.prank(borrower);
            ecrecoverRatifier.setIsAuthorizedWithSig(borrower, lender, isAuthorized, sig);

            assertEq(ecrecoverRatifier.nonce(borrower), i + 1);
            assertEq(midnight.isAuthorized(borrower, lender), isAuthorized);
        }
    }
}
