// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {Signature} from "../src/interfaces/IMorphoV2.sol";
import {MorphoV2} from "../src/MorphoV2.sol";
import {ROOT_TYPEHASH} from "../src/libraries/ConstantsLib.sol";
import {Test} from "../lib/forge-std/src/Test.sol";

contract SignatureTest is Test, MorphoV2 {
    function testFormat(bytes32 root) public view {
        bytes32 structHash = keccak256(abi.encode(ROOT_TYPEHASH, root, block.chainid, address(this)));
        bytes32 expectedDigest = keccak256(bytes.concat("\x19\x01", _domainSeparator(), structHash));
        assertEq(expectedDigest, _hashTypedData(root));
    }

    function testSigner(bytes32 root, uint256 sk) public view {
        sk = boundPrivateKey(sk);
        bytes32 digest = _hashTypedData(root);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(sk, digest);
        assertEq(_signer(root, Signature({v: v, r: r, s: s})), vm.addr(sk));
    }

    function _hashTypedData(bytes32 root) internal view returns (bytes32) {
        bytes32 structHash = keccak256(abi.encode(ROOT_TYPEHASH, root, block.chainid, address(this)));
        return keccak256(bytes.concat("\x19\x01", _domainSeparator(), structHash));
    }
}
