# Collateral, Health, and Liquidation Model

Date: 2026-05-30

## Collateral params

Per market index: `token`, `lltv`, `maxLif`, `oracle`.

- **LLTV:** loan capacity per collateral value (`mulDivDown(price, lltv)`).
- **maxLif:** liquidation incentive factor cap; bad debt computed with `mulDivUp(..., maxLif)`.

## Bitmap and index

- `collateralBitmap` tracks active indices (max 128 active per borrower).
- `liquidate` accepts explicit `collateralIndex` for seize/repay leg.

## isHealthy

Used after `withdrawCollateral` and end of `take` (seller). Aggregates oracle prices over **active** bitmap entries vs debt.

**Supply collateral does not call oracle** — activation without debt is allowed.

## Liquidation eligibility

Pre-maturity: `originalDebt > maxDebt` and not `liquidationLocked`.

Post-maturity: `postMaturityMode && timestamp > maturity`.

During sell callback: seller **liquidation locked** — cannot be liquidated mid-callback.

## Bad debt

Loop computes `badDebt` as debt not covered at maxLif valuations. If `badDebt > 0`:

- Reduce borrower debt, increase `lossFactor`, decrease `totalUnits`, adjust `continuousFeeCredit`.

**Zero-repay liquidation:** Both `seizedAssets` and `repaidUnits` zero allowed — realizes bad debt (Spearbit/Blackthorn documented — duplicate-risk).

## Permissionless oracle/gate vs invariant break

| Scenario | Classification |
|---|---|
| Market creator sets malicious oracle | **INTENDED** for consenting traders |
| Victim forced into malicious market without consent | REQUIRES POC |
| Protocol allows liquidate healthy borrower | **INVARIANT BREAK** |
| Zero oracle price | Spearbit duplicate |

## Invariant sections

### Healthy borrower liquidation

- Pre-maturity: require `originalDebt > maxDebt` (unless locked semantics).
- **Severity if broken:** High

### Insolvent borrower recoverability

- Unhealthy positions should be liquidatable modulo gates.
- Gate revert = **INTENDED** market policy

### Bad debt accounting

- `badDebt` slash should match economically unrecoverable portion.
- Over-slash → Medium/High

### Multi-collateral edge cases

- Bitmap desync, wrong index, phantom collateral (Spearbit informational).
- **REQUIRES POC:** C-033 class

### Oracle liveness

- Reverting oracle blocks withdraw/liquidate — participant risk

### Maturity-boundary liquidation

- Post-maturity LIF formula; LLTV=WAD removes incentive (Blackthorn L-4 duplicate)

## Cross-links

- [04_MARKET_LIFECYCLE.md](04_MARKET_LIFECYCLE.md)
- `certora/specs/Healthiness.spec`, `Liquidate.spec`, `LiquidationBoundedByLIF.spec`
