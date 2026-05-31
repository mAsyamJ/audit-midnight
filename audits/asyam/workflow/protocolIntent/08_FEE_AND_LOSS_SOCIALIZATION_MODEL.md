# Fee and Loss Socialization Model

Date: 2026-05-30

## Settlement fee

- Stored per market: `settlementFeeCbp0..6` by time-to-maturity bucket.
- On `take`: `claimableSettlementFee[loanToken] += buyerAssets - sellerAssets`.
- Claimed by `feeClaimer` via `claimSettlementFee`.

**INTENDED:** Fee increases can invalidate very low tick offers (NatSpec).

## Continuous fee

- `MarketState.continuousFee` — bounded by `MAX_CONTINUOUS_FEE` (Certora).
- Accrues on lender credit via `pendingFee` → `updatePosition` → `continuousFeeCredit`.
- Claimed by `claimContinuousFee`.

## pendingFeeIncrease / decrease

- Take adjusts buyer/seller pending fees proportionally to credit changes.
- Withdraw/repay/liquidate reduce pending fee with credit.

## Fee setter / claimer

- `feeSetter`: defaults and per-market fees.
- `feeClaimer`: pulls claimable buckets.
- **Admin-only** — external attacker path unlikely.

## lossFactor and bad debt socialization

- Only `liquidate` increases `lossFactor` when realizing `badDebt` (`LossFactor.spec`).
- Formula scales remaining lenders' credit down on `updatePosition`.
- `totalUnits` decreases with bad debt — socializes loss across unit holders.

## withdrawable after repay / liquidate

- `repay`: `withdrawable += units`.
- `liquidate` (repay leg): `withdrawable += repaidUnits`.
- `withdraw`: `withdrawable -= units`.

Certora: `WithdrawableMonotonicity.spec`.

## Intended vs bug

| Behavior | Classification |
|---|---|
| Protocol fee extraction via spread | INTENDED |
| Admin fee parameter changes | INTENDED |
| Fee front-running / stale quote | Duplicate-risk (L-13, L-21) |
| Fee rounding dust | Low / INTENDED |
| Fee path creating value from nothing | BREAK |

## Invariant list

| ID | Statement |
|---|---|
| INV-FEE-01 | Settlement fee claimable ≤ accrued spreads |
| INV-FEE-02 | Continuous fee claimable ≤ accrued via positions |
| INV-FEE-03 | Fees cannot silently drain `withdrawable` without accounting |
| INV-LOSS-01 | `lossFactor` monotonic non-decreasing |
| INV-LOSS-02 | `badDebt` realization matches unrecoverable debt bound |
| INV-LOSS-03 | `updatePosition` syncs `lastLossFactor` after market slash |

## Cross-links

- C-034 untested: continuous fee + lossFactor rounding — likely dust
- C-021 untested: terminal lossFactor / pendingFee desync
