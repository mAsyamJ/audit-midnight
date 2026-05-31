# Credit / Debt Unit Model

Date: 2026-05-30

## What credit and debt represent

- **`credit`**: Lender's units of claim on the market's loan-token pool (after slash + continuous fee accrual via `updatePosition`).
- **`debt`**: Borrower's outstanding units owed to the market.

A position should not hold both meaningful credit and debt simultaneously after sync (Certora).

## Units ↔ assets in `take`

Driven by `tick`, settlement fee, and `offer.buy` rounding direction (`mulDivDown` vs `mulDivUp`).

## Settlement and continuous fee on take

- **Settlement:** spread `buyerAssets - sellerAssets` → `claimableSettlementFee`.
- **Continuous:** `buyerPendingFeeIncrease` on new credit; seller pending fee reduced when credit closed.

## updatePosition / updatePositionView

- Applies **lossFactor slash** to credit and pending fee.
- Accrues continuous fee from `lastAccrual` to `min(now, maturity)`.
- Must run before `withdraw` and when loading credit in `take`.

## Debt / credit mutation rules

| Event | Debt | Credit |
|---|---|---|
| Buy-heavy take | Buyer debt ↓, credit may ↑ | Seller credit ↓, debt may ↑ |
| Repay | Debt ↓ | — |
| Withdraw | Credit ↓ | — |
| Liquidate | Debt ↓ (and bad debt branch) | — |
| Bad debt | Debt ↓, `totalUnits` ↓, `lossFactor` ↑ | Lenders slashed on update |

## reduceOnly

```solidity
require(!offer.reduceOnly || (offer.buy ? buyerCreditIncrease == 0 : sellerDebtIncrease == 0));
```

Unit-side deltas checked **before** callbacks. **INTENDED:** reduce debt to zero on buy-side reduce-only; overfill reverts `MakerCreditOrDebtIncreased`.

## Post-maturity

`CannotIncreaseDebtPostMaturity`: seller cannot increase debt after maturity.

## lossFactor effect

`updatePositionView`: new credit scaled by `(maxLF - marketLF) / (maxLF - userLF)`.

## Invariant candidates

| ID | Statement |
|---|---|
| INV-CD-01 | `totalUnits` changes match net credit creation/destruction on take |
| INV-CD-02 | Repay increases `withdrawable` 1:1 with units |
| INV-CD-03 | Withdraw decreases `withdrawable` 1:1 with units |
| INV-CD-04 | reduceOnly never increases exposed maker debt/credit |

## Rounding / dust

- Wei-level mulDiv imprecision: **usually Low** unless cap bypass.
- Certora `ExactMath` / `MulDiv` bound overflow paths.

## Severity escalation

| Issue | Potential severity |
|---|---|
| Cap bypass via rounding | Medium+ |
| Credit without `updatePosition` slash | Medium+ |
| Dust-only drift | Low / informational |

## Cross-links

- [08_FEE_AND_LOSS_SOCIALIZATION_MODEL.md](08_FEE_AND_LOSS_SOCIALIZATION_MODEL.md)
- C-12 closed: [../05_DEEP_VALIDATION_C12_C26_C29_C31.md](../05_DEEP_VALIDATION_C12_C26_C29_C31.md)
