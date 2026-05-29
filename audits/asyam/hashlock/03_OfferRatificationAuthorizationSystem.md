# Hashlock AI Audit Report — Morpho Midnight Offer Ratification / Authorization System

DeFi Protocol - Offer Ratification / Authorization System

This contract suite implements a Merkle-tree-based offer ratification system for the Morpho 'Midnight' protocol. It consists of: (1) HashLib — a library for EIP-712 hashing of structured data (CollateralParams, Market, Offer) and Merkle tree operations; (2) EcrecoverRatifier — a ratifier that verifies an offer is part of a signed Merkle tree of offers using ECDSA signatures; (3) SetterRatifier — a ratifier that verifies an offer is part of a Merkle tree whose root has been explicitly approved on-chain by the maker; (4) IEcrecoverAuthorizer — an interface for an authorization contract that manages delegated signing permissions. Together, these contracts allow makers to pre-authorize batches of offers (organized as Merkle trees) either via off-chain ECDSA signatures or on-chain root approvals.


Source: Hashlock AI Audit page content pasted by the user.  
Date shown in pasted scan: **May 30, 2026**.  
Scan summary shown: **6 files**, **13 issues found**.  
Target described by scan: **DeFi Protocol — Offer Ratification / Authorization System**.

> Important: the original page explicitly states that this is an **AI-generated scan** and may contain inaccuracies or false positives. Treat every item below as a triage candidate, not as a confirmed competition finding. For Cantina submission, each issue needs source validation, deduplication, and preferably a Foundry PoC or a precise proof.

---

## 1. Executive Summary

The scan focuses on the Morpho Midnight ratification / authorization layer, especially:

- `EcrecoverRatifier.sol`
- `SetterRatifier.sol`
- `HashLib.sol`
- `IEcrecoverAuthorizer.sol`
- Related interfaces and Merkle/EIP-712 helper logic

The reported issues cluster around:

1. **Root cancellation / ratification operations**
   - front-running of cancellations
   - delegate ability to de-ratify or cancel roots
   - irreversible root cancellation

2. **Merkle proof and hashing gas behavior**
   - unbounded `collateralParams` hashing in `hashMarket`
   - proof length inconsistency between `EcrecoverRatifier` and `SetterRatifier`

3. **Signature and EIP-712 hygiene**
   - raw `ecrecover`
   - signature malleability
   - dynamic domain separator gas cost
   - hardcoded typehash correctness

4. **Compilation / interface hygiene**
   - floating pragmas
   - overly broad `>=0.5.0` pragma in `IEcrecoverAuthorizer.sol`

5. **Auditability**
   - no event emission on `isRatified` due to `view` design

---

## 2. Access Control Model

### Privileged Roles

1. `MIDNIGHT` immutable contract address
2. `maker` / offer creator
3. authorized delegate via `IMidnight.isAuthorized`
4. `msg.sender` for `cancelRoot` and `setIsRootRatified`

### External Systems

1. EIP-712 signing infrastructure
2. Merkle tree construction infrastructure

### Call Graph Items Shown by Scan

```text
offerTreeTypeHash
isLeaf
hashNode
hashCollateralParams
hashMarket
hashOffer
SetIsAuthorized
MIDNIGHT
nonce
setIsAuthorized
constructor
cancelRoot
CancelRoot
isRatified
setIsRootRatified
SetIsRootRatified
isRootCanceled
isRootRatified
```

---

## 3. Severity Summary

| Severity | Count shown | Main themes |
|---|---:|---|
| Medium | 3 | cancellation front-running, gas DoS from unbounded arrays/proofs, delegate de-ratification griefing |
| Low | 4 | signature malleability, proof length inconsistency, irreversible cancellation, zero-address maker defense-in-depth |
| Gas | 2 | public vs external, domain separator recomputation |
| Informational | 4 | floating pragmas, hardcoded typehash verification, auditability limits, broad pragma |

---

## 4. Competition Triage Summary

| ID | Title | Scan severity | Competition triage |
|---|---|---:|---|
| M-01 | Front-running of `cancelRoot` / `setIsRootRatified` enables unwanted trade execution | Medium | Likely known order-cancellation MEV risk. Needs strong proof of protocol-specific broken guarantee to be accepted. |
| M-02 | Unbounded `collateralParams` array in `hashMarket` enables gas exhaustion DoS | Medium | Needs validation against `Midnight.touchMarket` bounds and whether ratifier is called before market validation. Potentially weak if core already bounds markets. |
| M-03 | Authorized delegate can de-ratify/cancel roots | Medium | May be intended authorization semantics. Strong only if delegate scope is expected to be narrower. |
| L-01 | Signature malleability in `EcrecoverRatifier` | Low | Real hygiene issue, likely low unless signature bytes are used for replay/dedup elsewhere. |
| L-02 | SetterRatifier proof length not capped | Low | Potential low/gas grief. Need test whether proof length > 20 can ever be valid/useful. |
| L-03 | `cancelRoot` irreversible | Low | Likely design decision. Could be accepted as operational risk only. |
| L-04 | Missing zero-address validation for `offer.maker` | Low | Likely defense-in-depth. Need prove `offer.maker == address(0)` can reach `take` and cause impact. |
| G-01 | `setIsRootRatified` public instead of external | Gas | Minor gas only. |
| G-02 | Domain separator computed at call time | Gas | Gas only; dynamic chain-id may be intentional. |
| I-01 | Floating pragmas | Informational | Hygiene. |
| I-02 | Hardcoded typehash values not verified on-chain | Informational | Test coverage / correctness issue. |
| I-03 | No event emitted for `isRatified` calls | Informational | Not possible while function is `view`; rely on Midnight events/traces. |
| I-04 | `IEcrecoverAuthorizer` broad pragma | Informational | Hygiene; overlaps I-01. |

---

# 5. Medium Severity Findings

---

## M-01 — Front-Running of `cancelRoot` / `setIsRootRatified` Enables Unauthorized or Unwanted Trade Execution

**Affected files**

- `EcrecoverRatifier.sol`
- `SetterRatifier.sol`

**Scan severity:** Medium

### Summary

When a maker decides to revoke a signed Merkle tree root by calling `cancelRoot` in `EcrecoverRatifier` or `setIsRootRatified(maker, root, false)` in `SetterRatifier`, the transaction is visible in the public mempool before being mined. A taker monitoring the mempool can front-run the cancellation by filling a still-valid offer from the soon-to-be-canceled tree.

### Impact

A maker attempting to cancel a root to avoid unwanted trades may still have one or more trades executed before the cancellation lands. This can cause financial loss if market conditions changed adversely.

### Scenario

1. Maker signs a Merkle tree root containing offers at price `P`.
2. Market price drops significantly.
3. Maker submits `cancelRoot(maker, root)` or `setIsRootRatified(maker, root, false)`.
4. Attacker observes the pending cancellation in the mempool.
5. Attacker submits a higher-priority transaction to execute an offer from the same tree.
6. Attacker’s trade executes first.
7. Maker’s cancellation executes afterward, but the unfavorable trade already happened.

### Affected Code

```solidity
function cancelRoot(address maker, bytes32 root) external {
    require(maker == msg.sender || IMidnight(MIDNIGHT).isAuthorized(maker, msg.sender), Unauthorized());
    isRootCanceled[maker][root] = true;
    emit CancelRoot(msg.sender, maker, root);
}
```

### Proposed Fix From Scan

1. Document the mempool front-running risk prominently.
2. Recommend private mempool / protected RPC routes for cancellation transactions.
3. Use short offer expiries.
4. Consider protocol-level mitigation if feasible, such as a pause/pre-cancel mechanism.

### Audit Triage Notes

This is a common off-chain order cancellation race. It is probably **not enough** as a standalone Medium unless the protocol claims root cancellation is immediate protection against already-submitted but unmined fills. To make this competition-worthy, prove one of:

- the protocol documentation promises cancellation safety that is not true;
- a maker cannot set short expiries or reduce exposure in a practical way;
- a cancellation path is uniquely worse than standard off-chain orderbook cancellation;
- there is a bundled or protocol-specific path that amplifies impact beyond ordinary MEV.

### PoC Direction

Write a Foundry test that models ordering:

```text
tx1 pending: maker.cancelRoot(root)
tx2 mined first: taker fills offer from root
tx1 mined second: cancellation succeeds but is too late
```

The key is not technical feasibility; it is whether this violates an accepted security guarantee.

---

## M-02 — Unbounded `collateralParams` Array in `hashMarket` Enables Gas Exhaustion DoS

**Affected file**

- `HashLib.sol`

**Scan severity:** Medium

### Summary

`hashMarket` iterates over `market.collateralParams` without an explicit local length bound. A malicious offer can contain an extremely large `collateralParams` array, forcing expensive hashing during `hashOffer` / `isRatified`.

### Impact

A malicious actor may craft offers with very large collateral arrays that cause `isRatified` to run out of gas or become prohibitively expensive. This can grief trades that try to use such offers.

### Scenario

```solidity
CollateralParams[] memory params = new CollateralParams[](10000);

for (uint256 i = 0; i < 10000; i++) {
    params[i] = CollateralParams(address(uint160(i)), 0, 0, address(0));
}

Offer memory offer = Offer({
    market: Market({ collateralParams: params, ... }),
    ...
});

// Submit offer through MIDNIGHT.
// isRatified -> hashOffer -> hashMarket hashes every collateral param.
```

### Affected Code

```solidity
function hashMarket(Market memory market) internal pure returns (bytes32) {
    bytes32[] memory collateralParamsHashes = new bytes32[](market.collateralParams.length);

    for (uint256 i = 0; i < market.collateralParams.length; i++) {
        collateralParamsHashes[i] = hashCollateralParams(market.collateralParams[i]);
    }

    ...
}
```

### Proposed Fix From Scan

Add explicit bounds in ratifiers before hashing:

```solidity
uint256 constant MAX_COLLATERAL_PARAMS = 20;
require(offer.market.collateralParams.length <= MAX_COLLATERAL_PARAMS, "Too many collateral params");
```

Also cap proof length in `SetterRatifier`:

```solidity
uint256 constant MAX_PROOF_LENGTH = 20;
require(proof.length <= MAX_PROOF_LENGTH, "Proof too long");
```

### Audit Triage Notes

This finding requires careful validation because the core `Midnight.touchMarket` is expected to enforce market collateral bounds. If `take()` calls `touchMarket(offer.market)` before ratifier validation, then malformed huge markets may be rejected before ratifier hashing. If the core validates length before `isRatified`, this issue may be a false positive for the protocol path.

To validate:

1. Confirm call order in `Midnight.take`.
2. Confirm `touchMarket` checks `market.collateralParams.length <= MAX_COLLATERALS`.
3. Confirm whether any ratifier can be called directly or only by Midnight.
4. Confirm `msg.sender == MIDNIGHT` guard in ratifiers.
5. Try Foundry PoC with oversized `collateralParams` through actual `Midnight.take`.

### PoC Direction

```text
test_POC_oversizedCollateralParamsRejectedBeforeRatifier()
```

Expected outcomes:

- If `touchMarket` rejects before `isRatified`, this is likely not valid.
- If `isRatified` hashes before length rejection, then gas DoS may be valid.

---

## M-03 — Authorized Delegate Can Unilaterally De-Ratify Roots in `SetterRatifier`

**Affected files**

- `SetterRatifier.sol`
- `EcrecoverRatifier.sol`

**Scan severity:** Medium

### Summary

Any address authorized through `IMidnight.isAuthorized(maker, msg.sender)` can set or unset root ratification in `SetterRatifier`. Similarly, an authorized delegate can cancel roots in `EcrecoverRatifier`.

### Impact

A malicious or compromised delegate can invalidate a maker’s active offer tree, disrupting market-making operations. In `EcrecoverRatifier`, cancellation is irreversible.

### Scenario

1. Maker authorizes a delegate via Midnight authorization.
2. Maker ratifies a root with `setIsRootRatified(maker, root, true)`.
3. Delegate becomes malicious or compromised.
4. Delegate calls `setIsRootRatified(maker, root, false)`.
5. Offers in the tree fail with `NotRatified`.
6. Maker experiences operational disruption.

### Affected Code

```solidity
function setIsRootRatified(address maker, bytes32 root, bool newIsRootRatified) public {
    require(maker == msg.sender || IMidnight(MIDNIGHT).isAuthorized(maker, msg.sender), Unauthorized());
    isRootRatified[maker][root] = newIsRootRatified;
    emit SetIsRootRatified(msg.sender, maker, root, newIsRootRatified);
}
```

### Proposed Fix From Scan

Separate ratification and de-ratification privileges:

```solidity
function setIsRootRatified(address maker, bytes32 root, bool newIsRootRatified) public {
    if (!newIsRootRatified) {
        require(maker == msg.sender, OnlyMakerCanDeratify());
    } else {
        require(maker == msg.sender || IMidnight(MIDNIGHT).isAuthorized(maker, msg.sender), Unauthorized());
    }

    isRootRatified[maker][root] = newIsRootRatified;
    emit SetIsRootRatified(msg.sender, maker, root, newIsRootRatified);
}
```

Alternative: document that Midnight authorization is broad and includes root cancellation/de-ratification authority.

### Audit Triage Notes

This may be an intended consequence of broad `isAuthorized` semantics. It becomes stronger only if:

- authorization is documented as limited to trading but actually controls root validity;
- official periphery asks users to grant broad authorization without warning;
- a contract authorized for a narrow purpose can de-ratify/cancel roots due to shared authorization mapping;
- there is no way for maker to scope authorization.

### PoC Direction

```text
test_POC_authorizedDelegateCanDeratifyRoot()
test_POC_authorizedDelegateCanCancelEcrecoverRoot()
```

PoC should demonstrate the exact user expectation broken, not merely that authorized delegates can act.

---

# 6. Low Severity Findings

---

## L-01 — Signature Malleability in `EcrecoverRatifier`

**Affected file**

- `EcrecoverRatifier.sol`

**Scan severity:** Low

### Summary

`EcrecoverRatifier.isRatified` uses raw `ecrecover` without low-`s` normalization. For a valid ECDSA signature `(r, s)`, a malleable counterpart `(r, n - s)` with adjusted `v` can recover the same signer.

### Impact

An attacker who sees a valid signature can compute another valid signature with different bytes but the same recovered signer. Current contract logic does not appear to use raw signature bytes as a replay-prevention key, so direct impact is limited.

### Scenario

```solidity
uint8 v2 = sig.v == 27 ? 28 : 27;

bytes32 s2 = bytes32(
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - uint256(sig.s)
);

// (v2, r, s2) recovers the same address.
```

### Affected Code

```solidity
address _signer = ecrecover(digest, sig.v, sig.r, sig.s);
require(_signer != address(0), InvalidSignature());
require(_signer == offer.maker || IMidnight(MIDNIGHT).isAuthorized(offer.maker, _signer), Unauthorized());
return CALLBACK_SUCCESS;
```

### Proposed Fix From Scan

Use OpenZeppelin `ECDSA.recover`, or add a low-`s` check:

```solidity
uint256 constant SECP256K1_N_HALF =
    0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0;

require(uint256(sig.s) <= SECP256K1_N_HALF, InvalidSignature());
```

### Audit Triage Notes

Likely valid as hygiene but low severity unless:

- raw signature bytes are tracked elsewhere;
- an off-chain system deduplicates by signature bytes;
- future extension depends on signature uniqueness.

---

## L-02 — `SetterRatifier` Proof Length Not Capped

**Affected file**

- `SetterRatifier.sol`

**Scan severity:** Low

### Summary

`EcrecoverRatifier.isRatified` indirectly caps proof length by calling `HashLib.offerTreeTypeHash(proof.length)`, which reverts above height 20. `SetterRatifier.isRatified` calls `HashLib.isLeaf` directly and does not enforce the same cap.

### Impact

A taker can submit long proof arrays to increase gas consumption. The scan describes this as griefing rather than direct security break.

### Affected Code

```solidity
function isRatified(Offer memory offer, bytes memory ratifierData) external view returns (bytes32) {
    require(msg.sender == MIDNIGHT, NotMidnight());

    (bytes32 root, uint256 leafIndex, bytes32[] memory proof) =
        abi.decode(ratifierData, (bytes32, uint256, bytes32[]));

    require(HashLib.isLeaf(root, HashLib.hashOffer(offer), leafIndex, proof), InvalidProof());
    require(isRootRatified[offer.maker][root], NotRatified());

    return CALLBACK_SUCCESS;
}
```

### Proposed Fix From Scan

```solidity
require(proof.length <= 20, "Proof too long");
```

### Audit Triage Notes

This is more credible than M-02 because the cap inconsistency is real at the ratifier level. However, practical severity depends on:

- whether long proofs can be valid for an approved root;
- who pays gas;
- whether a taker can grief someone else or only themselves.

---

## L-03 — `EcrecoverRatifier.cancelRoot` Is Irreversible

**Affected file**

- `EcrecoverRatifier.sol`

**Scan severity:** Low

### Summary

Once a root is canceled through `cancelRoot`, it is permanently set to `true` in `isRootCanceled[maker][root]`. There is no recovery or re-enable function.

### Impact

Accidental or malicious root cancellation permanently invalidates the Merkle tree. The maker must generate and sign a new root.

### Affected Code

```solidity
function cancelRoot(address maker, bytes32 root) external {
    require(maker == msg.sender || IMidnight(MIDNIGHT).isAuthorized(maker, msg.sender), Unauthorized());
    isRootCanceled[maker][root] = true;
    emit CancelRoot(msg.sender, maker, root);
}
```

### Proposed Fix From Scan

Option 1: document the irreversible design.

Option 2: use a toggle model:

```solidity
mapping(address maker => mapping(bytes32 root => bool)) public isRootEnabled;

function setRootEnabled(address maker, bytes32 root, bool enabled) external {
    require(maker == msg.sender || IMidnight(MIDNIGHT).isAuthorized(maker, msg.sender), Unauthorized());
    isRootEnabled[maker][root] = enabled;
    emit SetRootEnabled(msg.sender, maker, root, enabled);
}
```

Option 3: restrict cancellation to maker only:

```solidity
function cancelRoot(address maker, bytes32 root) external {
    require(maker == msg.sender, Unauthorized());
    isRootCanceled[maker][root] = true;
    emit CancelRoot(msg.sender, maker, root);
}
```

### Audit Triage Notes

Likely a design tradeoff, not a vulnerability, unless the protocol documentation implies roots can be recovered or only maker can invalidate them.

---

## L-04 — Missing Zero-Address Validation for `offer.maker`

**Affected file**

- `EcrecoverRatifier.sol`

**Scan severity:** Low

### Summary

`EcrecoverRatifier.isRatified` checks `_signer != address(0)` but does not explicitly check `offer.maker != address(0)`. If an upstream bug allows `offer.maker == address(0)`, and if `address(0)` has authorized delegates in Midnight, then an authorized signer for `address(0)` could ratify offers.

### Impact

This is a defense-in-depth concern. Direct exploitability depends on whether `offer.maker == address(0)` can reach this function through `Midnight.take`, and whether `address(0)` can have authorized delegates.

### Affected Code

```solidity
address _signer = ecrecover(digest, sig.v, sig.r, sig.s);
require(_signer != address(0), InvalidSignature());
require(_signer == offer.maker || IMidnight(MIDNIGHT).isAuthorized(offer.maker, _signer), Unauthorized());
return CALLBACK_SUCCESS;
```

### Proposed Fix From Scan

```solidity
require(offer.maker != address(0), InvalidMaker());
```

### Audit Triage Notes

This is only strong if a Foundry test proves:

1. `offer.maker == address(0)` is accepted by `Midnight.take`.
2. `isAuthorized(address(0), signer)` can become true.
3. A meaningful trade/accounting impact follows.

Without those, it is likely low/informational.

---

# 7. Gas Findings

---

## G-01 — `setIsRootRatified` Is `public` Instead of `external`

**Affected file**

- `SetterRatifier.sol`

**Scan severity:** Gas

### Summary

`setIsRootRatified` is marked `public`, but the scan states it is not called internally. Marking it `external` may save gas.

### Affected Code

```solidity
function setIsRootRatified(address maker, bytes32 root, bool newIsRootRatified) public {
    require(maker == msg.sender || IMidnight(MIDNIGHT).isAuthorized(maker, msg.sender), Unauthorized());
    isRootRatified[maker][root] = newIsRootRatified;
    emit SetIsRootRatified(msg.sender, maker, root, newIsRootRatified);
}
```

### Proposed Fix

```solidity
function setIsRootRatified(address maker, bytes32 root, bool newIsRootRatified) external {
    require(maker == msg.sender || IMidnight(MIDNIGHT).isAuthorized(maker, msg.sender), Unauthorized());
    isRootRatified[maker][root] = newIsRootRatified;
    emit SetIsRootRatified(msg.sender, maker, root, newIsRootRatified);
}
```

---

## G-02 — Domain Separator Computed at Call Time

**Affected file**

- `EcrecoverRatifier.sol`

**Scan severity:** Gas

### Summary

`EcrecoverRatifier.isRatified` computes the domain separator dynamically on every call:

```solidity
bytes32 domainSeparator = keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, block.chainid, address(this)));
```

### Impact

This costs more gas than caching the domain separator. However, dynamic computation is also fork-safe and appears intentional.

### Proposed Fix From Scan

Cache domain separator while preserving fork handling:

```solidity
bytes32 private immutable _DOMAIN_SEPARATOR;
uint256 private immutable _CHAIN_ID;

constructor(address _midnight) {
    MIDNIGHT = _midnight;
    _CHAIN_ID = block.chainid;
    _DOMAIN_SEPARATOR = keccak256(
        abi.encode(EIP712_DOMAIN_TYPEHASH, block.chainid, address(this))
    );
}

function _domainSeparator() internal view returns (bytes32) {
    if (block.chainid != _CHAIN_ID) {
        return keccak256(abi.encode(EIP712_DOMAIN_TYPEHASH, block.chainid, address(this)));
    }

    return _DOMAIN_SEPARATOR;
}
```

### Audit Triage Notes

This is gas-only. Do not prioritize for a severity competition unless gas findings are explicitly rewarded.

---

# 8. Informational Findings

---

## I-01 — Floating Pragmas in Interface and Library Files

**Affected files named by scan**

- `HashLib.sol`
- `IEcrecoverRatifier.sol`
- `ISetterRatifier.sol`
- `IEcrecoverAuthorizer.sol`

**Scan severity:** Informational

### Summary

Some interface/library files use floating pragma directives such as:

```solidity
pragma solidity ^0.8.0;
pragma solidity >=0.5.0;
```

Implementation contracts use fixed `0.8.34`.

### Impact

Compilation with older or unexpected compiler versions can introduce subtle differences or expose compiler bugs.

### Proposed Fix

Pin all security-critical files to:

```solidity
pragma solidity 0.8.34;
```

or at least:

```solidity
pragma solidity ^0.8.34;
```

---

## I-02 — Hardcoded TypeHash Values Not Verified On-Chain

**Affected file**

- `HashLib.sol`

**Scan severity:** Informational

### Summary

`HashLib` contains hardcoded typehash values for EIP-712 structures and offer tree heights. If any hardcoded value is wrong, signatures may fail or, in a worst case, validate against an unintended type.

### Affected Code Pattern

```solidity
function offerTreeTypeHash(uint256 height) internal pure returns (bytes32) {
    if (height <= 10) {
        if (height == 0) return 0x2b9ee710e1977dfc5778fe18c905ccc1d9e144baf3ba83be732d4da65ecb73e3;
        if (height == 1) return 0x3cc16189b92a85898f1d5c6e87282c8ded7c1c93b2323d5e85ae10c5f4b2b220;
        ...
    }
}
```

### Proposed Fix

Add test/deployment verification for all hardcoded typehashes:

```solidity
function verifyTypeHashes() external pure returns (bool) {
    bytes32 expected0 = keccak256(bytes.concat(
        "OfferTree(Offer[2] offerTree)",
        COLLATERAL_PARAMS_TYPE,
        MARKET_TYPE,
        OFFER_TYPE
    ));

    assert(HashLib.offerTreeTypeHash(0) == expected0);

    return true;
}
```

### Audit Triage Notes

This is best converted into a test coverage recommendation unless a concrete mismatch is found.

---

## I-03 — No Event Emitted for `isRatified` Calls

**Affected files**

- `EcrecoverRatifier.sol`
- `SetterRatifier.sol`

**Scan severity:** Informational

### Summary

`isRatified` functions do not emit events when ratification succeeds or fails. This reduces independent auditability of the ratification layer.

### Affected Code Pattern

```solidity
function isRatified(Offer memory offer, bytes memory ratifierData) external view returns (bytes32) {
    require(msg.sender == MIDNIGHT, NotMidnight());
    ...
    return CALLBACK_SUCCESS;
}
```

### Important Note

Because `isRatified` is a `view` function, it cannot emit events. The scan itself notes this.

### Proposed Alternatives

1. Rely on `MIDNIGHT` trade execution events.
2. Use off-chain transaction tracing.
3. Only make `isRatified` non-view if the protocol deliberately wants ratifier-level event logs.

---

## I-04 — `IEcrecoverAuthorizer` Uses Overly Broad Pragma

**Affected file**

- `IEcrecoverAuthorizer.sol`

**Scan severity:** Informational

### Summary

`IEcrecoverAuthorizer.sol` uses:

```solidity
pragma solidity >=0.5.0;
```

This permits compilation with very old compiler versions.

### Impact

This is an operational/code-quality risk. It overlaps with I-01 but is more specific.

### Proposed Fix

```solidity
pragma solidity 0.8.34;
```

or:

```solidity
pragma solidity ^0.8.0;
```

---

# 9. Audit Validation Plan

Use this section to convert the AI scan into real competition work.

## 9.1 Must-Validate Before Submitting

```text
M-01 cancellation front-running:
- Verify whether docs promise cancellation protection.
- Determine whether this is just normal off-chain orderbook MEV.
- Build mempool-ordering test or explain realistic ordering.

M-02 unbounded collateralParams:
- Verify actual call order in Midnight.take.
- Check if touchMarket bounds collateralParams before ratifier call.
- If bounded before ratifier, mark false positive.

M-03 delegate de-ratification:
- Verify intended meaning of Midnight authorization.
- Look for docs saying delegates are scoped or unscoped.
- Determine whether official periphery encourages risky delegation.

L-02 proof length:
- Verify proof.length behavior in SetterRatifier.
- Test long proof gas.
- Check whether long proof can be valid against an approved root.

L-04 zero maker:
- Verify whether offer.maker == address(0) can pass Midnight.take.
- Verify whether address(0) can authorize delegates.
```

## 9.2 Likely False Positives or Weak Submissions

These are probably weak without extra evidence:

```text
- Front-running cancellation as generic MEV risk.
- Unbounded collateralParams if core validates length first.
- Authorized delegate can de-ratify if authorization is intentionally broad.
- Irreversible cancellation if documented as intended.
- No event in view function.
- Floating pragma if build config pins compiler.
```

## 9.3 Strongest PoC Candidates

Start here:

```text
1. SetterRatifier proof length inconsistency
2. Authorized delegate cancellation / de-ratification scope
3. Zero-address maker reachability
4. Oversized collateralParams through actual Midnight.take path
```

The best outcome is not necessarily confirming the Hashlock findings. The best outcome is using them as a map to find deeper protocol-specific issues.

---

# 10. Foundry PoC Checklist

Create:

```text
test/poc/PoC_RatifierRootControl.t.sol
test/poc/PoC_SetterProofLength.t.sol
test/poc/PoC_EcrecoverSignatureMalleability.t.sol
test/poc/PoC_ZeroMaker.t.sol
test/poc/PoC_HashMarketBounds.t.sol
```

## 10.1 `PoC_RatifierRootControl.t.sol`

Test cases:

```text
test_delegateCanDeratifySetterRoot()
test_delegateCanCancelEcrecoverRoot()
test_makerCannotRecoverCanceledRoot()
```

Assertions:

```text
- offer valid before de-ratification/cancellation
- offer invalid after delegate action
- cancellation cannot be reversed
```

## 10.2 `PoC_SetterProofLength.t.sol`

Test cases:

```text
test_setterAcceptsProofLengthAbove20IfMerkleValidOrLoops()
test_setterLongProofGasCost()
test_ecrecoverProofAbove20RevertsViaTreeTooHigh()
```

Assertions:

```text
- Setter path lacks proof length cap
- Ecrecover path has cap through offerTreeTypeHash
- gas difference measured
```

## 10.3 `PoC_EcrecoverSignatureMalleability.t.sol`

Test cases:

```text
test_malleableSignatureRecoversSameSigner()
```

Assertions:

```text
- original signature passes
- high-s counterpart also passes
```

This likely proves low severity only.

## 10.4 `PoC_ZeroMaker.t.sol`

Test cases:

```text
test_zeroMakerRejectedByMidnightTake()
test_zeroMakerRatifierBehaviorIfReachable()
test_zeroAddressAuthorizationImpossibleOrPossible()
```

Assertions:

```text
- If Midnight rejects zero maker, mark AI finding false positive.
- If not, check whether meaningful impact exists.
```

## 10.5 `PoC_HashMarketBounds.t.sol`

Test cases:

```text
test_oversizedCollateralParamsRejectedBeforeRatifier()
test_oversizedCollateralParamsCanReachRatifier()
```

Assertions:

```text
- Identify whether M-02 is valid or false positive.
```

---

# 11. Cantina Submission Template for Validated Items

Use only after real validation.

```markdown
## Summary

[One sentence: who can do what, under what condition, causing what loss or broken invariant.]

## Finding Description

[Explain the intended security guarantee. Explain the exact code path. Explain why existing checks do not prevent it. Include the malicious input flow.]

## Impact Explanation

[Explain funds at risk, operational disruption, accounting corruption, or liveness impact. Map to Cantina impact.]

## Likelihood Explanation

[Explain prerequisites: authorization, public mempool, specific ratifier, maker behavior, market state, proof construction, gas assumptions.]

## Proof of Concept

```bash
forge test --match-test test_POC_<Name> -vvvv
```

[Paste test code or trace summary.]

## Recommendation

[Minimal fix and regression test.]
```

---

# 12. Final Research Priority

For winning severity, do **not** spend too much time on pure gas/informational findings. Use this scan mainly to guide deeper tests around authorization and ratifier assumptions.

Priority order:

```text
1. Validate whether oversized collateralParams reaches HashLib before Midnight bounds.
2. Validate SetterRatifier proof length inconsistency.
3. Validate delegate root cancellation/de-ratification against intended auth model.
4. Validate zero maker reachability.
5. Prove or dismiss signature malleability impact.
6. Save gas/informational items only if the competition accepts low/gas reports.
```

---

# 13. Original Scan Metadata Preserved

```text
Date shown: 5/30/2026
Files shown: 6 files
Issues shown: 13 issues found
Visibility: Public
Tool: Hashlock AI Audit
Disclaimer shown: AI-generated scan may contain inaccuracies and false positives.
Target title: DeFi Protocol - Offer Ratification / Authorization System
```
