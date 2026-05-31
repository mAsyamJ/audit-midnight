# Validated Findings

**Agent role:** [../.AGENTROLE.md](../.AGENTROLE.md)

Validated finding index only — not a candidate backlog.

Date: 2026-05-31

## PoC Validation

Last validated: 2026-05-31

### Full repository

```bash
forge test -vvv
```

Result: **485/485 tests passed**.

### Exploratory PoCs (`test/asyam/poc/`)

```bash
forge test --match-path 'test/asyam/poc/**/*.sol' -vvvv
```

Result: **91/91 tests passed**.

See [../workflow/POC_RESULTS.md](../workflow/POC_RESULTS.md) and [../candidates/CANDIDATES.md](../candidates/CANDIDATES.md).

## Submit-Ready Low/Gas/Informational

| ID | Submission file | Likelihood | Impact | Severity |
|---|---|---|---|---|
| L-01 | [cantina-L01-signature-malleability.md](cantina-L01-signature-malleability.md) | Medium | Low | Low |
| P3-02 | [cantina-P3-02-solvency-spec-market-id-aliasing.md](cantina-P3-02-solvency-spec-market-id-aliasing.md) | Medium | Low | Informational / P3 |

## Hold / Do Not Submit

| ID | Packet | Decision | Severity ceiling |
|---|---|---|---|
| P3-01 | [cantina-P3-01-role-setter-bricking.md](cantina-P3-01-role-setter-bricking.md) | Hold for manual admin-only scope review | Low at most |
| L-02 | [cantina-L02-tiny-repay-liquidation-gas-grief.md](cantina-L02-tiny-repay-liquidation-gas-grief.md) | Hold for manual duplicate review | Gas / Informational, Low at most |
| L-03 | [cantina-L03-rcf-topup-liquidation-gas-grief.md](cantina-L03-rcf-topup-liquidation-gas-grief.md) | Do not submit: intended RCF branch behavior | Informational |

See [../submissionReview/README.md](../submissionReview/README.md) for the final
decision matrix and archive.

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

## Disproven H/M Candidates

The attack-plan, composition, blackbox, and historical escalation queues did not
produce a new deduplicated High or Medium issue. In particular:

- adaptive liquidation closes the L-02 and L-03 escalation theories;
- callback accounting closes self-liquidation incentive capture;
- cross-market, fee/loss-factor, bundle, Permit2, oracle/gate, and same-token
  compositions did not demonstrate material loss.

Full archive:
[../submissionReview/05_DO_NOT_SUBMIT_ARCHIVE.md](../submissionReview/05_DO_NOT_SUBMIT_ARCHIVE.md).

## Commands to Reproduce

```bash
forge build
forge test -vvv
forge test --match-path 'test/asyam/poc/**/*.sol' -vvvv
forge test --match-path test/asyamFindings/PoC_SignatureMalleability.t.sol -vvv
forge test --match-path test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol -vvvv
```

Detailed packet commands:
[../submissionReview/07_PROOF_COMMANDS_AND_TEST_STATUS.md](../submissionReview/07_PROOF_COMMANDS_AND_TEST_STATUS.md).

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

## P3-02: CVL summaries alias production-distinct market IDs

### Summary

The solvency CVL summary derives market IDs from only loan token, maturity, chain ID, and Midnight address. `NoDivisionByZero.spec` compares only the first three collateral entries when identifying its global market. Production IDs include the complete encoded market configuration. Distinct supported markets can therefore collapse into one modeled identity.

### Impact

This is a formal-assurance gap, not a demonstrated production fund-loss exploit. Valid multi-market traces can be pruned by contradictory collateral-token assumptions or collapsed into one modeled accounting bucket, so the current proof does not establish its advertised breadth.

### Proof

Validation test:

```text
test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol
```

The PoC validates both mismatches: two supported single-collateral markets alias under the solvency tuple, and two supported four-collateral markets that differ at index `3` alias under the `NoDivisionByZero.spec` predicate. Production IDs remain distinct and all markets are created.

### Recommendation

Key the affected summaries by the complete encoded market configuration. The existing `certora/helpers/Utils.sol::hashMarket` helper can provide the full market hash.

### Cantina submission

Full report: [cantina-P3-02-solvency-spec-market-id-aliasing.md](cantina-P3-02-solvency-spec-market-id-aliasing.md)

---

## Agent maintenance

When a finding is proven or disproven:

1. Update this file
2. Update [../workflow/POC_RESULTS.md](../workflow/POC_RESULTS.md)
3. Update [../candidates/CANDIDATES.md](../candidates/CANDIDATES.md) status
4. Refresh current snapshot in [../.AGENTROLE.md](../.AGENTROLE.md)
