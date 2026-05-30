# PoC Results

Date: 2026-05-30

## Validation command

```bash
forge test --match-path 'test/asyam/**/*.sol' -vvv
```

Result: **19/19 passed** (7 PoC suites, 4 invariant suites, migrated L-01/P3-01 PoCs).

```bash
forge test --match-path 'test/asyamFindings/*.sol' -vvv
```

Result: **13/13 passed** (validated Cantina PoCs plus promoted priority live-queue regressions).

## Priority queue outcomes

| Candidate | PoC file | Status | Notes |
|---|---|---|---|
| MIDNIGHT-CAND-026 | `test/asyam/poc/PoC_BundleTemporaryBalanceReentrancy.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol` | **disproven** | Fixed-amount transfers preserve outer first-leg proceeds during a nested sell bundle; observed refund float cannot be extracted; scoped to standard-token assumptions |
| MIDNIGHT-CAND-014 | `test/asyam/poc/PoC_TakeCallbackReentrancy.t.sol` | **disproven** | Buy-callback reentry does not profit attacker; consumed cap enforced on double-take |
| MIDNIGHT-CAND-005 | `test/asyam/poc/PoC_OfferConsumedCapRounding.t.sol` | **duplicate** | Shared `maxUnits`/`maxAssets` caps enforced; aligns with Blackthorn L-5 mitigation in current code |
| MIDNIGHT-CAND-012 | `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol` | **disproven** | Reduce-only buy fill cannot create one wei of maker credit; overfill reverts with `MakerCreditOrDebtIncreased` |
| MIDNIGHT-CAND-029 | `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol` | **invalid** | Units-target total budget below `filledBuyerAssets + referralFeeAssets` reverts atomically; exact budget succeeds without router residual |
| MIDNIGHT-CAND-031 | `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol` | **disproven** | Same-token repay callback, leverage unwind, and liquidation-from-seized-collateral paths keep custody sufficient under standard-token assumptions |
| L-01 | `test/asyam/poc/PoC_SignatureMalleability.t.sol` | **proven** | Cantina submission exists |
| P3-01 | `test/asyam/poc/PoC_RoleSetterBricking.t.sol` | **proven** | Cantina submission exists |
| P3-02 | `test/asyam/poc/PoC_SolvencySpecMarketIdAliasing.t.sol`, `test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol` | **proven** | Production creates two distinct supported markets while the solvency CVL summary aliases them; formal-assurance gap, not a production fund-loss claim |

Dedicated C-36 logs:

```text
audits/asyam/workflow/formal_gap_exploratory.log
audits/asyam/workflow/formal_gap_validation.log
```

## Invariant suite

```bash
forge test --match-path 'test/asyam/invariant/*.sol' -vvvv
```

Log: `audits/asyam/workflow/invariant_tests.log`

All 4 invariant files pass (6 tests total).

## Finding gate

No new H/M Cantina findings written — priority live-queue items did not demonstrate novel fund loss or accounting corruption beyond prior audit coverage. P3-02 records a distinct formal-assurance gap in `Solvency.spec`.

## Lower-priority queue closure

| Candidate | Status | Closure evidence |
|---|---|---|
| MIDNIGHT-CAND-013 | **disproven/covered** | Native fee breakpoint/interpolation tests plus `SettlementFeeBoundaries.spec` |
| MIDNIGHT-CAND-020 | **disproven/covered** | Native partial repay/withdraw fuzz tests plus exact withdrawable CVL deltas |
| MIDNIGHT-CAND-021 | **duplicate** | Spearbit loss-index/fee-rounding corpus, Blackthorn M-1/L-9, current terminal-take guard |
| MIDNIGHT-CAND-022 | **duplicate-risk closed** | Intended repay callback flow; no novel unauthorized extraction beyond Blackthorn L-19/L-26 |
| MIDNIGHT-CAND-033 | **disproven/covered** | Native bitmap lifecycle tests plus `CollateralBitmap.spec` storage mirror |
| MIDNIGHT-CAND-034 | **duplicate** | Spearbit rounding corpus and Blackthorn L-9; no novel profitable amplification |

## Test ownership

- Protocol-authored tests are read-only executable design evidence.
- Exploratory hypotheses and attack probes live under `test/asyam`.
- Stable regressions for validated findings or closed priority queues live under `test/asyamFindings`.
