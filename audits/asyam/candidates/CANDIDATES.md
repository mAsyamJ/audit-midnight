# Midnight Candidate Registry

Date: 2026-05-30

Canonical candidate list for the Cantina audit continuation. See [../workflow/POC_RESULTS.md](../workflow/POC_RESULTS.md) for PoC outcomes.

Status values: `untested` | `testing` | `proven` | `disproven` | `duplicate` | `invalid`

---

### MIDNIGHT-CAND-001 — Zero oracle price bad liquidation

- **Status:** duplicate
- **Source:** Spearbit Medium, audited JSON
- **Files:** `src/Midnight.sol` (`liquidate`, `isHealthy`)
- **Functions:** `liquidate`, `_collateralValue`
- **Hypothesis:** Zero oracle price enables division-by-zero or free bad-debt realization.
- **Invariant possibly broken:** Liquidation only on liquidatable positions.
- **Attack prerequisites:** Market with zero-price oracle.
- **Expected impact:** Bad debt socialization / unfair liquidation.
- **Expected likelihood:** Medium (permissionless markets).
- **Dedup notes:** Spearbit Medium; Blackthorn L-10 related.
- **PoC plan:** Oracle set to 0, liquidate with zero repay.
- **Current result:** Do not PoC; duplicate-known.

---

### MIDNIGHT-CAND-002 — Market created before default fees configured

- **Status:** duplicate
- **Source:** Spearbit Medium
- **Files:** `src/Midnight.sol` (`touchMarket`)
- **Hypothesis:** First touch creates market with stale zero fees.
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-003 — Pending fee rounding dust amplification

- **Status:** duplicate
- **Source:** Spearbit Low, Blackthorn L-9
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-004 — Near-maturity unconsented seller debt

- **Status:** duplicate
- **Source:** Blackthorn M-2
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-005 — Grouped offer shared cap overfill via rounding

- **Status:** duplicate
- **Source:** Blackthorn L-5, code
- **Files:** `src/Midnight.sol` (`take`, `consumed`)
- **Functions:** `take`
- **Hypothesis:** Rounding allows `consumed[maker][group]` to exceed `maxAssets`/`maxUnits`.
- **Invariant possibly broken:** Shared group cap.
- **PoC plan:** `test/asyam/poc/PoC_OfferConsumedCapRounding.t.sol`
- **Current result:** **duplicate/disproven** — caps enforced in current code.

---

### MIDNIGHT-CAND-006 — Terminal lossFactor fresh lender slash

- **Status:** duplicate
- **Source:** Blackthorn M-1, Spearbit
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-007 — Hardfork obligation ID change

- **Status:** duplicate
- **Source:** Blackthorn L-1
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-008 — Delegated ratifier excessive authority

- **Status:** duplicate
- **Source:** Spearbit/Blackthorn L-16
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-009 — Callback actor binding fund drain

- **Status:** duplicate
- **Source:** Blackthorn L-19
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-010 — Zero-unit take callback replay

- **Status:** duplicate
- **Source:** Blackthorn L-20
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-011 — Optimistic bad-debt socialization at zero cost

- **Status:** duplicate
- **Source:** Blackthorn L-10
- **Current result:** Duplicate-known unless non-oracle path found.

---

### MIDNIGHT-CAND-012 — take() reduceOnly bypass via rounding

- **Status:** disproven
- **Source:** code, Certora gap
- **Files:** `src/Midnight.sol`
- **Functions:** `take`
- **Hypothesis:** Rounding lets debt/credit increase on reduce-only offers.
- **Invariant possibly broken:** `reduceOnly` forbids maker credit/debt increase.
- **PoC plan:** `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol`
- **Current result:** **disproven** — the core guard checks unit-side credit/debt deltas before callbacks. Protocol-authored buy/sell fuzz tests and the audit probes confirm a reduce-only buy fill can reduce maker debt to zero, while a one-wei overfill reverts with `MakerCreditOrDebtIncreased` rather than creating maker credit.

---

### MIDNIGHT-CAND-013 — take() settlement fee at maturity boundary

- **Status:** disproven
- **Source:** code
- **Functions:** `take`, `settlementFee`
- **Hypothesis:** Fee bucket boundary causes unexpected revert or zero-price seller side.
- **Current result:** **disproven/covered** — `settlementFee` uses explicit piecewise intervals with exact breakpoint behavior. Protocol-authored `SettersTest` covers every exact breakpoint plus interpolation midpoints, `SettlementFeeTest` covers post-maturity and early-settlement take behavior, and `SettlementFeeBoundaries.spec` checks breakpoint equality and adjacent-bound enclosure. No distinct implementation path remains.

---

### MIDNIGHT-CAND-014 — take() state-before-transfer callback reentrancy

- **Status:** disproven
- **Source:** code, Hashlock
- **Files:** `src/Midnight.sol`, callbacks
- **Functions:** `take`
- **Hypothesis:** Buy callback reenters before transfer to corrupt accounting.
- **Invariant possibly broken:** Consumed caps / solvency.
- **PoC plan:** `test/asyam/poc/PoC_TakeCallbackReentrancy.t.sol`
- **Current result:** **disproven** — no attacker profit; caps hold.

---

### MIDNIGHT-CAND-015 — take() grouped cap edge at maxAssets=0/maxUnits>0

- **Status:** duplicate
- **Source:** code
- **PoC plan:** Covered by MIDNIGHT-CAND-005.
- **Current result:** duplicate/disproven.

---

### MIDNIGHT-CAND-016 — liquidate() inactive collateral index

- **Status:** duplicate
- **Source:** Spearbit Low
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-017 — liquidate() post-maturity LLTV=WAD no incentive

- **Status:** duplicate
- **Source:** Blackthorn L-4
- **Current result:** Duplicate-known.

---

### MIDNIGHT-CAND-018 — liquidate() zero-repay bad debt over-realization

- **Status:** duplicate
- **Source:** Blackthorn L-10, deep-research
- **Hypothesis:** Zero-repay liquidation socializes bad debt under weak oracle.
- **Current result:** Duplicate/design-dependent on oracle trust.

---

### MIDNIGHT-CAND-019 — liquidate() liquidation lock bypass

- **Status:** disproven
- **Source:** code, `TakeTest` nested liquidate tests
- **Current result:** Seller liquidation lock holds during sell callbacks.

---

### MIDNIGHT-CAND-020 — withdraw() withdrawable over-claim after partial repay

- **Status:** disproven
- **Source:** code, Certora WithdrawableMonotonicity
- **Current result:** **disproven/covered** — `repay` increases `withdrawable` by the pulled units and `withdraw` decreases it before transfer, reverting on underflow if over-claimed. Protocol-authored `OtherFunctionsTest.testRepay` and `testWithdraw` fuzz partial repay/withdraw accounting; `WithdrawableMonotonicity.spec` checks exact deltas.

---

### MIDNIGHT-CAND-021 — updatePosition() terminal lossFactor pendingFee desync

- **Status:** duplicate
- **Source:** code
- **Current result:** **duplicate-risk closed** — terminal `lossFactor` behavior is covered by Spearbit loss-index findings and Blackthorn M-1, while fee slash rounding is covered by Spearbit and Blackthorn L-9. Current `take` rejects `lossFactor == type(uint128).max`; protocol-authored liquidation and continuous-fee tests exercise slash synchronization.

---

### MIDNIGHT-CAND-022 — repay() callback-before-pull reentrancy

- **Status:** duplicate
- **Source:** code
- **Current result:** **duplicate-risk closed** — the callback can compose against the state-before-pull repayment window, but each successful outer repayment still pulls its units after callback return. Native `testRepayCallback` covers the intended callback flow. The reviewed lender-withdraw composition only permits voluntarily funded claim conversion; no unauthorized extraction path distinct from Blackthorn L-19/L-26 was found.

---

### MIDNIGHT-CAND-023 — ECDSA high-s signature malleability

- **Status:** proven
- **Source:** code, Hashlock L-01
- **Files:** `EcrecoverRatifier.sol`, `EcrecoverAuthorizer.sol`
- **PoC plan:** `test/asyam/poc/PoC_SignatureMalleability.t.sol`
- **Current result:** **proven Low** — Cantina doc at `findings/cantina-L01-signature-malleability.md`.

---

### MIDNIGHT-CAND-024 — roleSetter zero address bricking

- **Status:** proven
- **Source:** code
- **Files:** `src/Midnight.sol`
- **PoC plan:** `test/asyam/poc/PoC_RoleSetterBricking.t.sol`
- **Current result:** **proven Low/admin footgun** — Cantina doc at `findings/cantina-P3-01-role-setter-bricking.md`.

---

### MIDNIGHT-CAND-025 — Delegate root griefing via authorized operator

- **Status:** duplicate
- **Source:** Blackthorn L-16 / M-03 Hashlock
- **Current result:** Accepted broad delegation semantics.

---

### MIDNIGHT-CAND-026 — Bundler temporary loan-token balance theft

- **Status:** disproven
- **Source:** Hashlock High-02, code
- **Files:** `src/periphery/MidnightBundles.sol`
- **Functions:** `supplyCollateralAndSellWithUnitsTarget`, `supplyCollateralAndSellWithAssetsTarget`
- **Hypothesis:** Reentrant callback steals `loanToken.balanceOf(bundler)` mid-loop.
- **Invariant possibly broken:** Bundle payout matches filled amounts only.
- **PoC plan:** `test/asyam/poc/PoC_BundleTemporaryBalanceReentrancy.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol`
- **Current result:** **disproven** under the standard-token assumption — transfers use computed per-call amounts and the router does not approve callbacks to drain its balance. The promoted validation confirms both that a seller callback cannot extract an observed refund float and that a nested sell bundle cannot spend outer first-leg proceeds parked in the router. Token-hook reentry remains outside the protocol's stated token assumptions.

---

### MIDNIGHT-CAND-027 — Mixed-market bundle collateral mismatch

- **Status:** invalid
- **Source:** Hashlock, strategy doc
- **Files:** `MidnightBundles.sol`
- **Current result:** **invalid** — `InconsistentMarket` enforced (`MidnightBundlesTest`).

---

### MIDNIGHT-CAND-028 — Exact-fill TakeAmountsLib vs core divergence

- **Status:** duplicate
- **Source:** Blackthorn L-6/L-7
- **Current result:** Duplicate-risk; existing bundle tests cover common paths.

---

### MIDNIGHT-CAND-029 — Referral fee exact-fill boundary break

- **Status:** invalid
- **Source:** Hashlock Medium-01
- **PoC plan:** `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol`
- **Current result:** **invalid** — `buyWithUnitsTargetAndWithdrawCollateral` intentionally treats `maxBuyerAssets` as the total budget. `requiredBudget - 1` reverts atomically while paying the referral, and the exact `requiredBudget` succeeds with no router residual. The asset-target route also handles an extreme `WAD - 1` referral fee without residual.

---

### MIDNIGHT-CAND-030 — Gate liveness trap via callback state change

- **Status:** invalid
- **Source:** Hashlock
- **Hypothesis:** Market-chosen gate blocks exit after callback.
- **Current result:** Accepted market-design risk.

---

### MIDNIGHT-CAND-031 — Same loan token as collateral self-loop

- **Status:** disproven
- **Source:** SOL-Defi-Lending-10
- **PoC plan:** `test/asyam/poc/PoC_DeepValidationQueues.t.sol`, `test/asyamFindings/Validation_LiveQueues.t.sol`
- **Current result:** **disproven** for the tested standard-token self-loop paths — same-token collateral can fund repay callback unwinds, two-step leverage can fully unwind, and liquidation can repay from seized same-token collateral while custody continues to back remaining collateral plus lender claims. Multi-collateral compositions and malicious token/oracle behavior remain separate queues.

---

### MIDNIGHT-CAND-032 — Permit2 cross-function replay

- **Status:** invalid
- **Source:** Hashlock
- **Current result:** Likely false positive (Permit2 nonces).

---

### MIDNIGHT-CAND-033 — Multi-collateral health bitmap desync

- **Status:** disproven
- **Source:** code
- **Current result:** **disproven/covered** — bitmap updates are paired with zero-to-nonzero supplies and full withdraw/liquidation clears. Protocol-authored `OtherFunctionsTest` covers activation caps, single/multiple bit state, full withdraw clearing, and full liquidation clearing across the configured maximum. `CollateralBitmap.spec` also proves the storage mirror invariant.

---

### MIDNIGHT-CAND-034 — Continuous fee + lossFactor rounding amplification

- **Status:** duplicate
- **Source:** code, Spearbit rounding
- **Current result:** **duplicate-risk closed** — the identified behavior maps to prior Spearbit pending-fee rounding findings and Blackthorn L-9 repeated-transfer fee reduction. Native `ContinuousFeeTest` exercises accrual, exits, slashes, and fee claims. No novel repeatable profit or accounting-corruption path was found.

---

### MIDNIGHT-CAND-035 — Empty takes[] bundle out-of-bounds

- **Status:** invalid
- **Source:** Hashlock Low-02
- **Current result:** Reverts on `takes[0]`; self-DoS only.

---

### MIDNIGHT-CAND-036 — Solvency CVL summary aliases production-distinct markets

- **Status:** proven
- **Source:** Certora model review
- **Files:** `certora/specs/Solvency.spec`, `src/libraries/IdLib.sol`
- **Functions:** `CVL_toId`, `IdLib.toId`
- **Hypothesis:** The solvency proof collapses distinct supported markets because its summarized ID omits most immutable market fields.
- **Invariant possibly broken:** The formal proof does not establish token solvency across all supported multi-market configurations.
- **PoC plan:** `test/asyam/poc/PoC_SolvencySpecMarketIdAliasing.t.sol`, `test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol`
- **Current result:** **proven P3 formal-assurance gap** — production creates two distinct markets with the same loan token and maturity but different collateral tokens, while the `Solvency.spec` summary aliases them. This can prune valid multi-market traces through contradictory collateral-token requirements. No production fund-loss exploit is claimed.

---

## Summary

| Status | Count |
|---|---|
| proven | 3 |
| disproven | 8 |
| duplicate | 20 |
| invalid | 5 |
| untested | 0 |

## Live queue

The current 36-candidate queue is classified. Priority live-queue attack probes are covered by `test/asyamFindings/Validation_LiveQueues.t.sol`; the remaining lower-priority hypotheses were closed against protocol-authored tests, CVL boundaries, source review, and prior-audit dedup.

No H/M finding should be filed without a passing PoC demonstrating novel impact.
