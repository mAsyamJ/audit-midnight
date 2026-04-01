// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity 0.8.31;

import {IMidnight} from "../interfaces/IMidnight.sol";
import {Signature, AUTHORIZATION_TYPEHASH, EIP712_DOMAIN_TYPEHASH} from "../interfaces/IEcrecover.sol";

contract SetIsAuthorizedWithSig {
    address public immutable MIDNIGHT;
    mapping(address => uint256) public nonce;

    constructor(address _midnight) {
        MIDNIGHT = _midnight;
    }

    function setIsAuthorizedWithSig(address authorizer, address authorized, bool isAuthorized, Signature calldata sig)
        external
    {
        require(msg.sender == authorizer || IMidnight(MIDNIGHT).isAuthorized(authorizer, msg.sender), "unauthorized");
        bytes32 structHash =
            keccak256(abi.encode(AUTHORIZATION_TYPEHASH, authorizer, authorized, isAuthorized, nonce[authorizer]++));
        bytes32 domainSeparator = keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, block.chainid, address(this)));
        bytes32 digest = keccak256(bytes.concat("\x19\x01", domainSeparator, structHash));
        address _signer = ecrecover(digest, sig.v, sig.r, sig.s);
        require(_signer != address(0) && _signer == authorizer, "invalid signature");
        IMidnight(MIDNIGHT).setIsAuthorized(authorizer, authorized, isAuthorized);
    }
}
