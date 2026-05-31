# Invariant Break Targets

Date: 2026-05-30

Testable targets for Foundry unit + invariant tests.

---

## AP-INV-001 — totalUnits solvency

- **Statement:** `marketState.totalUnits` equals aggregate debt + `withdrawable` (Certora `Midnight.spec`).
- **Functions:** all unit mutators
- **Test idea:** Sequence fuzz: take → repay → liquidate → withdraw
- **Foundry:** extend `Invariant_MarketAccounting.t.sol`
- **Links:** AP-001, AP-019

## AP-INV-002 — no credit and debt together

- **Statement:** After `_updatePosition`, user not holding both credit and debt meaningfully.
- **Source:** `Midnight.spec`
- **Test idea:** fuzz positions after take/repay

## AP-INV-003 — withdrawable monotonicity

- **Statement:** repay/liquidate increase `withdrawable`; withdraw decreases 1:1.
- **Source:** `WithdrawableMonotonicity.spec`
- **Test idea:** assert deltas on each call
- **Links:** AP-009

## AP-INV-004 — lossFactor sync

- **Statement:** User credit after `updatePosition` reflects market `lossFactor` slash.
- **Source:** `LossFactor.spec`
- **Links:** AP-008, AP-010

## AP-INV-005 — no units from nothing

- **Statement:** Sum of token flows matches `totalUnits` delta on `take`.
- **Links:** AP-001

## AP-INV-006 — consumed cap monotonic

- **Statement:** `consumed[maker][group]` never exceeds offer cap.
- **Source:** `Consume.spec`
- **Links:** AP-002 (closed)

## AP-INV-007 — healthy not liquidatable

- **Statement:** Pre-maturity: `debt <= maxDebt` ⇒ `NotLiquidatable`.
- **Source:** `Healthiness.spec` (note: take not in CVL health preservation)
- **Links:** AP-004

## AP-INV-008 — bad debt bounded

- **Statement:** `badDebt` slash ≤ economically unrecoverable portion.
- **Links:** AP-004, AP-008

## AP-INV-009 — seizure bounded

- **Statement:** `seizedAssets <= collateral[index]`.
- **Links:** AP-005

## AP-INV-010 — callback no profit

- **Statement:** Reentrant `take` during callback does not increase attacker loan token balance.
- **Links:** AP-001 (closed)

## AP-INV-011 — bundle no sweep

- **Statement:** Router never transfers more than computed leg amount from untrusted balance.
- **Links:** AP-014 (closed); `Invariant_BundleNoCrossCallBalanceLeak.t.sol`

## AP-INV-012 — bitmap consistency

- **Statement:** Bit set iff `collateral[i] > 0`.
- **Source:** `CollateralBitmap.spec`
- **Links:** AP-007 (closed)

## Certora gap note

`Solvency.spec::CVL_toId` — formal only (AP-022 / P3-02). Do not confuse with production `IdLib.toId`.
