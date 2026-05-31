# Temporal and Maturity Compositions

Date: 2026-05-30

| # | Time edge | Attack sequence | Expected invariant | Why prior tests may miss it | Suggested Foundry test |
|---|---|---|---|---|---|
| T-01 | `maturity - 1` | quote route -> execute sell -> record fee/debt | fee bucket current | direct tests omit stale route | `PoC_Comp_FeeChangeRouteQuote` |
| T-02 | `maturity` | take -> seller callback repay -> finish | no prohibited debt increase | callback not paired with exact boundary | `PoC_Comp_CallbackRatifierRoot` |
| T-03 | `maturity + 1` | flash -> post-maturity liquidate -> withdraw -> repay flash | no excess extraction | AP-006/AP-019 separate | `PoC_Comp_MaturityLiquidationFlash` |
| T-04 | offer expiry boundary | route built before expiry -> execute after -> fallback | explicit bounds hold | native expiry is direct | `PoC_Comp_FeeChangeRouteQuote` |
| T-05 | fee change before take | sign root -> raise fee -> direct take | documented revert/fill only | signed root timing absent | `PoC_Comp_FeeChangeRouteQuote` |
| T-06 | fee change after route quote | quote A/B -> raise fee -> route skips A -> B fills | min/max preserved | fallback economics absent | `PoC_Comp_FeeChangeRouteQuote` |
| T-07 | root canceled after route built | route A/B -> cancel A -> execute | no cap/refund mismatch | canceled root direct only | `PoC_Comp_ExactTargetCanceledRoot` |
| T-08 | delegate revoked after signature | signer signs A -> revoke -> route A/B | A unusable; B bounded | route fallback absent | `PoC_Comp_ExactTargetCanceledRoot` |
| T-09 | oracle change after borrow | borrow with live oracle -> oracle revert -> withdraw | classify lock only | lifecycle composition absent | `PoC_Comp_MultiCollateralOracleGate` |
| T-10 | gate change before liquidation | debt underwater -> gate denies -> maturity -> allow | intended loss only | timing/economics absent | `PoC_Comp_GateLiquidationSocialLoss` |
| T-11 | bad debt before lender update | liquidate -> stale lender claim/update | proportional slash | direct sync test lacks second market | `PoC_Comp_LossFactorWithdrawableFee` |
| T-12 | repay before bad debt | repay A -> liquidate B -> lender withdraw | backed post-slash exit | permutation absent | `PoC_Comp_PartialRepayLossFactor` |
| T-13 | repay after bad debt | liquidate B -> repay A -> lender withdraw | same backing bound | permutation absent | `PoC_Comp_PartialRepayLossFactor` |
| T-14 | claim fee before stale update | slash -> claim -> lender update -> withdraw | aggregate custody | order not composed | `PoC_Comp_LossFactorWithdrawableFee` |
| T-15 | claim fee after stale update | slash -> lender update -> claim -> withdraw | equivalent bounded result | order not composed | `PoC_Comp_LossFactorWithdrawableFee` |
| T-16 | callback same transaction | outer take -> root toggle -> nested take -> outer settle | cap and custody | direct tx tests omit root toggle | `PoC_Comp_CallbackRatifierRoot` |
| T-17 | two transactions | direct fill A -> disable root -> bundle B/C | cap across transactions | route helper state change absent | `PoC_Comp_RatifierPeripheryConsumed` |
| T-18 | post-maturity cleanup | oracle reverts -> dust bit cannot clear -> liquidate other index | liveness classification | bitmap and oracle tests separate | `PoC_Comp_MultiCollateralOracleGate` |
| T-19 | cross-market maturity mismatch | take A pre-maturity -> callback B post-maturity unwind | market isolation | callback tests single market | `PoC_Comp_CrossMarketSharedToken` |
| T-20 | repeated microfill horizon | loop route fills -> accrue -> slash -> claim | no material amplification | ordinary fuzz not economic benchmark | `PoC_Comp_DustDriftToNonDustLoss` |
