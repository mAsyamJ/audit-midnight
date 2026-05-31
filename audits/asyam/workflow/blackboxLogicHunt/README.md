# Midnight Blackbox Logic Hunt

Date: 2026-05-31

## Purpose

This workspace is an authorized whitehat search for net-new Morpho Midnight logic and economic failures. It starts
after the direct AP queue and the first composition queue were closed. The corpus is a hypothesis map and PoC backlog,
not a finding list.

## Rules

- Treat `src/*`, protocol-authored `test/*`, and `protocolIntent/*` as the behavioral truth.
- Do not reopen a closed class without a different root cause and invariant target.
- Do not treat Hashlock AI text or audited JSON reports as new findings.
- Keep exploratory proofs under `test/asyam/poc/blackbox/`.
- Promote only compiling, deduplicated regressions with concrete impact into `test/asyamFindings/`.
- Reject self-DoS, chosen-market risk, malicious-token-only behavior, admin-only behavior, and dust-only effects unless
  a PoC demonstrates loss to a non-consenting user.

## Baseline

| Command | Log |
|---|---|
| `forge build` | `baseline_build.log` |
| `forge test -vvv` | `baseline_full_tests.log` |
| `forge test --match-path 'test/asyam/poc/composition/*.sol' -vvvv` | `baseline_composition_tests.log` |
| `forge test --match-path 'test/asyam/poc/PoC_*.sol' -vvvv` | `baseline_poc_tests.log` |

## Highest-Value New Angles

1. Lazy stored position updates causing a later material branch flip.
2. Recoverable debt being socialized after a multi-transaction collateral or liquidation sequence.
3. Bundle calls satisfying explicit arguments while violating a distinct economic intent.
4. Authorization reuse across core, ratifier, authorizer, and bundler surfaces.
5. Aggregate token backing across permissionless markets, including token-global settlement fees.
6. Permissionless-market risk crossing a missing non-consenting-user boundary.

## Files

- `00_PRIOR_WORK_EXCLUSION_MAP.md`: closed-class filter.
- `01_DIFFERENT_ANGLE_THREAT_MODEL.md`: logic-manipulation threat model.
- `02_BUSINESS_LOGIC_ATTACKS.md`: protocol-intent hypotheses.
- `03_STATE_MACHINE_DESYNC_ATTACKS.md`: duplicated-state and delayed-update hypotheses.
- `04_ACCOUNTING_DISCONTINUITY_HUNT.md`: threshold and timing targets.
- `05_INCENTIVE_AND_MARKET_MANIPULATION_HUNT.md`: rational strategy search.
- `06_PERMISSIONLESS_MARKET_ASSUMPTION_BREAKS.md`: consent-boundary search.
- `07_NON_OBVIOUS_MULTI_TX_STRATEGIES.md`: ordered transaction sequences.
- `08_PROTOCOL_ASSUMPTION_INVERSION.md`: assumption inversions.
- `09_COMPOSITE_INVARIANT_FUZZ_TARGETS.md`: later invariant campaigns.
- `10_BLACKBOX_POC_BACKLOG.md`: executable backlog.
- `11_VALIDATION_AND_DISPROOF_RULES.md`: promotion gate.
- `12_EXECUTION_PLAN.md`: PoC order and commands.
- `blackbox_logic_hunt_graph.json`: machine-readable summary.
- `POC_RESULTS.md`: implemented blackbox probe and invariant classifications.
