# Accounting Discontinuity Hunt

Date: 2026-05-31

A target escalates only if a tiny or timed input flips a later non-dust economic decision.

| ID | Threshold | Path | Suspicion | Material branch to test | Test design |
|---|---|---|---|---|---|
| AD-001 | stored vs effective credit delta of 1 | `updatePositionView`, `withdraw` | First touch shrinks max withdrawal | full withdraw vs revert | Slash by one wei, compare stored quote and actual exit |
| AD-002 | pending fee rounds from 0 to 1 | `_updatePosition` | Touch ordering changes reserved fee | fee claim vs lender exit | Accrue around first nonzero fee |
| AD-003 | loss factor from 0 to nonzero | `liquidate` | First default changes every stale lender | healthy claim vs reduced claim | Realize one wei bad debt with large lender base |
| AD-004 | loss factor near max | `take`, `_updatePosition` | New activity terminally blocked | live vs frozen market | Dedup terminal behavior; only pursue new loss path |
| AD-005 | withdrawable from 0 to 1 | `repay`, `liquidate` | First cash enables race | withdraw vs rollover | Compare direct and route-triggered actions |
| AD-006 | aggregate custody equals liabilities | fee claims, withdraw | Claim ordering may cross solvency boundary | later valid claim succeeds vs reverts | Same-token markets with exact backing |
| AD-007 | bad debt from 0 to 1 | `liquidate` | Tiny price move causes system-wide slash | no slash vs slash | Neighboring oracle prices, standard oracle |
| AD-008 | health `maxDebt == debt` | `isHealthy`, `take`, `withdrawCollateral` | Rounding flips liquidatability | healthy vs liquidatable | Boundary collateral amounts |
| AD-009 | RCF residual equals threshold | `liquidate` | One wei disables close-factor guard | partial vs full liquidation | Neighboring `rcfThreshold` values |
| AD-010 | maturity - 1 / maturity / +1 | `take`, `liquidate` | Fee and mode branch switch | debt increase, LIF, seizure | Three-timestamp matrix |
| AD-011 | settlement fee bucket breakpoint | `settlementFee` | Interpolation boundary changes route | fallback or revert | Quote just before and execute after breakpoint |
| AD-012 | offer expiry exact timestamp | `take`, bundles | Valid leg becomes skipped fallback | different exposure | Execute at expiry and expiry + 1 |
| AD-013 | tick price equals settlement fee | `take`, helpers | Buy seller price becomes zero | zero transfer vs active callback | Dedup low-price behavior unless material |
| AD-014 | buyer price equals WAD | helper | Inverse reachability mode changes | exact target possible vs revert | Neighboring ticks and fee |
| AD-015 | consumed equals cap | consumed helpers | Zero-unit forwarded leg executes | fallback and callbacks | Direct zero callback duplicate; test route side effect only |
| AD-016 | collateral balance 1 -> 0 | bitmap | Last withdrawal clears oracle dependency | locked vs unlocked position | Debt-zero bundle repay then exit |
| AD-017 | activated collateral count 16 -> 17 | `supplyCollateral` | Supply route reverts after earlier pulls | partial effects vs atomic revert | Bundle collateral supplies around limit |
| AD-018 | collateral index 127 / 128 | bitmap | Shift assumption boundary | active vs ignored | Valid array length and final index |
| AD-019 | array length 0 / 1 / 128 / 129 | `touchMarket` | Creation validation branch | market creation vs revert | Boundary market construction |
| AD-020 | maxUnits / maxAssets mode | `take`, helpers | Cap unit changes economic family | cap respected vs unintended reuse | Same group with heterogeneous mode, classify user error |
| AD-021 | referral pct 0 / 1 / WAD-1 | bundles | Fee rounding changes target units | different debt or proceeds | Explicit bound and residual checks |
| AD-022 | continuous fee claim equals withdrawable | `claimContinuousFee` | Last available cash race | fee claim vs lender withdraw | Order permutations |
| AD-023 | settlement fee claim equals free custody | `claimSettlementFee` | Token-global reserve boundary | later market withdrawal | Aggregate fee backing PoC |
| AD-024 | oracle value causing product headroom edge | health/liquidate | Arithmetic revert locks exit | liveness vs solvency | Keep only realistic oracle values |
| AD-025 | partial repay leaves 1 debt unit | `repay`, `withdrawCollateral` | Oracle dependency persists unexpectedly | collateral exit vs locked dust debt | Repay exact debt and debt-1 through bundle |
