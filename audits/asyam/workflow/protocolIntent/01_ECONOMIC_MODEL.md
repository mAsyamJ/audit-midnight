# Economic Model

Date: 2026-05-30

## Fixed-rate lending as unit trading

Midnight does not pool variable-rate utilization. Each market trades **units** of credit/debt with payoff analogous to **zero-coupon obligations** maturing at `market.maturity`:

- **1 debt unit** = obligation to repay **1 loan token** (in unit accounting) before/at maturity workflow.
- **1 credit unit** = claim on repaid loan tokens held in market custody (`withdrawable`).

Implied simple rate from trade price \(P\) (WAD): \(r = 1/P - 1\) (whitepaper §2.1; `TickLib.tickToPrice`).

## Assets vs units

| Concept | Meaning |
|---|---|
| **units** | Integer position delta in `take`, `repay`, `withdraw`, `liquidate` |
| **buyerAssets / sellerAssets** | Loan-token amounts computed from `units` and side-specific prices |
| **buyerPrice / sellerPrice** | Derived from `tick`, `settlementFee(id, timeToMaturity)` |

In `Midnight.take` (lines ~358–364):

- `sellerPrice = offer.buy ? offerPrice - fee : offerPrice`
- `buyerPrice = sellerPrice + fee`
- Buy-side offer: `buyerAssets = units.mulDivDown(buyerPrice, WAD)`, `sellerAssets = units.mulDivDown(sellerPrice, WAD)`
- Sell-side offer: rounding direction flips (`mulDivUp` on buyer assets)

**Settlement spread:** `claimableSettlementFee[loanToken] += buyerAssets - sellerAssets`.

## Buyer / seller / maker / taker economics

| Role in `take` | If `offer.buy` | If `!offer.buy` |
|---|---|---|
| Maker | Buyer (credit↑) | Seller (debt↑ or credit↓) |
| Taker | Seller | Buyer |

- **Buyer** closes debt before accumulating credit: `buyerCreditIncrease = max(0, units - buyer.debt)`.
- **Seller** closes credit before new debt: `sellerDebtIncrease = units - min(units, seller.credit)`.

`totalUnits` changes by `buyerCreditIncrease - sellerCreditDecrease` (new lender principal net).

## Non-escrow offers and settlement liquidity

Offers are **messages**; no loan tokens locked at quote time. At `take`:

1. Position math and caps updated.
2. **Callbacks** (optional) for liquidity / checks.
3. **Transfers:** net `buyerAssets - sellerAssets` to Midnight; `sellerAssets` to receiver.
4. **Health:** seller must be healthy after callbacks (`isHealthy`) unless liquidation-locked during sell callback.

**Payer:** `buyerCallback != 0 ? buyerCallback : (offer.buy ? buyer : msg.sender)` — bundler often is `msg.sender` when it pre-pulls.

## Maturity behavior

- **Pre-maturity:** Normal trading; debt can increase on sell-side fills.
- **At maturity:** `timeToMaturity` → 0 affects settlement fee bucket; continuous fee accrual uses `min(now, maturity)`.
- **Post-maturity:** `CannotIncreaseDebtPostMaturity` — seller debt increase must be zero; trading still allowed for unwinds (whitepaper §2.3).

## Fees

### Settlement fee (`settlementFee`)

- Piecewise constant in **cbps** by `timeToMaturity` (`settlementFeeCbp0..6`).
- Embedded in spread: buyer pays higher price than seller receives.
- **INTENDED:** Very low tick offers can revert if `buyerPrice` invalid (NatSpec on `take`).

### Continuous fee

- `MarketState.continuousFee` (per-second style accrual factor).
- On take: `buyerPendingFeeIncrease` proportional to new credit × fee × timeToMaturity.
- Realized via `updatePosition` → moves to `continuousFeeCredit` (claimable by fee claimer).

## Loss factor, withdrawable, totalUnits, bad debt

**Certora core identity** (`Midnight.spec`): `totalUnits = sum(debt) + withdrawable` (market-level).

| Field | Economic meaning |
|---|---|
| `withdrawable` | Loan tokens in custody backing lender withdrawals |
| `totalUnits` | Outstanding unit liabilities (debt + withdrawable bucket) |
| `lossFactor` | Cumulative lender slash index; monotonic non-decreasing |
| `badDebt` (in `liquidate`) | Debt not covered by collateral at `maxLif` prices — socialized |

Bad debt realization (`liquidate` ~626–641):

- Reduces borrower `debt`, lowers `totalUnits`, increases `lossFactor`.
- Lenders must call `updatePosition` before relying on `credit` — slash applied via `lastLossFactor` vs market `lossFactor`.

## Key formulas (code paths)

| Formula | Location |
|---|---|
| `tick → price` | `TickLib.tickToPrice` |
| Health `maxDebt` | `liquidate` loop: `collateral * price * lltv` |
| `badDebt` bound | collateral valued at `maxLif` |
| Post-maturity `lif` | `min(maxLif, WAD + (maxLif-WAD)*elapsed/TIME_TO_MAX_LIF)` |
| Slash credit | `updatePositionView`: `credit * (maxLF - marketLF) / (maxLF - userLF)` |

## Economic invariants (summary)

1. No user holds **both credit and debt** after sync (Certora).
2. `totalUnits` consistent with repay/withdraw/liquidate/take deltas.
3. `lossFactor` only increases; maxed market blocks new `take`.
4. Settlement fees accrue only on executed takes.
5. Consumed caps monotonic per maker/group.

## Economic Failure Definitions

| Failure | Definition | Classification if proven |
|---|---|---|
| **Over-withdrawal** | User withdraws more loan tokens than post-slash credit / `withdrawable` | SECURITY-RELEVANT INVARIANT BREAK |
| **Undercollateralized unliquidatable borrower** | `debt > maxDebt` but `NotLiquidatable` without accepted gate/oracle cause | REQUIRES POC (or accepted risk) |
| **Solvent borrower liquidated** | Liquidation when `originalDebt <= maxDebt` (pre-maturity mode) | SECURITY-RELEVANT INVARIANT BREAK |
| **Bad debt over-realization** | `badDebt` slash exceeds unrecoverable debt | SECURITY-RELEVANT INVARIANT BREAK |
| **Bad debt under-realization** | Insolvent debt remains after zero-repay liquidation path | Design / oracle dependent |
| **Consumed cap bypass** | `consumed[maker][group]` exceeds `maxAssets` or `maxUnits` | SECURITY-RELEVANT INVARIANT BREAK |
| **Credit/debt from nothing** | Units change without matching transfers / `totalUnits` | SECURITY-RELEVANT INVARIANT BREAK |
| **Loss factor desynchronization** | User credit not slashed when market `lossFactor` increased | SECURITY-RELEVANT INVARIANT BREAK |
| **Fee extraction** | Claimable fees exceed accrued spread/continuous fees | SECURITY-RELEVANT INVARIANT BREAK |
| **Maturity boundary arbitrage** | Inconsistent fee/debt rules across `maturity` second | REQUIRES POC |
| **Periphery balance leakage** | Router or victim loses tokens via nested call | SECURITY-RELEVANT INVARIANT BREAK |

## Assumptions and unknowns

- **Exact, non-reentrant ERC20** (core comments, Certora ERC20 summaries).
- **Oracle correctness** is market participant risk unless forced on non-consenting victim.
- **Rounding dust** at wei scale: usually Low unless compounded to cap bypass.

## Cross-links

- Flows: [03_ASSET_AND_VALUE_FLOW.md](03_ASSET_AND_VALUE_FLOW.md)
- Liquidation: [07_COLLATERAL_HEALTH_AND_LIQUIDATION_MODEL.md](07_COLLATERAL_HEALTH_AND_LIQUIDATION_MODEL.md)
- Fees: [08_FEE_AND_LOSS_SOCIALIZATION_MODEL.md](08_FEE_AND_LOSS_SOCIALIZATION_MODEL.md)
