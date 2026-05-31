# Test Gap to Attack Plan

Date: 2026-05-30

Maps [../01_TEST_COVERAGE_GAP_MAP.md](../01_TEST_COVERAGE_GAP_MAP.md) gaps to `AP-XXX` and test paths.

| Gap # | Description | AP-XXX | Suggested test | Type |
|---|---|---|---|---|
| 1 | Callback reentrancy exhaustive | AP-001, AP-021 | `PoC_TakeCallbackReentrancy` (closed); new only if novel | unit |
| 2 | Periphery balance leakage | AP-014 | `PoC_BundleTemporaryBalanceReentrancy` | unit |
| 3 | Exact-fill helper vs core | AP-015 | fuzz `TakeAmountsLib` vs manual take | fuzz |
| 4 | Permit2 adversarial fuzz | AP-017 | closed invalid — optional regression fuzz | fuzz |
| 5 | Event reconstructibility | — | indexer replay test (P3) | integration |
| 6 | Same-token multi-collateral | AP-008 | extend `DeepValidationQueues` | unit |
| 7 | Stateful gate/oracle in callback | AP-018 | `PoC_StatefulGateCallback.t.sol` | unit |
| 8 | CVL market ID alias | AP-022 | `PoC_SolvencySpecMarketIdAliasing` | formal |
| 9 | Healthiness CVL take gap | — | retain Foundry take health tests | spec note |
| 10 | Repay callback composition | AP-021 | closed duplicate-risk per POC_RESULTS | — |
| 11 | Flash loan composition | AP-019 | `PoC_FlashLoanReentrancy.t.sol` | unit |
| 12 | Maturity fee bucket | AP-020 | warp fuzz at maturity | fuzz |
| 13 | Multi-collateral bitmap | AP-007 | closed C-033 — optional invariant extend | invariant |
| 14 | Terminal lossFactor fee | AP-010 | closed C-021 duplicate | `PoC_PendingFeeLossFactorSync.t.sol` |
| 15 | Withdrawable custody | AP-009 | partial repay sequence test | unit |

## Harness vs protocol tests

| Need adversarial probe | Use `test/asyam/poc/` |
| Need stable regression | Promote to `test/asyamFindings/` |
| Property over random sequences | `test/asyam/invariant/` |

Do **not** edit protocol-authored `test/TakeTest.sol` etc. to close candidates.
