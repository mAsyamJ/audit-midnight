# Security-Relevant Invariants

Date: 2026-05-30

**Primary handoff for PoC agents.** Each invariant: statement, code locations, test idea, severity if broken, links.

Classification: **BREAK** = security-relevant if violated | **INTENDED** = design | **CLOSED** = tested in this audit.

---

## Core accounting

### INV-001 — totalUnits consistency

- **Statement:** `totalUnits = aggregate debt + withdrawable` (market-level).
- **Files:** `Midnight.sol`, `certora/specs/Midnight.spec`
- **Functions:** `take`, `repay`, `withdraw`, `liquidate`
- **Why:** Solvency of lender pool.
- **Severity:** High
- **Test:** Invariant fuzz over sequence of ops.
- **PoC:** POC-INTENT-009

### INV-002 — No simultaneous credit and debt

- **Statement:** After `_updatePosition`, user should not hold both credit and debt (Certora).
- **Files:** `Midnight.sol`
- **Severity:** Medium
- **Test:** `test/asyam/invariant/`

### INV-003 — withdrawable consistency

- **Statement:** Sum of withdrawals ≤ cumulative repay/liquidate inflows minus prior withdrawals.
- **Files:** `Midnight.sol`; `WithdrawableMonotonicity.spec`
- **Severity:** High
- **PoC:** POC-INTENT-009

### INV-004 — pendingFee consistency

- **Statement:** `pendingFee ≤ credit`; accrual via `updatePosition` only.
- **Files:** `updatePositionView`, `take`
- **Severity:** Medium
- **PoC:** POC-INTENT-010

### INV-005 — No credit/debt from nothing

- **Statement:** Unit deltas match token flows and `totalUnits` delta.
- **Files:** `take`, `repay`
- **Severity:** High
- **PoC:** POC-INTENT-001

### INV-006 — No over-withdrawal

- **Statement:** `withdraw(units)` cannot exceed post-slash credit or `withdrawable`.
- **Files:** `withdraw`
- **Severity:** High
- **PoC:** POC-INTENT-009

---

## Liquidation

### INV-007 — Healthy borrower not liquidatable

- **Statement:** Pre-maturity: `originalDebt <= maxDebt` ⇒ `NotLiquidatable`.
- **Files:** `liquidate` ~620-624
- **Severity:** High
- **PoC:** POC-INTENT-004

### INV-008 — Bad debt not over-realized

- **Statement:** `badDebt` slash ≤ economically unrecoverable debt.
- **Files:** `liquidate` bad debt branch
- **Severity:** High
- **PoC:** POC-INTENT-004

### INV-009 — Insolvent liquidatable (modulo gates)

- **Statement:** `debt > maxDebt` ⇒ liquidatable unless locked/gated.
- **Severity:** Medium
- **Status:** REQUIRES POC for gate bypass

### INV-010 — Collateral seizure bounded

- **Statement:** Seized ≤ position collateral; LIF/LLTV bounds respected.
- **Files:** `liquidate` seize branch
- **Severity:** High
- **PoC:** POC-INTENT-005

---

## Offer execution

### INV-011 — Consumed cap enforced

- **Statement:** `consumed[maker][group]` never exceeds `maxAssets`/`maxUnits`.
- **Status:** **CLOSED** C-005
- **PoC:** `PoC_OfferConsumedCapRounding.t.sol`

### INV-012 — reduceOnly enforced

- **Statement:** No maker credit/debt increase on reduce-only fills.
- **Status:** **CLOSED** C-012
- **PoC:** `PoC_DeepValidationQueues.t.sol`

### INV-013 — Seller health after take

- **Statement:** Seller healthy after take unless liquidation-locked during callback.
- **Files:** `take` final `require(isHealthy || locked)`
- **Severity:** Medium

### INV-014 — Settlement fee consistency

- **Statement:** Fee accrual equals `buyerAssets - sellerAssets` on take.
- **Severity:** Low/Medium

---

## Ratifiers

### INV-015 — Unauthorized roots rejected

- **Files:** `take` → `isRatified`
- **Severity:** High

### INV-016 — Canceled roots unusable

- **Files:** `SetterRatifier`, `EcrecoverRatifier`
- **Severity:** Medium

### INV-017 — Signatures bind economic fields

- **Status:** Partial — L-01 malleability (Low), not field replay
- **Severity:** Low to High depending on path

### INV-018 — Delegation within maker intent

- **Status:** INTENDED broad scope (duplicate)

---

## Periphery

### INV-019 — Bundle distributes only call-generated assets

- **Status:** **CLOSED** C-26
- **PoC:** `PoC_BundleTemporaryBalanceReentrancy.t.sol`

### INV-020 — Exact target not falsely failing

- **Severity:** Low/Medium
- **PoC:** POC-INTENT-015

### INV-021 — Referral cannot underfund repayment

- **Status:** **CLOSED invalid** C-29

### INV-022 — Skip behavior honors min guarantees

- **Severity:** Low
- **PoC:** POC-INTENT-016

---

## Oracle / gate / callback

### INV-023 — Callback reentrancy no monetization

- **Status:** **CLOSED disproven** C-14
- **PoC:** `PoC_TakeCallbackReentrancy.t.sol`

### INV-024 — Callback return enforced

- **Files:** all callback requires
- **Severity:** Low (DoS)

### INV-025 — Oracle/gate not forced on victims

- **Severity:** High if proven
- **PoC:** POC-INTENT-018

---

## Cross-reference

Full attack surface list: [13_ECONOMIC_ATTACK_SURFACES.md](13_ECONOMIC_ATTACK_SURFACES.md)  
PoC tasks: [14_PROTOCOL_INTENT_TO_POC_TARGETS.md](14_PROTOCOL_INTENT_TO_POC_TARGETS.md)
