# Cantina Submission — L-01

## Cantina UI Fields

| Field | Value |
|---|---|
| **Finding Title** | ECDSA signatures are accepted in malleated high-s form |
| **Likelihood** | Medium |
| **Impact** | Low |
| **Severity** | Low (computed by Cantina from Likelihood × Impact) |
| **Checklist anchor** | SOL-Signature-1 (malleability) |
| **PoC location** | `test/asyamFindings/PoC_SignatureMalleability.t.sol` |
| **PoC type** | Local Foundry (no fork required) |

---

## Summary

`EcrecoverRatifier` and `EcrecoverAuthorizer` recover signers with raw `ecrecover` and do not reject high-s signatures. Any valid low-s signature can be transformed into a distinct high-s signature that recovers the same signer and is accepted by both contracts.

## Finding Description

ECDSA signatures on secp256k1 are malleable: for any valid signature `(v, r, s)`, the tuple `(v ^ 1, r, n - s)` — where `n` is the curve order — is also valid for the same message digest and recovers the same signer. EIP-2 requires rejecting signatures where `s > n/2` to enforce canonical (low-s) form.

Both Midnight signature verification contracts use raw `ecrecover` without low-s normalization:

**`EcrecoverRatifier.isRatified`** (`src/ratifiers/EcrecoverRatifier.sol`):

```solidity
address _signer = ecrecover(digest, sig.v, sig.r, sig.s);
require(_signer != address(0), InvalidSignature());
require(_signer == offer.maker || IMidnight(MIDNIGHT).isAuthorized(offer.maker, _signer), Unauthorized());
```

**`EcrecoverAuthorizer.setIsAuthorized`** (`src/periphery/EcrecoverAuthorizer.sol`):

```solidity
address signer = ecrecover(digest, signature.v, signature.r, signature.s);
require(signer != address(0), InvalidSignature());
```

### Security guarantee broken

The protocol implicitly assumes that a signed authorization or ratification digest maps to a canonical signature representation. Without low-s enforcement, **signature uniqueness is not guaranteed**: two byte-distinct signatures can authenticate the same signer for the same digest.

### Propagation path

1. An observer sees a valid signature in the mempool, off-chain order flow, or indexer logs.
2. The observer computes `s' = secp256k1n - s` and flips `v` between 27 and 28.
3. The malleated signature is submitted on-chain:
   - **Ratifier path**: `EcrecoverRatifier.isRatified` validates the Merkle proof and root cancellation unchanged, then accepts the malleated signature because `ecrecover` returns the same signer.
   - **Authorizer path**: `EcrecoverAuthorizer.setIsAuthorized` accepts the malleated signature, increments the authorizer nonce, and calls `Midnight.setIsAuthorized`.

On-chain replay of the same authorization after successful execution is blocked by the authorizer nonce and by ratifier root/cancellation semantics. The broken guarantee is **canonicality**, not replay of an already-consumed authorization.

## Impact Explanation

**Impact: Low**

There is no direct path to steal user funds or bypass authorization logic:

- `EcrecoverAuthorizer` increments `nonce[authorizer]` before applying authorization, so a malleated signature cannot replay an already-consumed authorization.
- `EcrecoverRatifier` binds validity to Merkle root proof and root cancellation, not to raw signature bytes.

However, the issue still has concrete security-relevant effects:

- Integrations, indexers, or monitoring systems that deduplicate or authorize by raw `(v, r, s)` bytes can be confused by alternate valid signatures for the same digest.
- A malleated authorization can be submitted before the canonical signature is mined, creating an ordering/MEV surface for off-chain systems tracking signature uniqueness.
- The contracts deviate from EIP-2 canonical signature expectations, which is a known source of cross-system inconsistency in DeFi signature pipelines.

This does **not** constitute signature replay that bypasses nonce or root protections. Impact is limited to broken uniqueness assumptions and related operational/integration risk.

## Likelihood Explanation

**Likelihood: Medium**

Constructing a malleated signature requires only public arithmetic on an observed valid signature:

```solidity
s' = secp256k1n - s
v' = v == 27 ? 28 : 27
```

No private key, privileged role, or special market configuration is required. Any party who observes a valid ratifier or authorizer signature in transit can compute the high-s variant trivially. Because signatures are commonly visible in mempools and off-chain order infrastructure, the preconditions for malleation are routinely met in production.

## Proof of Concept

Run:

```bash
forge test --match-path test/asyamFindings/PoC_SignatureMalleability.t.sol -vvv
```

Validated: 2026-05-30 — 2/2 tests pass.

Core PoC logic from `test/asyamFindings/PoC_SignatureMalleability.t.sol`:

```solidity
function testPoC_RatifierAcceptsHighSMalleatedSignature() public {
    Offer memory offer = _signedOffer(lender);
    bytes32 root = HashLib.hashOffer(offer);

    RatifierSignature memory original = signature(root, privateKey[lender], address(ecrecoverRatifier), 0);
    RatifierSignature memory malleated =
        RatifierSignature({v: _flipV(original.v), r: original.r, s: _malleatedS(original.s)});

    assertGt(uint256(malleated.s), SECP256K1_HALF_N, "malleated signature is high-s");

    bytes32[] memory proof = new bytes32[](0);
    bytes memory ratifierData = abi.encode(malleated, root, uint256(0), proof);

    vm.prank(address(midnight));
    bytes32 result = ecrecoverRatifier.isRatified(offer, ratifierData);

    assertEq(result, CALLBACK_SUCCESS, "ratifier accepted the alternate high-s signature");
}

function testPoC_AuthorizerAcceptsHighSMalleatedSignature() public {
    // ... build Authorization digest, sign with vm.sign ...
    AuthorizationSignature memory malleated = AuthorizationSignature({v: _flipV(v), r: r, s: _malleatedS(s)});

    assertGt(uint256(malleated.s), SECP256K1_HALF_N, "malleated signature is high-s");

    ecrecoverAuthorizer.setIsAuthorized(authorization, malleated);

    assertTrue(midnight.isAuthorized(authorization.authorizer, authorization.authorized));
    assertEq(ecrecoverAuthorizer.nonce(borrower), authorization.nonce + 1);
}

function _malleatedS(bytes32 s) internal pure returns (bytes32) {
    return bytes32(SECP256K1_N - uint256(s));
}

function _flipV(uint8 v) internal pure returns (uint8) {
    return v == 27 ? 28 : 27;
}
```

## Recommendation

Replace raw `ecrecover` with a library that enforces EIP-2 low-s canonicality and valid `v` values. Apply the fix in both `EcrecoverRatifier.sol` and `EcrecoverAuthorizer.sol`.

```solidity
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

// Instead of:
// address signer = ecrecover(digest, signature.v, signature.r, signature.s);

address signer = ECDSA.recover(digest, signature.v, signature.r, signature.s);
```

Alternatively, add an explicit check before recovery:

```solidity
require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "Invalid s value");
require(v == 27 || v == 28, "Invalid v value");
address signer = ecrecover(digest, v, r, s);
```
