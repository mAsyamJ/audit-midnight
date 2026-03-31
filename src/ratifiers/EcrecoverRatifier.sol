// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity 0.8.31;

import {IRatifier} from "../interfaces/ICallbacks.sol";
import {IMidnight, Offer} from "../interfaces/IMidnight.sol";
import {CALLBACK_SUCCESS} from "../libraries/ConstantsLib.sol";

struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
}

bytes32 constant EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(uint256 chainId,address verifyingContract)");
bytes32 constant ROOT_TYPEHASH = keccak256("Root(bytes32 root)");
bytes32 constant AUTHORIZATION_TYPEHASH =
    keccak256("Authorization(address authorizer,address authorized,bool isAuthorized,uint256 nonce)");

contract EcrecoverRatifier is IRatifier {
    address public immutable MIDNIGHT;
    mapping(address => uint256) public nonce;

    constructor(address _midnight) {
        MIDNIGHT = _midnight;
    }

    function signer(bytes32 structHash, Signature memory sig) internal view returns (address) {
        bytes32 domainSeparator = keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, block.chainid, address(this)));
        bytes32 digest = keccak256(bytes.concat("\x19\x01", domainSeparator, structHash));
        address _signer = ecrecover(digest, sig.v, sig.r, sig.s);
        require(_signer != address(0), "invalid signature");
        return _signer;
    }

    function onRatify(Offer memory offer, bytes32 root, bytes memory data) external view returns (bytes32) {
        Signature memory sig = abi.decode(data, (Signature));
        bytes32 structHash = keccak256(abi.encode(ROOT_TYPEHASH, root));
        address _signer = signer(structHash, sig);
        require(_signer == offer.maker || IMidnight(MIDNIGHT).isAuthorized(offer.maker, _signer), "invalid signature");
        return CALLBACK_SUCCESS;
    }

    function setIsAuthorizedWithSig(address authorizer, address authorized, bool isAuthorized, Signature calldata sig)
        external
    {
        require(msg.sender == authorizer || IMidnight(MIDNIGHT).isAuthorized(authorizer, msg.sender), "unauthorized");
        bytes32 structHash =
            keccak256(abi.encode(AUTHORIZATION_TYPEHASH, authorizer, authorized, isAuthorized, nonce[authorizer]++));
        address _signer = signer(structHash, sig);
        require(_signer == authorizer, "invalid signature");
        IMidnight(MIDNIGHT).setIsAuthorized(authorizer, authorized, isAuthorized);
    }
}
