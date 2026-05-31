# PoC Results

Date: 2026-05-30

## Validation command

```bash
forge test --match-path 'test/asyam/**/*.sol' -vvv
```

Result: **77/77 passed** (exploratory PoCs, composition probes, 4 invariant suites, migrated L-01/P3-01 PoCs).

```bash
forge test --match-path 'test/asyamFindings/*.sol' -vvv
```

Result: **14/14 passed** (validated Cantina PoCs plus promoted priority live-queue regressions).

## Priority queue outcomes

| Candidate | PoC file | Status | Notes |
|---|---|---|---|
| MIDNIGHT-CAND-026 | `test/asyam/poc/PoC_BundleTemporaryBalanceReentrancy.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol` | **disproven** | Fixed-amount transfers preserve outer first-leg proceeds during a nested sell bundle; observed refund float cannot be extracted; scoped to standard-token assumptions |
| MIDNIGHT-CAND-014 | `test/asyam/poc/PoC_TakeCallbackReentrancy.t.sol` | **disproven** | Buy-callback reentry does not profit attacker; consumed cap enforced on double-take |
| MIDNIGHT-CAND-005 | `test/asyam/poc/PoC_OfferConsumedCapRounding.t.sol` | **duplicate** | Shared `maxUnits`/`maxAssets` caps enforced; aligns with Blackthorn L-5 mitigation in current code |
| MIDNIGHT-CAND-012 | `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol` | **disproven** | Reduce-only buy fill cannot create one wei of maker credit; overfill reverts with `MakerCreditOrDebtIncreased` |
| MIDNIGHT-CAND-029 | `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol` | **invalid** | Units-target total budget below `filledBuyerAssets + referralFeeAssets` reverts atomically; exact budget succeeds without router residual |
| MIDNIGHT-CAND-031 | `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol` | **disproven** | Same-token repay callback, leverage unwind, and liquidation-from-seized-collateral paths keep custody sufficient under standard-token assumptions |
| AP-019 / MC-04 | `test/asyam/poc/PoC_FlashLoanReentrancy.t.sol` | **disproven** | Flash loan must reimburse; nested `take` during `onFlashLoan` and nested `withdraw` during `onRepay` do not steal loan tokens or break `totalUnits` accounting |
| AP-005 | `test/asyam/poc/PoC_LiquidationOverSeize.t.sol` | **disproven** | Seize/repay bounded by collateral and RCF; cumulative liquidations cannot exceed posted collateral |
| AP-006 | `test/asyam/poc/PoC_PostMaturityLiquidation.t.sol` | **disproven** | Post-maturity LIF/seize math respects collateral; healthy borrowers cannot be liquidated in normal mode after maturity |
| AP-011 | `test/asyam/poc/PoC_CanceledRootReuse.t.sol` | **disproven** | `cancelRoot` blocks `take`; unauthorized third parties cannot cancel foreign roots |
| AP-026 (liquidate callback) | `test/asyam/poc/PoC_LiquidateCallbackReentrancy.t.sol` | **disproven** | Nested `liquidate` in `onLiquidate` does not profit attacker or drain Midnight custody |
| AP-004 | `test/asyam/poc/PoC_LiquidationSolventBadDebt.t.sol` | **disproven** | Healthy borrowers not liquidatable; bad debt matches collateral shortfall; no loan-token extraction via zero-liquidation |
| AP-008 | `test/asyam/poc/PoC_LossFactorOverslash.t.sol` | **disproven/covered** | `lossFactor` slash tracks `totalUnits`; no extra slash without bad debt (Spearbit/Blackthorn M-1 duplicate-risk) |
| AP-015 | `test/asyam/poc/PoC_BundleExactFillAlignment.t.sol` | **disproven/covered** | `TakeAmountsLib` aligns with bundle fill; inconsistent markets rejected (L-6/L-7 duplicate-risk) |
| AP-018 | `test/asyam/poc/PoC_EnterGateForcedDebt.t.sol` | **disproven** | `enterGate` blocks non-consenting seller debt increases |
| AP-016 | `test/asyam/poc/PoC_BundleHelperRevertSemantics.t.sol` | **invalid/documented** | NatSpec requires bundle revert on lib failure; `take` skip only inside try/catch |
| AP-026 (sell callback) | `test/asyam/poc/PoC_SellCallbackComposition.t.sol` | **disproven** | Liquidation lock + post-maturity debt rules hold under sell-callback reentrancy |
| AP-010 | `test/asyam/poc/PoC_PendingFeeLossFactorSync.t.sol` | **duplicate/covered** | `updatePosition` matches `updatePositionView` after slash; terminal `take` blocked; `lastLossFactor` syncs on touch (C-021/C-034) |
| L-01 | `test/asyam/poc/PoC_SignatureMalleability.t.sol` | **proven** | Cantina submission exists |
| P3-01 | `test/asyam/poc/PoC_RoleSetterBricking.t.sol` | **proven** | Cantina submission exists |
| P3-02 | `test/asyam/poc/PoC_SolvencySpecMarketIdAliasing.t.sol`, `test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol` | **proven** | Production creates distinct supported markets while the solvency tuple and no-division-by-zero three-collateral prefix summaries alias them; formal-assurance gap, not a production fund-loss claim |

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

## Net-new composition hunt

```bash
forge test --match-path 'test/asyam/poc/composition/*.sol' -vvv
```

Result: **21/21 passed**.

Log: `audits/asyam/workflow/compositionHunt/composition_poc_tests.log`

Detailed classification: [compositionHunt/12_POC_RESULTS.md](compositionHunt/12_POC_RESULTS.md)

The composition campaign closed ratifier/periphery consumed-cap fallback, canceled-root exact targets, loss-factor fee
claim ordering, maturity liquidation flash callbacks, delegated Permit2 routing, shared-token cross-market callbacks,
reduce-only bundle fallback, callback-time root activation, fee-update stale routes, multi-collateral oracle/gate
liveness, post-maturity bad-debt withdrawal ordering, and fragmented-lender dust amplification. None demonstrated a
new non-duplicate High or Medium impact.

## Finding gate

No new H/M Cantina findings written — priority live-queue items did not demonstrate novel fund loss or accounting corruption beyond prior audit coverage. P3-02 records distinct formal-assurance identity-summary gaps in `Solvency.spec` and `NoDivisionByZero.spec`.

The final residual runtime pass also closed Permit2/ERC2612 operation-context misuse, router payer composition, exact-fill helper failure atomicity, ratifier proof-shape griefing, and persistent-state event replay. These closures rely on Midnight's documented standard-token assumptions and protocol-authored tests as intention evidence; native tests were kept read-only.

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

## Blackbox logic hunt

```bash
forge test --match-path 'test/asyam/poc/blackbox/*.sol' -vvv
forge test --match-path 'test/asyam/invariant/composite/*.sol' -vvv
```

Results: **9/9 blackbox PoCs passed** and **256/256 composite invariant fuzz runs passed**.

Detailed classification: [blackboxLogicHunt/POC_RESULTS.md](blackboxLogicHunt/POC_RESULTS.md)

This pass closed lazy-position stale withdrawal, recoverable bad-debt realization, bundle fallback intent bounds,
fee-change quote fallback, token-global fee custody across markets, and same-token collateral/loan/fee aggregate
accounting. An unused user-signed authorizer grant can restore an operator after direct revocation, but that trace is
kept as duplicate-risk or accepted signature semantics because the user created the capability and the behavior is
adjacent to prior broad/transitive revocation-delay coverage. No new deduplicated High or Medium issue was promoted.

Final verification after this pass: **87/87 exploratory tests**, **14/14 promoted validation tests**, and **474/474
repository tests** passed.

## Historical exploit-pattern implementation

Historical self-liquidation callback capture was tested with ordinary ERC20s and explicit borrower authorization:

```bash
forge test --match-path test/asyam/poc/historical/PoC_Hist_SelfLiquidationCallbackCapture.t.sol -vvvv
```

Result: **5/5 passed**.

The callback can re-supply seized collateral, fund nested repayment, and open replacement exposure through a new offer
group. These transitions remain fully charged: repayment claims are backed by real token pulls, replacement debt
creates matching credit, and bad-debt socialization matches a zero-input realization control. Callback-time
observation of pre-pull `withdrawable` does not enable post-liquidation extraction. HPH-POC-003 is closed as
**disproven / intended behavior**; no new finding draft was created.

## Final Low / Gas / Informational Submission Review

Date: 2026-05-31

Fresh verification:

```bash
forge build
forge test -vvv
forge test --match-path 'test/asyam/poc/**/*.sol' -vvvv
```

Results:

- `forge build`: passed.
- Full repository: **485/485 passed**.
- Exploratory PoC glob: **91/91 passed**.
- `git diff --check -- audits/asyam`: passed.

Final packet disposition is recorded below.

## Submit-Ready Low/Gas/Informational

| ID | Decision | Severity ceiling | Reason |
|---|---|---|---|
| L-01 | Submit | Low | Proven signature-canonicality defect without replay-based fund-loss claim |
| P3-02 | Submit | Informational | Proven CVL model mismatch without runtime exploit claim |

## Hold / Do Not Submit

| ID | Decision | Severity ceiling | Reason |
|---|---|---|---|
| P3-01 | Hold | Low at most | Admin-only operational footgun |
| L-02 | Hold | Gas / Informational, Low at most | Liquidation-specific gas grief with acknowledged front-run invalidation overlap |
| L-03 | Do not submit | Informational | Intended RCF branch transition; adaptive liquidation succeeds |

Review pack:
`audits/asyam/submissionReview/README.md`.

## Disproven H/M Candidates

All tested escalation queues remain closed. Composition, blackbox, and
historical probes did not demonstrate a new deduplicated High or Medium impact.

## Commands to Reproduce

```bash
forge build
forge test -vvv
forge test --match-path 'test/asyam/poc/**/*.sol' -vvvv
```
