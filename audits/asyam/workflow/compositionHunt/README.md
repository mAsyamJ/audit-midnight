# Midnight Net-New Composition Hunt

Date: 2026-05-30

## Purpose

This workspace is the post-attack-plan research handoff. The direct AP queue is closed. Every item here is a hypothesis, not a finding. A candidate is eligible for a later Foundry PoC only when it crosses at least two closed domains and targets a new state transition or invariant.

## Evidence Order

1. `src/*` and protocol-authored `test/*` are implementation and intent truth.
2. `../protocolIntent/*` is the economic-intent model.
3. `../attackPlan/*`, `../POC_RESULTS.md`, `../03_DEDUP_MAP.md`, `../../audited/*.json`, and `../../findings/*` are closure and dedup sources.
4. `../../hashlock/*` is hypothesis input only.

## Outputs

| File | Purpose |
|---|---|
| `00_CLOSED_QUEUE_DIGEST.md` | AP-001 through AP-026 closure boundary |
| `01_COMPOSITION_SEARCH_SPACE.md` | contract, state, actor, time, and value axes |
| `02_NET_NEW_ATTACK_COMPOSITIONS.md` | 30 cross-domain hypotheses |
| `03_CROSS_DOMAIN_SEQUENCE_MATRIX.md` | 50 concrete transaction sequences |
| `04_STATE_MACHINE_BREAKPOINTS.md` | external-call and state-ordering windows |
| `05_ROLE_COLLUSION_AND_AUTHORIZATION_COMPOSITIONS.md` | 20 multi-role hypotheses |
| `06_TEMPORAL_MATURITY_COMPOSITIONS.md` | 20 ordering and maturity sequences |
| `07_PERIPHERY_CORE_RATIFIER_COMPOSITIONS.md` | 20 three-domain hypotheses |
| `08_FORMAL_SPEC_BLINDSPOT_COMPOSITIONS.md` | 15 assurance boundaries |
| `09_CREATIVE_POC_BACKLOG.md` | top 15 later Foundry implementations |
| `10_DISPROOF_CRITERIA.md` | proof, disproof, duplicate, and intent gates |
| `11_EXECUTION_PLAN.md` | implementation order after this planning phase |
| `12_POC_RESULTS.md` | executed composition PoCs and classification |
| `composition_hunt_graph.json` | machine-readable research graph |

## Baseline

Fresh command output is saved in:

- `baseline_build.log`
- `baseline_tests.log`
- `existing_poc_tests.log`
- `composition_poc_tests.log`
- `final_build.log`
- `final_exploratory_tests.log`
- `final_validation_tests.log`
- `final_full_tests.log`

## Filing Gate

Do not write Cantina findings from this workspace. Promote only after a compiling Foundry PoC demonstrates concrete non-duplicate impact under the documented standard-token model.
