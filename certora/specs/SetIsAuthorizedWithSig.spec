// SPDX-License-Identifier: GPL-2.0-or-later

using Midnight as midnight;

methods {
    function nonce(address) external returns (uint256) envfree;
    function MIDNIGHT() external returns (address) envfree;
    function midnight.isAuthorized(address, address) external returns (bool) envfree;
}

/// setIsAuthorizedWithSig is satisfiable.
rule satisfiable(env e, address authorizer, address authorized, bool isAuth, SetIsAuthorizedWithSig.Signature signature) {
    setIsAuthorizedWithSig(e, authorizer, authorized, isAuth, signature);
    satisfy true;
}

/// setIsAuthorizedWithSig requires caller auth, valid signer, increments nonce, and doesn't change other nonces.
rule setIsAuthorizedWithSigEffects(env e, address authorizer, address authorized, bool isAuth, SetIsAuthorizedWithSig.Signature signature, address other) {
    require other != authorizer;
    uint256 nonceBefore = nonce(authorizer);
    uint256 otherNonceBefore = nonce(other);
    bool callerWasAuthorized = midnight.isAuthorized(authorizer, e.msg.sender);

    setIsAuthorizedWithSig(e, authorizer, authorized, isAuth, signature);

    assert e.msg.sender == authorizer || callerWasAuthorized;
    assert nonce(authorizer) == nonceBefore + 1;
    assert nonce(other) == otherNonceBefore;
}

/// A nonce can't be reused: calling setIsAuthorizedWithSig twice with the same nonce reverts.
rule nonceReplay(env e1, env e2, address authorizer, address authorized1, bool isAuth1, SetIsAuthorizedWithSig.Signature signature1, address authorized2, bool isAuth2, SetIsAuthorizedWithSig.Signature signature2) {
    uint256 nonceBefore = nonce(authorizer);

    setIsAuthorizedWithSig(e1, authorizer, authorized1, isAuth1, signature1);

    setIsAuthorizedWithSig@withrevert(e2, authorizer, authorized2, isAuth2, signature2);

    assert !lastReverted => nonce(authorizer) == nonceBefore + 2;
}
