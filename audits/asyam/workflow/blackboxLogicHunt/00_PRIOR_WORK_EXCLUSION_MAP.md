# Prior Work Exclusion Map

Date: 2026-05-31

Every row is closed as a direct approach. Adjacent work is allowed only where a different root cause changes the state
transition or the affected invariant.

| Closed class | Tested evidence | Surviving invariant | Forbidden direct approach | Allowed adjacent angle |
|---|---|---|---|---|
| Callback reentrancy | `PoC_TakeCallbackReentrancy`, `PoC_LiquidateCallbackReentrancy`, `PoC_SellCallbackComposition` | Nested calls settle or revert atomically | Direct nested `take`, `withdraw`, or `liquidate` drain | Callback as one step in a new authorization or aggregate-accounting path |
| Flash repayment bypass | `PoC_FlashLoanReentrancy`, `PoC_Comp_MaturityLiquidationFlash` | Flash principal is restored | Unpaid flash withdrawal | Flash as funding only for a distinct threshold flip |
| Group cap rounding bypass | `PoC_OfferConsumedCapRounding`, `PoC_Comp_RatifierPeripheryConsumed` | `consumed <= cap` | Repeated simple group overfill | Group semantics crossing unrelated economic families |
| Reduce-only bypass | `PoC_DeepValidationQueues`, `PoC_Comp_ReduceOnlyBundleRoute` | Maker exposure does not increase | Direct reduce-only edge | Deferred-state interpretation before reduce-only check |
| Optimistic bad debt | `PoC_LiquidationSolventBadDebt`, `PoC_Comp_PostMaturityBadDebtWithdraw` | Known socialization formula applies | Zero-price or simple zero-repay realization | Recoverability changes across a new multi-tx sequence |
| Liquidation over-seize | `PoC_LiquidationOverSeize` | Seize and repay remain bounded | Direct repeated seizure | RCF threshold causing a later non-dust state flip |
| Post-maturity liquidation | `PoC_PostMaturityLiquidation`, `PoC_Comp_MaturityLiquidationFlash` | Mode gates and LIF bounds hold | Simple maturity-edge seizure | Quote or authorization prepared before maturity and settled after it |
| Bitmap desync | Native bitmap tests and `CollateralBitmap.spec` | Active collateral bits track non-zero balances | Direct set/clear desync | Bitmap threshold interacting with liveness or delayed monitoring |
| Withdrawable overstatement | Accounting invariants and withdrawal probes | Market-local withdrawal is backed | Simple over-withdraw | Aggregate backing across markets and token-global fees |
| Pending fee / loss factor | `PoC_PendingFeeLossFactorSync`, `PoC_Comp_LossFactorWithdrawableFee` | Explicit touch synchronizes stored state | Direct fee/loss desync | Lazy state used by a different later decision or off-chain quote |
| Canceled root reuse | `PoC_CanceledRootReuse`, `PoC_Comp_ExactTargetCanceledRoot` | Canceled root cannot fill | Direct replay after cancellation | Independent signed intents combined across authorization surfaces |
| Delegate grief | Native authorization tests and delegate composition probes | Broad delegate power is documented | Voluntary delegate misuse | Unauthorized scope expansion without a corresponding user action |
| Bundler temporary balances | `PoC_BundleTemporaryBalanceReentrancy` | Computed transfers leave no extractable float | Balance-sweep theft | Bound-compliant route with a different economic side effect |
| Exact-fill helper mismatch | `PoC_BundleExactFillAlignment`, native periphery tests | Helper/core exact routes align | Direct rounding impossibility | Quote-to-settlement branch changes outside helper arithmetic |
| Helper revert skip | `PoC_BundleHelperRevertSemantics` | Pre-loop helper revert is documented | Generic route DoS | Partial economic side effect before a later helper or route failure |
| Permit2 unintended operation | `PoC_Comp_DelegatePermit2Route` | Permit payer context binds caller | Direct victim permit drain | Multiple independent signed intents composed by relayer |
| Oracle/gate forced victim | `PoC_EnterGateForcedDebt`, `PoC_Comp_MultiCollateralOracleGate` | Chosen-market liveness risk only | Malicious chosen oracle/gate | Consent boundary crossed through periphery or shared state |
| Same-token self-loop | `PoC_DeepValidationQueues`, maturity callback probes | Concrete repay-from-collateral path backed | Simple same loan/collateral drain | Shared-token global liability ordering |
| Role setter zero brick | `PoC_RoleSetterBricking` | Known Low footgun | Refile roleSetter zero | Separate external actor path only |
| Signature malleability | `PoC_SignatureMalleability` | Known Low issue | Refile high-s replay | Different signature-domain or intent-scope flaw |
| Formal market-ID aliasing | `PoC_SolvencySpecMarketIdAliasing` | Runtime full IDs stay isolated | Refile CVL summary mismatch | Executable runtime path only |

## Forbidden Duplicate Classes

Do not write new findings for direct variants of any row above, audited JSON issue, or Hashlock claim without a materially
different root cause and a local PoC.

## Allowed Adjacent Unexplored Classes

- Lazy state synchronized only on first touch and then consumed by a different economic decision.
- Aggregate token liabilities spanning permissionless markets and token-global settlement fees.
- Non-consenting-user exposure to a bad market through a missing periphery, ratifier, or authorization consent boundary.
- RCF, maturity, bitmap, fee, and one-wei thresholds that activate a later material branch.
- Event reconstruction gaps that demonstrably delay economically required action.

## Only Pursue If New Root Cause Exists

Dust, stale quotes, liveness, broad delegation, permissionless bad markets, callback composition, and social loss are
finding candidates only after a PoC proves non-dust loss or meaningful freeze for an actor that did not accept that risk.
