# Validated Findings

Date: 2026-05-30

## PoC Validation

Last validated: 2026-05-30

```bash
forge test --match-path 'test/asyamFindings/*.sol' -vvv
```

Result: 3/3 tests passed (2 signature malleability, 1 role setter bricking).

## Cantina Submissions

| ID | Submission file | Likelihood | Impact | Severity |
|---|---|---|---|---|
| L-01 | [cantina-L01-signature-malleability.md](cantina-L01-signature-malleability.md) | Medium | Low | Low |
| P3-01 | [cantina-P3-01-role-setter-bricking.md](cantina-P3-01-role-setter-bricking.md) | Low | Low | Low |

Competition: [Cantina Midnight overview](https://cantina.xyz/code/4679e0fa-85f7-4ea5-8827-ee6c70bdee6b/overview)

---

## L-01: ECDSA signatures are accepted in malleated high-s form

### Summary

`EcrecoverRatifier` and `EcrecoverAuthorizer` recover signers with raw `ecrecover` and do not reject high-s signatures. A valid low-s signature can therefore be transformed into a different high-s signature that recovers the same signer and is accepted by the protocol.

### Impact

This breaks unique-signature assumptions for integrations or monitoring that deduplicate, index, or authorize by raw signature bytes. The direct on-chain impact is low because the authorizer nonce still prevents replay of the same authorization after successful execution, and the ratifier validates the signed offer root.

### Proof

Validation tests:

```text
test/asyamFindings/PoC_SignatureMalleability.t.sol
```

The PoC:

- signs a valid ratifier root / authorization digest
- computes `s' = secp256k1n - s` and flips `v`
- asserts the new signature is high-s
- shows both `EcrecoverRatifier.isRatified` and `EcrecoverAuthorizer.setIsAuthorized` accept the malleated signature

### Recommendation

Use OpenZeppelin `ECDSA.recover`, Solady `ECDSA`, or equivalent checks that reject high-s values and invalid `v` values before accepting the recovered signer.

### Cantina submission

Full report: [cantina-L01-signature-malleability.md](cantina-L01-signature-malleability.md)

## P3-01: `roleSetter` can be irreversibly set to `address(0)`

### Summary

`Midnight.setRoleSetter` accepts any address, including `address(0)`. Once `roleSetter` is zero, no account can pass `OnlyRoleSetter`, so role administration is permanently bricked.

### Impact

This is an operational footgun rather than an external attacker path. A mistaken or compromised role setter can permanently disable updates to `roleSetter`, `feeSetter`, `feeClaimer`, and `tickSpacingSetter`.

### Proof

Validation test:

```text
test/asyamFindings/PoC_RoleSetterBricking.t.sol
```

The PoC sets `roleSetter` to zero, then proves all role-management setters revert with `OnlyRoleSetter`.

### Recommendation

Reject `address(0)` in `setRoleSetter`, or use a two-step ownership transfer pattern with explicit acceptance by the new role setter.

### Cantina submission

Full report: [cantina-P3-01-role-setter-bricking.md](cantina-P3-01-role-setter-bricking.md)
