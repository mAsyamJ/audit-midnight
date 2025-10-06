// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import "./BaseTest.sol";

uint256 constant SECP256K1 = 115792089237316195423570985008687907852837564279074904382605163141518161494337;

/// @dev Ref implem from OpenZeppelin.
function toEthSignedMessageHash(bytes32 messageHash) pure returns (bytes32 digest) {
    assembly ("memory-safe") {
        mstore(0x00, "\x19Ethereum Signed Message:\n32") // 32 is the bytes-length of messageHash
        mstore(0x1c, messageHash) // 0x1c (28) is the length of the prefix
        digest := keccak256(0x00, 0x3c) // 0x3c is the length of the prefix (0x1c) + messageHash (0x20)
    }
}

contract SignatureTest is Test, MorphoV2 {
    function testFormat(bytes32 root) public {
        bytes32 messageHash = keccak256(bytes.concat("\x19\x45thereum Signed Message:\n32", root));
        assertEq(toEthSignedMessageHash(root), messageHash);
    }

    function testSigner(bytes32 root, uint256 sk) public {
        vm.assume(sk != 0);
        vm.assume(sk < SECP256K1);
        bytes32 messageHash = keccak256(bytes.concat("\x19\x45thereum Signed Message:\n32", root));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sk, messageHash);
        assertEq(signer(root, Signature({v: v, r: r, s: s})), vm.addr(sk));
    }
}
