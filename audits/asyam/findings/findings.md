# Validated Findings

**Agent role:** [../.AGENTROLE.md](../.AGENTROLE.md)

Validated finding index only — not a candidate backlog.

Date: 2026-05-30

## PoC Validation

Last validated: 2026-05-30

### Legacy path (`test/asyamFindings/`)

```bash
forge test --match-path 'test/asyamFindings/*.sol' -vvv
```

Result: **13/13 tests passed**.

### Audit harness (`test/asyam/`)

```bash
forge test --match-path 'test/asyam/**/*.sol' -vvv
```

Result: **19/19 tests passed** (exploratory PoCs + invariants).

See [../workflow/POC_RESULTS.md](../workflow/POC_RESULTS.md) and [../candidates/CANDIDATES.md](../candidates/CANDIDATES.md).

## Cantina Submissions

| ID | Submission file | Likelihood | Impact | Severity |
|---|---|---|---|---|
| L-01 | [cantina-L01-signature-malleability.md](cantina-L01-signature-malleability.md) | Medium | Low | Low |
| P3-01 | [cantina-P3-01-role-setter-bricking.md](cantina-P3-01-role-setter-bricking.md) | Low | Low | Low |
| P3-02 | [cantina-P3-02-solvency-spec-market-id-aliasing.md](cantina-P3-02-solvency-spec-market-id-aliasing.md) | Medium | Low | Informational / P3 |

Competition: [Cantina Midnight overview](https://cantina.xyz/code/4679e0fa-85f7-4ea5-8827-ee6c70bdee6b/overview)

### Priority queue PoC outcomes (2026-05-30)

No new H/M findings. Priority candidates tested and closed:

| Candidate | Result | PoC |
|---|---|---|
| C-26 bundler temp balance theft | disproven | `test/asyam/poc/PoC_BundleTemporaryBalanceReentrancy.t.sol` |
| C-14 take callback reentrancy | disproven | `test/asyam/poc/PoC_TakeCallbackReentrancy.t.sol` |
| C-05 grouped cap overfill | duplicate | `test/asyam/poc/PoC_OfferConsumedCapRounding.t.sol` |
| C-12 reduce-only rounding | disproven | exploratory probe + promoted regression |
| C-29 referral exact-fill boundary | invalid total-budget hypothesis | exploratory probe + promoted fuzz regression |
| C-31 same loan/collateral token | scoped disproval under standard-token assumptions | exploratory probe + promoted repay/leverage/liquidation regressions |

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

## P3-02: `Solvency.spec` aliases production-distinct market IDs

### Summary

The solvency CVL summary derives market IDs from only loan token, maturity, chain ID, and Midnight address. Production IDs include the complete encoded market configuration. Distinct supported markets can therefore collapse into one modeled ID.

### Impact

This is a formal-assurance gap, not a demonstrated production fund-loss exploit. Valid multi-market traces can be pruned by contradictory collateral-token assumptions or collapsed into one modeled accounting bucket, so the current proof does not establish its advertised breadth.

### Proof

Validation test:

```text
test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol
```

The PoC creates two supported production markets with the same loan token and maturity but different collateral tokens. Production IDs differ and both markets are created; the reduced CVL summary tuple aliases them.

### Recommendation

Key `CVL_toId` by the complete encoded market configuration. The existing `certora/helpers/Utils.sol::hashMarket` helper can provide the full market hash.

### Cantina submission

Full report: [cantina-P3-02-solvency-spec-market-id-aliasing.md](cantina-P3-02-solvency-spec-market-id-aliasing.md)

---

## Agent maintenance

When a finding is proven or disproven:

1. Update this file
2. Update [../workflow/POC_RESULTS.md](../workflow/POC_RESULTS.md)
3. Update [../candidates/CANDIDATES.md](../candidates/CANDIDATES.md) status
4. Refresh current snapshot in [../.AGENTROLE.md](../.AGENTROLE.md)
