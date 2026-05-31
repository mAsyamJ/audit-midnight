# Net-New Attack Compositions

Date: 2026-05-30

These are hypotheses only. Each item crosses closed domains and needs a compiling Foundry PoC before any severity claim.

### COMP-001 — Ratified route fallback shares consumed group after canceled root

- **Composition domains:** ratifier root lifecycle + bundle skip/fallback + consumed cap
- **Contracts involved:** `EcrecoverRatifier`, `MidnightBundles`, `Midnight`
- **Functions involved:** `cancelRoot`, `buyWithUnitsTargetAndWithdrawCollateral`, `take`
- **Actors:** maker, delegate, route caller
- **State variables:** `isRootCanceled`, `consumed[maker][group]`, `position`
- **Why this is net-new:** AP-002 and AP-011 were tested separately, not as one route with a stale first root and valid fallback root sharing a group.
- **Prior AP items it uses as components:** AP-002, AP-011, AP-015
- **Attack setup:** two signed sell offers share maker/group; cancel root A; route A then B.
- **Attack sequence:** cancel A -> execute exact route -> A skips -> B fills -> attempt collateral withdrawal.
- **Economic invariant targeted:** route fallback must not bypass `INV-011` or over-withdraw collateral.
- **Why it might work:** helper computes consumable units before `take`, while ratifier failure is caught and route continues.
- **Why it might fail:** B recomputes current consumed state and final target reverts atomically.
- **Expected impact if true:** cap bypass or unauthorized debt/collateral movement, Medium/High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium; stale-root route failure may be intended.
- **Existing tests that partially cover it:** `PoC_CanceledRootReuse.t.sol`, `PoC_OfferConsumedCapRounding.t.sol`.
- **Missing test:** canceled first root plus valid same-group fallback in one bundle.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol' -vvvv`

### COMP-002 — Exact-target route with canceled root and referral split

- **Composition domains:** canceled root + exact target math + referral settlement
- **Contracts involved:** `EcrecoverRatifier`, `MidnightBundles`, `TakeAmountsLib`, `Midnight`
- **Functions involved:** `cancelRoot`, `buyWithAssetsTargetAndWithdrawCollateral`, `take`
- **Actors:** maker, route caller, referral recipient
- **State variables:** `isRootCanceled`, `consumed`, bundler loan-token balance
- **Why this is net-new:** combines a caught root failure with inverse-fill math and final fee split.
- **Prior AP items it uses as components:** AP-011, AP-015, AP-023
- **Attack setup:** first offer canceled, second valid at a different tick, exact buyer-assets target, nonzero referral.
- **Attack sequence:** cancel root A -> route A/B -> skip A -> fill B -> transfer referral -> assert refund/residual.
- **Economic invariant targeted:** distributed assets equal caller budget and target fill; router retains no float.
- **Why it might work:** fallback tick changes inverse-rounding path after a skip.
- **Why it might fail:** totals use actual `resBuyerAssets` and final equality is strict.
- **Expected impact if true:** caller loss, router residue, or third-party fee extraction, Medium.
- **Expected likelihood if true:** low/medium.
- **False-positive risk:** high; stale quote revert is intended.
- **Existing tests that partially cover it:** `PoC_BundleExactFillAlignment.t.sol`, referral regressions.
- **Missing test:** exact target plus canceled root plus referral.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol' -vvvv`

### COMP-003 — Loss socialization, stale lender, withdrawable, and fee-claim ordering

- **Composition domains:** liquidation bad debt + lossFactor + partial repay + continuous fee claim
- **Contracts involved:** `Midnight`
- **Functions involved:** `liquidate`, `repay`, `updatePosition`, `withdraw`, `claimContinuousFee`
- **Actors:** borrower, liquidator, lender, fee claimer
- **State variables:** `lossFactor`, `totalUnits`, `withdrawable`, `continuousFeeCredit`, `position.pendingFee`
- **Why this is net-new:** direct slash and fee sync were closed separately; the interleaving with repay-backed withdrawable and claim is not covered.
- **Prior AP items it uses as components:** AP-008, AP-009, AP-010
- **Attack setup:** lender has stale credit; borrower realizes partial bad debt; another borrower repays.
- **Attack sequence:** liquidate -> repay -> claim fee -> stale lender update -> withdraw.
- **Economic invariant targeted:** custody covers withdrawable and fee claims after every order permutation.
- **Why it might work:** slash scales fee credit while repay independently increases withdrawable.
- **Why it might fail:** all decrements are storage-bounded and update math is proportional.
- **Expected impact if true:** pool insolvency or excess fee extraction, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium; rounding-only differences are Low.
- **Existing tests that partially cover it:** `PoC_LossFactorOverslash.t.sol`, `PoC_PendingFeeLossFactorSync.t.sol`.
- **Missing test:** stateful permutation with balance assertions.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_LossFactorWithdrawableFee.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_LossFactorWithdrawableFee.sol' -vvvv`

### COMP-004 — Post-maturity liquidation funded by flash loan and callback unwind

- **Composition domains:** maturity + liquidation + flash loan + repay/withdraw callback
- **Contracts involved:** `Midnight`
- **Functions involved:** `flashLoan`, `liquidate`, `repay`, `withdraw`
- **Actors:** borrower-liquidator callback, lender
- **State variables:** `position.debt`, `withdrawable`, `totalUnits`, `lossFactor`
- **Why this is net-new:** AP-006 and AP-019 tested direct slices, not a post-maturity callback unwind funded by protocol float.
- **Prior AP items it uses as components:** AP-006, AP-019, AP-021
- **Attack setup:** matured debt, posted collateral, callback contract able to flash, liquidate, repay, and withdraw.
- **Attack sequence:** flash -> post-maturity liquidate -> callback repay/withdraw -> repay flash -> compare balances.
- **Economic invariant targeted:** no extraction beyond liquidation incentive; custody and units remain backed.
- **Why it might work:** liquidation increases withdrawable before pulling repayment and flash balance is temporarily absent.
- **Why it might fail:** outer repayment checks restore all temporary funding.
- **Expected impact if true:** protocol loan-token drain, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** flash, post-maturity, and liquidate callback PoCs.
- **Missing test:** four-function maturity composition.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol' -vvvv`

### COMP-005 — Delegated taker uses Permit2 route with independent payer and referral

- **Composition domains:** Permit2 + Midnight authorization + route receiver/referral
- **Contracts involved:** `MidnightBundles`, `Permit2`, `Midnight`
- **Functions involved:** `buyWithUnitsTargetAndWithdrawCollateral`, `pullToken`, `setIsAuthorized`, `take`
- **Actors:** taker, authorized delegate, relayer, permit holder, referral recipient
- **State variables:** `isAuthorized`, Permit2 nonce, bundler balance, taker collateral
- **Why this is net-new:** Permit2 was closed for attacker-owned calls; delegated taker and caller-owned payment semantics are composed here.
- **Prior AP items it uses as components:** AP-017, AP-023
- **Attack setup:** taker delegates route caller; caller presents its own Permit2 signature; receiver/referral are attacker-controlled.
- **Attack sequence:** authorize -> permit -> delegated bundle -> withdraw collateral -> fee/refund distribution.
- **Economic invariant targeted:** delegated execution cannot move taker collateral beyond explicit Midnight authorization intent or charge a third-party payer.
- **Why it might work:** Midnight authorization is broad while token source is `msg.sender`.
- **Why it might fail:** broad delegated collateral control is intended and Permit2 binds caller funds.
- **Expected impact if true:** unauthorized collateral movement or third-party drain, Medium/High.
- **Expected likelihood if true:** low.
- **False-positive risk:** high; delegated scope may be accepted risk.
- **Existing tests that partially cover it:** native Permit2 and authorization tests.
- **Missing test:** delegate/relayer/payer/referral role separation.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_DelegatePermit2Route.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_DelegatePermit2Route.sol' -vvvv`

### COMP-006 — Multi-collateral oracle liveness blocks gated post-maturity unwind

- **Composition domains:** oracle revert + collateral bitmap + liquidator gate + maturity
- **Contracts involved:** `Midnight`, oracle, liquidator gate
- **Functions involved:** `liquidate`, `withdrawCollateral`, `isHealthy`
- **Actors:** borrower, liquidator, oracle deployer, gate deployer
- **State variables:** `collateralBitmap`, collateral balances, debt, maturity
- **Why this is net-new:** direct liveness and bitmap behavior are known; their post-maturity unwind interaction is not tested.
- **Prior AP items it uses as components:** AP-004, AP-006, AP-007, AP-018
- **Attack setup:** borrower activates two collaterals; one oracle later reverts; gate restricts liquidators.
- **Attack sequence:** borrow -> oracle reverts -> mature -> permitted liquidator attempts alternate-collateral unwind -> lender withdraw.
- **Economic invariant targeted:** a supported unwind path exists or the lock is documented market risk.
- **Why it might work:** liquidation loop reads every active oracle before selecting collateral.
- **Why it might fail:** market-selected oracle liveness is accepted risk.
- **Expected impact if true:** locked collateral and delayed recovery, Low/Medium unless non-consenting victim forced.
- **Expected likelihood if true:** high as behavior, low as valid finding.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** `Reverts.spec`, native gate tests.
- **Missing test:** active multi-collateral revert after maturity.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_MultiCollateralOracleGate.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_MultiCollateralOracleGate.sol' -vvvv`

### COMP-007 — Shared loan token across markets exposes nested bundle custody ordering

- **Composition domains:** isolated markets + shared token custody + periphery float + nested callback
- **Contracts involved:** `Midnight`, `MidnightBundles`
- **Functions involved:** `supplyCollateralAndSellWithUnitsTarget`, `take`, `withdraw`
- **Actors:** attacker across market A/B, callback, lender
- **State variables:** per-market `withdrawable`, `totalUnits`, shared token balances
- **Why this is net-new:** simple bundler float was closed in one market; this crosses distinct markets sharing a standard loan token.
- **Prior AP items it uses as components:** AP-009, AP-014, AP-024
- **Attack setup:** market A and B share loan token; callback nests route/withdraw in other market.
- **Attack sequence:** route A -> callback route B -> withdraw B -> finish A -> compare custody buckets.
- **Economic invariant targeted:** aggregate shared-token custody covers each isolated market claim.
- **Why it might work:** ERC20 balance is global while accounting is market-local.
- **Why it might fail:** withdrawals are bounded by each market's backed `withdrawable`.
- **Expected impact if true:** cross-market loan-token drain, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** bundle leak invariant, direct withdraw tests.
- **Missing test:** nested route across same-token markets.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_CrossMarketSharedToken.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_CrossMarketSharedToken.sol' -vvvv`

### COMP-008 — Callback mutates ratifier root while outer offer state is transient

- **Composition domains:** take callback + ratifier root mutation + consumed state
- **Contracts involved:** `Midnight`, `SetterRatifier`, callback
- **Functions involved:** `take`, `onBuy`, `setIsRootRatified`, nested `take`
- **Actors:** maker-callback, taker, authorized delegate
- **State variables:** `consumed`, `isRootRatified`, `position`
- **Why this is net-new:** callback nesting and root state were closed independently.
- **Prior AP items it uses as components:** AP-001, AP-011, AP-026
- **Attack setup:** maker callback can toggle root B and execute nested offer B sharing group.
- **Attack sequence:** take A -> onBuy toggles B -> nested take B -> complete A.
- **Economic invariant targeted:** root mutation cannot monetize transient credit/debt or bypass caps.
- **Why it might work:** outer consumed and positions are written before callback.
- **Why it might fail:** nested take observes updated storage and outer transfer must settle.
- **Expected impact if true:** cap bypass or temporary-credit extraction, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** callback and canceled-root PoCs.
- **Missing test:** root mutation inside callback.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_CallbackRatifierRoot.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_CallbackRatifierRoot.sol' -vvvv`

### COMP-009 — Formal market alias becomes executable shared-token accounting probe

- **Composition domains:** CVL alias + production-distinct markets + shared-token accounting
- **Contracts involved:** `Midnight`, `IdLib`, Certora `Solvency.spec`
- **Functions involved:** `touchMarket`, `repay`, `withdraw`, `toId`
- **Actors:** lender, borrower across markets
- **State variables:** distinct market IDs, `withdrawable`, shared token custody
- **Why this is net-new:** P3-02 proves assurance loss only; this asks whether an executable economic path exists despite production IDs.
- **Prior AP items it uses as components:** AP-009, AP-022
- **Attack setup:** production-distinct markets share reduced CVL tuple and loan token.
- **Attack sequence:** create A/B -> debt and repay in A -> attempt claim in B -> nested ordering -> compare IDs/balances.
- **Economic invariant targeted:** market-local claims never cross production IDs.
- **Why it might work:** only if another path uses a reduced identity or shared balance incorrectly.
- **Why it might fail:** runtime storage keys use full production IDs everywhere.
- **Expected impact if true:** cross-market theft, Critical/High.
- **Expected likelihood if true:** low.
- **False-positive risk:** high; formal alias alone is not runtime.
- **Existing tests that partially cover it:** P3-02 PoC, `IdLibTest`.
- **Missing test:** executable cross-ID accounting attempts.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_FormalAliasExecutable.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_FormalAliasExecutable.sol' -vvvv`

### COMP-010 — Fee update invalidates first route leg and changes fallback economics

- **Composition domains:** fee schedule + stale off-chain route + bundle skip/fallback + referral
- **Contracts involved:** `Midnight`, `MidnightBundles`, `TakeAmountsLib`
- **Functions involved:** `setMarketSettlementFee`, `buyWithAssetsTargetAndWithdrawCollateral`, `take`
- **Actors:** fee setter, route caller, maker, referral recipient
- **State variables:** settlement fee schedule, `consumed`, bundler balance
- **Why this is net-new:** fee staleness is known; skip/fallback plus fee split is not exercised.
- **Prior AP items it uses as components:** AP-015, AP-020, AP-023
- **Attack setup:** quote route under fee F; setter raises fee so offer A reverts; B remains valid.
- **Attack sequence:** quote -> fee update -> exact route A/B -> A skips -> B fills or route reverts.
- **Economic invariant targeted:** no silent fill outside caller's asset/min-unit guarantees.
- **Why it might work:** skip semantics hide first-leg reason while helper uses current fees.
- **Why it might fail:** strict target and min-unit checks preserve slippage.
- **Expected impact if true:** adverse fill beyond declared bounds, Medium.
- **Expected likelihood if true:** low.
- **False-positive risk:** high; stale quote behavior is intended.
- **Existing tests that partially cover it:** native setter and bundle target tests.
- **Missing test:** fee-update fallback route.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_FeeChangeRouteQuote.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_FeeChangeRouteQuote.sol' -vvvv`

### COMP-011 — Partial repay before slash changes stale lender withdrawal after socialization

- **Composition domains:** partial repay + lossFactor + stale lender + withdraw
- **Contracts involved:** `Midnight`
- **Functions involved:** `repay`, `liquidate`, `updatePosition`, `withdraw`
- **Actors:** two borrowers, lender, liquidator
- **State variables:** `withdrawable`, `lossFactor`, lender `lastLossFactor`, `totalUnits`
- **Why this is net-new:** direct backing and slash tests do not permute repay-before-slash and stale lender exit.
- **Prior AP items it uses as components:** AP-008, AP-009, AP-010
- **Attack setup:** stale lender credit, one repaying borrower, one bad-debt borrower.
- **Attack sequence:** repay A -> liquidate B -> update lender -> withdraw max -> inspect residue.
- **Economic invariant targeted:** lender claim is bounded by backed post-slash credit and custody.
- **Why it might work:** repay adds cash before loss scale is applied to lender credit.
- **Why it might fail:** `withdrawable` and credit are independently bounded.
- **Expected impact if true:** first-withdrawer advantage or deficit, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** lossFactor and pending-fee PoCs.
- **Missing test:** repay/slash order permutation.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_PartialRepayLossFactor.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_PartialRepayLossFactor.sol' -vvvv`

### COMP-012 — reduceOnly route leg crosses exposure after an earlier bundle fill

- **Composition domains:** reduceOnly + multi-offer bundle + exact target
- **Contracts involved:** `MidnightBundles`, `Midnight`
- **Functions involved:** `supplyCollateralAndSellWithAssetsTarget`, `take`
- **Actors:** maker, route caller
- **State variables:** maker credit/debt, `consumed`, filled units/assets
- **Why this is net-new:** one-off reduceOnly edge was disproven; route-local state mutation before a later reduceOnly leg is new.
- **Prior AP items it uses as components:** AP-003, AP-015
- **Attack setup:** maker has debt/credit near crossing; route fills normal leg then reduceOnly leg.
- **Attack sequence:** execute exact target -> first leg changes maker side -> helper sizes reduceOnly second leg -> observe skip/fill.
- **Economic invariant targeted:** `INV-012` remains true after every accepted route leg.
- **Why it might work:** route sizing is computed incrementally against changed positions.
- **Why it might fail:** core recomputes reduceOnly deltas for each leg.
- **Expected impact if true:** unconsented exposure, Medium.
- **Expected likelihood if true:** low.
- **False-positive risk:** low.
- **Existing tests that partially cover it:** reduceOnly regression, bundle exact-fill tests.
- **Missing test:** state-crossing route sequence.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_ReduceOnlyBundleRoute.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_ReduceOnlyBundleRoute.sol' -vvvv`

### COMP-013 — Repeated dust drift becomes non-dust loss through socialization threshold

- **Composition domains:** rounding dust + repeated markets + pending fee + lossFactor
- **Contracts involved:** `Midnight`
- **Functions involved:** `take`, `updatePosition`, `liquidate`, `claimContinuousFee`
- **Actors:** multi-market lender/borrower/liquidator, fee claimer
- **State variables:** `pendingFee`, `continuousFeeCredit`, `lossFactor`, `totalUnits`
- **Why this is net-new:** dust alone is parked; this tests amplification into a later material slash or claim.
- **Prior AP items it uses as components:** AP-008, AP-010, AP-020
- **Attack setup:** many bounded fills/updates create directional drift; then realize bad debt.
- **Attack sequence:** repeat fill/update -> liquidate -> claim fee -> compare aggregate fair model.
- **Economic invariant targeted:** cumulative rounding cannot unlock non-dust extraction.
- **Why it might work:** asymmetric rounding is repeated before proportional slash.
- **Why it might fail:** amplification remains economically negligible.
- **Expected impact if true:** Medium only if realistic material extraction is shown.
- **Expected likelihood if true:** low.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** audited rounding corpus, fee tests.
- **Missing test:** realistic bounded amplification campaign.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_DustDriftToNonDustLoss.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_DustDriftToNonDustLoss.sol' -vvvv`

### COMP-014 — Liquidation callback withdraws repaid cash before outer pull

- **Composition domains:** liquidation state-before-pull + withdrawable + callback + flash funding
- **Contracts involved:** `Midnight`
- **Functions involved:** `liquidate`, `onLiquidate`, `withdraw`, `flashLoan`
- **Actors:** liquidator callback, lender
- **State variables:** `withdrawable`, `totalUnits`, token custody
- **Why this is net-new:** nested liquidate was closed; withdraw of precredited repayment inside liquidation callback is a different state consumer.
- **Prior AP items it uses as components:** AP-005, AP-009, AP-019, AP-026
- **Attack setup:** callback controls lender claim and liquidator funding.
- **Attack sequence:** liquidate with repaid units -> callback withdraws newly withdrawable units -> callback sources repayment -> finish.
- **Economic invariant targeted:** state-before-pull cannot let callback externalize unpaid repayment.
- **Why it might work:** `withdrawable += repaidUnits` precedes callback and transferFrom.
- **Why it might fail:** callback still must return repayment and withdrawn amount only consumes backed liquidity.
- **Expected impact if true:** loan-token drain, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** flash and liquidate callback PoCs.
- **Missing test:** withdraw as the nested liquidation consumer.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol' -vvvv`

### COMP-015 — Exact-maturity take callback nests repay before seller health check

- **Composition domains:** take callback + maturity boundary + repay + seller health
- **Contracts involved:** `Midnight`
- **Functions involved:** `take`, `onSell`, `repay`, `isHealthy`
- **Actors:** maker callback, taker, seller-borrower
- **State variables:** seller debt, liquidation lock, maturity, `withdrawable`
- **Why this is net-new:** maturity and callback locks were tested separately; nested repayment at the boundary changes final health state.
- **Prior AP items it uses as components:** AP-001, AP-006, AP-020, AP-021
- **Attack setup:** warp to maturity; seller callback can repay another or same position.
- **Attack sequence:** take at maturity -> callback repay -> outer transfer -> final health check.
- **Economic invariant targeted:** no post-maturity debt increase or unpaid health bypass.
- **Why it might work:** seller is transiently locked while nested state changes execute.
- **Why it might fail:** core post-maturity debt guard executes before callback.
- **Expected impact if true:** unconsented matured debt or collateral risk, Medium/High.
- **Expected likelihood if true:** low.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** sell callback and settlement boundary tests.
- **Missing test:** exact timestamp callback repayment.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_CallbackRatifierRoot.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_CallbackRatifierRoot.sol' -vvvv`

### COMP-016 — Setter-ratified roots share a group across bundle and direct call

- **Composition domains:** SetterRatifier + delegated root toggling + consumed cap + direct/bundle interleave
- **Contracts involved:** `SetterRatifier`, `MidnightBundles`, `Midnight`
- **Functions involved:** `setIsRootRatified`, `take`, bundle buy route
- **Actors:** maker, authorized delegate, taker
- **State variables:** `isRootRatified`, `consumed[maker][group]`
- **Why this is net-new:** combines direct and routed fills while root state changes between them.
- **Prior AP items it uses as components:** AP-002, AP-011, AP-012
- **Attack setup:** roots A/B share group and cap; delegate toggles; taker fills direct then routed.
- **Attack sequence:** ratify A/B -> direct A partial -> disable A -> bundle A/B -> inspect cap.
- **Economic invariant targeted:** total accepted consumption never exceeds group cap.
- **Why it might work:** route precomputes helper limit independently per offer.
- **Why it might fail:** storage `consumed` is shared and updated atomically.
- **Expected impact if true:** maker liquidity overfill, Medium.
- **Expected likelihood if true:** low.
- **False-positive risk:** low.
- **Existing tests that partially cover it:** consumed and ratifier tests.
- **Missing test:** direct/routed toggled-root interleave.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol' -vvvv`

### COMP-017 — ERC2612 permit consumed before stale-root route executes

- **Composition domains:** ERC2612 tolerant permit failure + canceled root + route rollback
- **Contracts involved:** `MidnightBundles`, ERC2612 token, `EcrecoverRatifier`
- **Functions involved:** `pullToken`, `permit`, `cancelRoot`, bundle buy route
- **Actors:** route caller, permit front-runner, maker
- **State variables:** token allowance, permit nonce, root canceled state
- **Why this is net-new:** permit tolerance and root skip are individually intended; the combined atomicity path is not documented.
- **Prior AP items it uses as components:** AP-011, AP-017
- **Attack setup:** caller signs permit; third party consumes permit but leaves allowance; maker cancels first route root.
- **Attack sequence:** consume permit -> cancel root -> execute route -> skip/fallback or revert -> inspect caller funds.
- **Economic invariant targeted:** failed route rolls back pulls; successful route charges only declared amount.
- **Why it might work:** permit failure is swallowed before token pull.
- **Why it might fail:** ERC20 transfer and all route changes revert atomically.
- **Expected impact if true:** caller fund loss or route grief; Low/Medium.
- **Expected likelihood if true:** low.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** native ERC2612 route tests.
- **Missing test:** consumed permit plus stale root.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol' -vvvv`

### COMP-018 — Cross-market same-token repay-and-withdraw consumes globally shared custody

- **Composition domains:** shared token markets + bundle repay/withdraw + same loan/collateral token
- **Contracts involved:** `MidnightBundles`, `Midnight`
- **Functions involved:** `repayAndWithdrawCollateral`, `repay`, `withdrawCollateral`, `withdraw`
- **Actors:** borrower in market A, lender in market B
- **State variables:** market A collateral, market A/B `withdrawable`, global token balance
- **Why this is net-new:** same-token self-loop and direct backing were tested only in one concrete market path.
- **Prior AP items it uses as components:** AP-009, AP-024
- **Attack setup:** markets A/B share token; token is collateral in A and loan token in both.
- **Attack sequence:** repay/withdraw collateral A -> lender withdraw B -> compare global custody and market claims.
- **Economic invariant targeted:** aggregate liabilities remain covered despite token-role reuse.
- **Why it might work:** one ERC20 balance simultaneously backs collateral and loan claims.
- **Why it might fail:** each deposited unit adds matching backing and transfers are exact.
- **Expected impact if true:** cross-market insolvency, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** same-token live-queue regressions.
- **Missing test:** two-market token-role reuse.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_CrossMarketSharedToken.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_CrossMarketSharedToken.sol' -vvvv`

### COMP-019 — Gated liquidation delays recovery until social loss ordering changes

- **Composition domains:** liquidator gate + bad debt + lender touch ordering + maturity
- **Contracts involved:** `Midnight`, liquidator gate
- **Functions involved:** `liquidate`, `updatePosition`, `withdraw`
- **Actors:** borrower, gate deployer, allowed/blocked liquidators, lenders
- **State variables:** gate result, debt, `lossFactor`, lender `lastLossFactor`
- **Why this is net-new:** direct gated liquidation is intended; delayed recovery plus stale lender exit ordering needs economic classification.
- **Prior AP items it uses as components:** AP-004, AP-008, AP-018
- **Attack setup:** consenting gated market, underwater borrower, lenders with different touch timing.
- **Attack sequence:** block liquidation -> mature or worsen debt -> allow liquidation -> stale/fresh lender withdrawals.
- **Economic invariant targeted:** no protocol-level loss beyond disclosed gated-market risk.
- **Why it might work:** time changes bad debt and distribution timing.
- **Why it might fail:** gate risk is market-selected and loss sharing is intended.
- **Expected impact if true:** loss timing unfairness; Low unless forced victim path exists.
- **Expected likelihood if true:** high behavior, low finding.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** gate and loss tests.
- **Missing test:** gated delay with multi-lender accounting.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_GateLiquidationSocialLoss.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_GateLiquidationSocialLoss.sol' -vvvv`

### COMP-020 — Active oracle revert prevents bitmap cleanup before post-maturity recovery

- **Composition domains:** bitmap + oracle liveness + collateral withdrawal + post-maturity liquidation
- **Contracts involved:** `Midnight`, oracle
- **Functions involved:** `withdrawCollateral`, `liquidate`, `isHealthy`
- **Actors:** borrower, liquidator
- **State variables:** `collateralBitmap`, collateral balances, debt
- **Why this is net-new:** bitmap correctness and oracle reverts are known separately; cleanup sequencing is not.
- **Prior AP items it uses as components:** AP-006, AP-007, AP-018
- **Attack setup:** activate dust collateral at reverting oracle plus valuable collateral.
- **Attack sequence:** borrow -> oracle reverts -> try remove dust -> mature -> liquidate valuable collateral.
- **Economic invariant targeted:** no unexpected protocol-wide loss; classify borrower lock precisely.
- **Why it might work:** health and liquidation iterate every active bit.
- **Why it might fail:** liveness failure is accepted oracle risk.
- **Expected impact if true:** position lock / delayed lender recovery, Low.
- **Expected likelihood if true:** high behavior.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** `Reverts.spec`, bitmap tests.
- **Missing test:** cleanup deadlock lifecycle.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_MultiCollateralOracleGate.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_MultiCollateralOracleGate.sol' -vvvv`

### COMP-021 — Expired root leg silently skips into worse valid fallback

- **Composition domains:** offer expiry + bundle skip + exact target + referral
- **Contracts involved:** `MidnightBundles`, `Midnight`, `TakeAmountsLib`
- **Functions involved:** exact buy/sell route, `take`
- **Actors:** route caller, makers, route builder
- **State variables:** offer `expiry`, filled units/assets, referral fee
- **Why this is net-new:** stale quote and skip are composed with a valid worse-price leg and referral math.
- **Prior AP items it uses as components:** AP-015, AP-020, AP-023
- **Attack setup:** route built before A expires; B remains valid and worse.
- **Attack sequence:** warp past A expiry -> execute route -> A skips -> B fills -> compare declared limits.
- **Economic invariant targeted:** fallback cannot exceed explicit user max/min bounds.
- **Why it might work:** skip is silent by design.
- **Why it might fail:** route bounds are caller-selected and enforced.
- **Expected impact if true:** adverse fill outside bound, Medium.
- **Expected likelihood if true:** low.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** bundle min/max tests, expiry tests.
- **Missing test:** expiry fallback with referral.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_FeeChangeRouteQuote.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_FeeChangeRouteQuote.sol' -vvvv`

### COMP-022 — Callback direct fill consumes group before outer bundle reaches fallback

- **Composition domains:** periphery route + callback nested direct take + consumed cap + skip semantics
- **Contracts involved:** `MidnightBundles`, `Midnight`, callback
- **Functions involved:** bundle sell route, `take`, `onBuy`
- **Actors:** maker callback, route caller
- **State variables:** `consumed`, route-local filled units/assets, positions
- **Why this is net-new:** simple nested take and simple route leakage were closed separately.
- **Prior AP items it uses as components:** AP-001, AP-002, AP-014, AP-026
- **Attack setup:** route A/B shares group; A callback directly consumes B capacity.
- **Attack sequence:** bundle take A -> callback direct take C -> outer route attempts B -> skip/revert/refund.
- **Economic invariant targeted:** accepted cap and route min/max guarantees remain atomic.
- **Why it might work:** route-local totals do not know nested consumption until next helper call.
- **Why it might fail:** helper reads updated consumed and final target reverts.
- **Expected impact if true:** cap bypass or router residue, Medium/High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** callback and bundle leak PoCs.
- **Missing test:** nested direct fill inside routed fill.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol' -vvvv`

### COMP-023 — Authorized callback raises maker consumed cancellation during route

- **Composition domains:** callback + delegated `setConsumed` cancellation + bundle continuation
- **Contracts involved:** `MidnightBundles`, `Midnight`
- **Functions involved:** bundle route, `take`, `onSell`, `setConsumed`
- **Actors:** maker, authorized callback delegate, route caller
- **State variables:** `consumed[maker][group]`, route-local totals
- **Why this is net-new:** direct cancellation and callback slices do not cover in-route cancellation of later legs.
- **Prior AP items it uses as components:** AP-002, AP-012, AP-026
- **Attack setup:** later route legs share maker/group; callback is authorized by maker.
- **Attack sequence:** fill A -> callback sets consumed max -> outer route skips B -> fallback C -> inspect guarantees.
- **Economic invariant targeted:** atomic min/max guarantees and no residue after callback-driven cancellation.
- **Why it might work:** cancellation is reachable during outer route execution.
- **Why it might fail:** intended asynchronous skip semantics plus final checks.
- **Expected impact if true:** route caller loss only if declared guarantee bypassed, Medium.
- **Expected likelihood if true:** low.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** authorization and helper skip tests.
- **Missing test:** callback cancellation inside route.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol' -vvvv`

### COMP-024 — Flash-funded nested bundle interacts with shared-token liquidation inflow

- **Composition domains:** flash loan + periphery route + liquidation + shared token
- **Contracts involved:** `Midnight`, `MidnightBundles`
- **Functions involved:** `flashLoan`, bundle sell route, `liquidate`, `withdraw`
- **Actors:** flash callback, liquidator, routed taker
- **State variables:** token custody, `withdrawable`, `totalUnits`, route float
- **Why this is net-new:** no prior test composes protocol flash float with router float and liquidation precredited inflow.
- **Prior AP items it uses as components:** AP-009, AP-014, AP-019, AP-026
- **Attack setup:** same loan token funds flash and market; callback can route and liquidate.
- **Attack sequence:** flash -> bundle route -> liquidate -> withdraw -> settle route -> repay flash.
- **Economic invariant targeted:** temporary balances cannot satisfy two obligations simultaneously.
- **Why it might work:** multiple components read one shared ERC20 balance at different points.
- **Why it might fail:** each outer frame requires repayment before transaction completion.
- **Expected impact if true:** protocol drain, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** flash and bundle leak PoCs.
- **Missing test:** three-frame temporary-balance composition.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol' -vvvv`

### COMP-025 — Fee change plus signed root causes route-local quote asymmetry

- **Composition domains:** signed offer root + fee update + periphery inverse math
- **Contracts involved:** `EcrecoverRatifier`, `MidnightBundles`, `Midnight`
- **Functions involved:** signed `take`, `setMarketSettlementFee`, exact route
- **Actors:** maker, fee setter, taker
- **State variables:** fee schedule, signed offer fields, consumed
- **Why this is net-new:** root integrity and fee staleness are known; signed route fallback economics are not mapped.
- **Prior AP items it uses as components:** AP-013, AP-015, AP-020
- **Attack setup:** signed offers at boundary ticks; fee setter updates after route quote.
- **Attack sequence:** sign -> quote -> set fee -> execute signed route -> inspect accepted fills.
- **Economic invariant targeted:** caller max/min protects against current-fee execution.
- **Why it might work:** fee is not signed as an offer field.
- **Why it might fail:** fee slippage is documented and route bounds hold.
- **Expected impact if true:** adverse execution outside route limits, Medium.
- **Expected likelihood if true:** low.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** signed ratifier and settlement fee tests.
- **Missing test:** signed stale-fee route.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_FeeChangeRouteQuote.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_FeeChangeRouteQuote.sol' -vvvv`

### COMP-026 — Callback switches to second market at a different maturity

- **Composition domains:** callback nesting + cross-market shared token + maturity mismatch
- **Contracts involved:** `Midnight`, callback
- **Functions involved:** `take`, nested `take`, `repay`, `withdraw`
- **Actors:** multi-market maker/taker callback
- **State variables:** A/B positions, maturities, shared token custody
- **Why this is net-new:** callback PoCs operate within one market; this switches market and maturity inside the callback.
- **Prior AP items it uses as components:** AP-001, AP-009, AP-020, AP-024
- **Attack setup:** A pre-maturity, B post-maturity, shared token, callback positions in both.
- **Attack sequence:** take A -> callback repay/withdraw or take B -> complete A -> inspect aggregate custody.
- **Economic invariant targeted:** isolated market accounting and maturity rules hold under cross-market nesting.
- **Why it might work:** one token balance services differently timed obligations.
- **Why it might fail:** per-market storage and exact transfers isolate accounting.
- **Expected impact if true:** cross-market extraction, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** callback and same-token PoCs.
- **Missing test:** different-maturity nested markets.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_CrossMarketSharedToken.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_CrossMarketSharedToken.sol' -vvvv`

### COMP-027 — Healthiness proof gap exercised by take callback state consumer

- **Composition domains:** CVL `take` exclusion + callback + seller-health final check
- **Contracts involved:** `Midnight`, `Healthiness.spec`, callback
- **Functions involved:** `take`, `onBuy`, `onSell`, `withdrawCollateral`, `isHealthy`
- **Actors:** seller callback, borrower
- **State variables:** debt, collateral bitmap, liquidation lock
- **Why this is net-new:** assurance boundary is paired with a concrete nested state consumer beyond direct nested take.
- **Prior AP items it uses as components:** AP-001, AP-007, AP-022, AP-026
- **Attack setup:** seller callback changes a different collateral or position while outer seller lock is set.
- **Attack sequence:** take -> callback nested withdraw/supply/repay -> complete -> assert seller health and bitmap.
- **Economic invariant targeted:** successful take cannot leave seller liquidatable unless lock remains active only transiently.
- **Why it might work:** CVL excludes `take` and assumes callback health.
- **Why it might fail:** production final health check catches all persistent damage.
- **Expected impact if true:** undercollateralized debt, High.
- **Expected likelihood if true:** low.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** sell callback tests, formal review.
- **Missing test:** callback collateral mutation around final health.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_CallbackRatifierRoot.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_CallbackRatifierRoot.sol' -vvvv`

### COMP-028 — Bad-debt realization across shared-token markets changes fee-claim availability

- **Composition domains:** multi-market shared token + bad debt + continuous fee claim + withdrawal ordering
- **Contracts involved:** `Midnight`
- **Functions involved:** `liquidate`, `claimContinuousFee`, `withdraw`
- **Actors:** fee claimer, liquidator, lenders in A/B
- **State variables:** A/B `withdrawable`, A `continuousFeeCredit`, global token custody
- **Why this is net-new:** loss and fee tests are single-market; token custody is global.
- **Prior AP items it uses as components:** AP-008, AP-009, AP-010
- **Attack setup:** A realizes bad debt, B holds repay-backed custody, both share token.
- **Attack sequence:** liquidate A -> claim fee A -> withdraw lender B -> reverse order -> compare.
- **Economic invariant targeted:** claims in A cannot consume custody needed for B liabilities beyond global backing.
- **Why it might work:** shared balance satisfies transfers regardless of market source.
- **Why it might fail:** aggregate backing includes all obligations and legitimate fees.
- **Expected impact if true:** cross-market first-claimer insolvency, High.
- **Expected likelihood if true:** medium.
- **False-positive risk:** medium.
- **Existing tests that partially cover it:** fee and liquidation tests.
- **Missing test:** two-market fee-claim order permutation.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_LossFactorWithdrawableFee.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_LossFactorWithdrawableFee.sol' -vvvv`

### COMP-029 — Delegated root signer revoked between route construction and fallback

- **Composition domains:** ratifier delegated signer + revocation timing + bundle fallback
- **Contracts involved:** `EcrecoverRatifier`, `MidnightBundles`, `Midnight`
- **Functions involved:** `setIsAuthorized`, `isRatified`, exact bundle route
- **Actors:** maker, delegated signer, relayer, taker
- **State variables:** `isAuthorized[maker][signer]`, consumed, route totals
- **Why this is net-new:** direct revocation is covered; fallback behavior across signatures from different authorities is not.
- **Prior AP items it uses as components:** AP-012, AP-013, AP-015
- **Attack setup:** route contains signer A and maker-signed B; revoke A before execution.
- **Attack sequence:** build route -> revoke A -> route skips A -> B fills -> inspect declared bounds and residues.
- **Economic invariant targeted:** revocation cannot cause silent execution outside caller bounds or resurrect A.
- **Why it might work:** ratifier failure is caught by route.
- **Why it might fail:** fallback is intended and bounded.
- **Expected impact if true:** unintended execution, Medium.
- **Expected likelihood if true:** low.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** `EcrecoverRatifierTest`, helper skip tests.
- **Missing test:** mixed-authority fallback route.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol' -vvvv`

### COMP-030 — Same-token cross-market dust drift feeds later socialized loss

- **Composition domains:** same-token markets + fee rounding + repeated route fills + bad-debt socialization
- **Contracts involved:** `Midnight`, `MidnightBundles`
- **Functions involved:** route takes, `updatePosition`, `liquidate`, `withdraw`
- **Actors:** multi-market maker/taker, borrower, liquidator
- **State variables:** per-market pending fee, `lossFactor`, `withdrawable`, shared custody
- **Why this is net-new:** it admits dust only as a precursor to measurable cross-market deficit.
- **Prior AP items it uses as components:** AP-008, AP-009, AP-010, AP-014, AP-024
- **Attack setup:** repeated small routes in A create drift; B holds large same-token liabilities; A then socializes loss.
- **Attack sequence:** loop routed fills -> update positions -> realize A bad debt -> withdraw A/B in both orders.
- **Economic invariant targeted:** dust cannot become a non-dust global custody deficit.
- **Why it might work:** rounding and global balance interact only after many operations.
- **Why it might fail:** differences remain bounded dust with no extraction.
- **Expected impact if true:** Medium only if realistic material deficit is shown.
- **Expected likelihood if true:** low.
- **False-positive risk:** high.
- **Existing tests that partially cover it:** rounding corpus, bundle invariant, lossFactor PoC.
- **Missing test:** bounded economic amplification benchmark.
- **Suggested PoC file:** `test/asyam/poc/composition/PoC_Comp_DustDriftToNonDustLoss.sol`
- **Run command:** `forge test --match-path 'test/asyam/poc/composition/PoC_Comp_DustDriftToNonDustLoss.sol' -vvvv`
