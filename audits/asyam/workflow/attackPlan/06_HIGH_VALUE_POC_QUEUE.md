# High-Value PoC Queue

Date: 2026-05-30

Primary handoff for PoC agents. **25+ entries.**

---

### AP-001 — Take callback monetizes temporary state

- **Status:** closed-disproven
- **Files/functions:** `Midnight.take`, `onBuy`/`onSell`
- **State variables:** `position`, `consumed`, `totalUnits`
- **Attacker roles:** taker + malicious callback
- **Setup:** `Config.t.sol`, funded callback payer
- **Attack sequence:** Reenter `take` during `onBuy`
- **Invariant:** INV-023
- **Expected impact:** Attacker profit or accounting break
- **Severity if true:** High
- **PoC feasibility:** med
- **Existing tests:** `PoC_TakeCallbackReentrancy.t.sol`
- **Links:** C-014, POC-INTENT-001

---

### AP-002 — Consumed cap bypass via rounding

- **Status:** closed-disproven
- **Files/functions:** `take`, `consumed`
- **Invariant:** INV-011
- **Severity if true:** Medium
- **Suggested test:** `PoC_OfferConsumedCapRounding.t.sol`
- **Links:** C-005, POC-INTENT-002

---

### AP-003 — reduceOnly increases maker exposure

- **Status:** closed-disproven
- **Files/functions:** `take` reduceOnly check
- **Invariant:** INV-012
- **Suggested test:** `PoC_DeepValidationQueues.t.sol`
- **Links:** C-012, POC-INTENT-003

---

### AP-004 — Bad debt on economically solvent borrower

- **Status:** closed-disproven (consenting-market / oracle-risk only)
- **Test:** `PoC_LiquidationSolventBadDebt.t.sol`
- **Files/functions:** `liquidate` badDebt loop
- **State variables:** `lossFactor`, `position.debt`
- **Attacker roles:** liquidator + market with mispriced oracle
- **Setup:** Consenting market vs forced victim
- **Attack sequence:** Liquidate with oracle misreport vs fair value
- **Invariant:** AP-INV-008
- **Expected impact:** Unfair lender slash
- **Severity if true:** High (if victim) / Info (market risk)
- **PoC feasibility:** med
- **Suggested test:** `PoC_LiquidationSolventBadDebt.t.sol`
- **Links:** C-018, POC-INTENT-004

---

### AP-005 — Liquidation over-seize collateral

- **Status:** closed-disproven
- **Files/functions:** `liquidate` seize/repay branches
- **Test:** `PoC_LiquidationOverSeize.t.sol` (4 tests)
- **Outcome:** Cannot seize above collateral; RCF caps repaid units pre-maturity
- **Links:** POC-INTENT-005

---

### AP-006 — Post-maturity liquidation model divergence

- **Status:** closed-disproven
- **Files/functions:** `liquidate(postMaturityMode=true)`
- **Test:** `PoC_PostMaturityLiquidation.t.sol` (3 tests)
- **Outcome:** Post-maturity seize/repay respects collateral and LIF ramp; no healthy-borrower normal-mode bypass
- **Links:** POC-INTENT-006

---

### AP-007 — Multi-collateral bitmap desync

- **Status:** closed-covered (C-033)
- **Files/functions:** `supplyCollateral`, `withdrawCollateral`, `liquidate`
- **State variables:** `collateralBitmap`, `collateral[]`
- **Invariant:** bitmap ↔ nonzero slots
- **Severity if true:** High
- **Existing tests:** native bitmap tests, `CollateralBitmap.spec`
- **Links:** C-033, POC-INTENT-007

---

### AP-008 — lossFactor over-slash lenders

- **Status:** closed-disproven (duplicate-risk Spearbit/Blackthorn M-1)
- **Test:** `PoC_LossFactorOverslash.t.sol` (4 tests)
- **Outcome:** Slash bounded by bad debt socialization; documented rounding only
- **Links:** POC-INTENT-008

---

### AP-009 — withdrawable exceeds loan token custody

- **Status:** closed-covered (C-020)
- **Files/functions:** `repay`, `withdraw`, `withdrawable`
- **Invariant:** AP-INV-003
- **Existing tests:** partial repay/withdraw fuzz, CVL
- **Links:** C-020, POC-INTENT-009

---

### AP-010 — pendingFee / lossFactor desync

- **Status:** closed-duplicate (C-021, C-034)
- **Files/functions:** `_updatePosition`, `take`
- **Test:** `PoC_PendingFeeLossFactorSync.t.sol` (4 tests)
- **Links:** Spearbit/Blackthorn rounding corpus

---

### AP-011 — Canceled ratifier root reuse

- **Status:** closed-disproven
- **Files/functions:** `EcrecoverRatifier.cancelRoot`, `take`
- **Test:** `PoC_CanceledRootReuse.t.sol` (4 tests)
- **Outcome:** Canceled roots revert on `take`; only maker/authorized delegate can cancel
- **Links:** POC-INTENT-011

---

### AP-012 — Delegate grief exceeds intent

- **Status:** closed-duplicate
- **Links:** C-025, L-16

---

### AP-013 — Signature field replay (beyond malleability)

- **Status:** partial-proven (L-01 malleability only)
- **Suggested test:** `PoC_SignatureMalleability.t.sol`
- **Links:** POC-INTENT-013

---

### AP-014 — Periphery temporary balance leakage

- **Status:** closed-disproven
- **Suggested test:** `PoC_BundleTemporaryBalanceReentrancy.t.sol`
- **Links:** C-026, POC-INTENT-014

---

### AP-015 — Exact target falsely impossible

- **Status:** closed-disproven (duplicate-risk L-6/L-7)
- **Test:** `PoC_BundleExactFillAlignment.t.sol`
- **Files/functions:** `TakeAmountsLib`, bundles
- **Severity if true:** Low/Medium
- **Suggested test:** fuzz vs `MidnightBundlesTest`
- **Links:** POC-INTENT-015

---

### AP-016 — Helper revert breaks documented skip

- **Status:** closed-invalid (matches NatSpec)
- **Test:** `PoC_BundleHelperRevertSemantics.t.sol` (4 tests)
- **Outcome:** `take` failures skip; `ConsumableUnitsLib`/`TakeAmountsLib` reverts abort bundle by design
- **Links:** POC-INTENT-016

---

### AP-017 — Permit2 unintended operation

- **Status:** closed-invalid
- **Links:** C-032, POC-INTENT-017

---

### AP-018 — Oracle/gate forced on victim

- **Status:** closed-disproven (enter gate path)
- **Test:** `PoC_EnterGateForcedDebt.t.sol`
- **Severity if true:** High if non-consenting
- **Links:** POC-INTENT-018

---

### AP-019 — Flash loan repayment bypass

- **Status:** closed-disproven
- **Files/functions:** `flashLoan`, nested `take` / `repay` / `withdraw` in callbacks
- **Severity if true:** High
- **Test:** `PoC_FlashLoanReentrancy.t.sol` (3 tests)
- **Outcome:** Non-reimbursed flash reverts; nested `take` and repay-callback `withdraw` do not profit attacker; `totalUnits` accounting holds
- **Links:** POC-INTENT-019, MC-04

---

### AP-020 — Maturity-second accounting

- **Status:** closed-covered (C-013)
- **Files/functions:** `take`, `settlementFee`
- **Existing tests:** `SettlementFeeTest`, `SettlementFeeBoundaries.spec`
- **Links:** C-013, POC-INTENT-020

---

### AP-021 — Repay callback reentrancy

- **Status:** closed-duplicate-risk
- **Files/functions:** `repay`, `onRepay`
- **Links:** C-022, POC-INTENT-021

---

### AP-022 — CVL market ID aliasing

- **Status:** closed-proven-formal (P3-02)
- **Suggested test:** `PoC_SolvencySpecMarketIdAliasing.t.sol`
- **Links:** C-036, POC-INTENT-022

---

### AP-023 — Referral budget underflow

- **Status:** closed-invalid
- **Links:** C-029

---

### AP-024 — Same loan/collateral self-loop insolvency

- **Status:** closed-disproven
- **Links:** C-031

---

### AP-025 — roleSetter zero brick

- **Status:** closed-proven (P3-01 Low)
- **Suggested test:** `PoC_RoleSetterBricking.t.sol`

---

### AP-026 — Nested composition beyond C-26/C-14

- **Status:** closed-partial (sell-callback slice disproven)
- **Test:** `PoC_SellCallbackComposition.t.sol` + prior callback PoCs
- **Outcome:** No novel profit path in sell-callback liquidate/flash probes; hunt only net-new compositions
- **Severity if true:** High

---

## Top open (residual value)

1. *(none — attack-plan queue exhausted; net-new composition only)*
2. Novel compositions outside closed callback/bundle/liquidation classes (no open AP id)

## Next command

```bash
forge test --match-path 'test/asyam/poc/PoC_*.sol' -vvv
```
