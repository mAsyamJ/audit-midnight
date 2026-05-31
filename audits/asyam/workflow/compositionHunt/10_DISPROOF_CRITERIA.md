# Disproof Criteria

Date: 2026-05-30

| PoC | Result that proves it | Result that disproves it | Low only | Duplicate | Intended behavior | Exact required assertion |
|---|---|---|---|---|---|---|
| RatifierPeripheryConsumed | accepted consumption exceeds cap or route residue | bounded cap and atomic rollback | stale-route DoS only | Blackthorn L-5/root grief | route skip with bounds | `assertLe(consumed, cap)` and router balance `== 0` |
| ExactTargetCanceledRoot | caller loses funds or fallback violates target | strict target/refund and rollback | stale route revert | L-6/L-7 or C-29 only | quote invalidation | invalid leg fill `== 0`; residual `== 0` |
| LossFactorWithdrawableFee | valid claim sequence leaves custody deficit | all permutations backed | dust variance only | M-1/L-9/C-021 | proportional slash | `balance >= aggregateLiabilities` |
| MaturityLiquidationFlash | attacker gains beyond incentive with restored flash | no excess gain or atomic revert | gas/rounding only | L-26/simple flash | normal liquidation incentive | post-balance delta bounded |
| DelegatePermit2Route | victim funds drained without matching context | only caller pays; delegated move intended | broad delegate UX risk | L-16/Permit2 hypothesis | voluntary delegation | victim balance unchanged |
| MultiCollateralOracleGate | non-consenting victim suffers protocol-level loss | chosen-market lock only | liveness grief | zero-oracle prior issue | oracle/gate trust | state drift absent after revert |
| CrossMarketSharedToken | one market consumes backing owed to another | aggregate custody always covers claims | dust only | same-token single-market C-31 | global token balance with local accounting | aggregate liability inequality |
| PostMaturityBadDebtWithdraw | order enables over-withdrawal | post-slash claims bounded | rounding only | optimistic bad debt L-10 | socialization model | withdrawn `<=` backed credit |
| CallbackRatifierRoot | nested callback leaves cap/health/custody broken | nested path safe or reverts | callback grief only | L-19/L-20 | untrusted callback self-risk | cap, health, lock assertions |
| FormalAliasExecutable | runtime state crosses full IDs | runtime IDs isolate all effects | formal gap only | P3-02 | none | `idA != idB`, B state unchanged |
| FeeChangeRouteQuote | accepted route exceeds explicit user bounds | revert or bounded fill | stale quote DoS | L-13 | fee slippage | filled assets/units within args |
| PartialRepayLossFactor | material order-dependent deficit | both orders backed | wei difference | M-1/L-9 | rounding | aggregate custody after both orders |
| ReduceOnlyBundleRoute | accepted leg increases maker exposure | exposure decreases or route skips | no impact | C-12 | reduce-only semantics | maker delta `<= 0` |
| GateLiquidationSocialLoss | forced third-party or systemic loss beyond chosen gate | consenting-market timing only | operational grief | prior gate/oracle risk | market configuration | victim opt-in boundary asserted |
| DustDriftToNonDustLoss | realistic bounded loop yields material profit | dust remains bounded/uneconomic | dust only | audited rounding corpus | fixed precision | profit exceeds declared threshold |

## Promotion Gate

A result enters `test/asyamFindings/` only after it compiles, demonstrates concrete impact, passes dedup, and is not merely intended behavior. A revert-only test is insufficient unless the claim is a protocol-level DoS with a non-consenting victim.
