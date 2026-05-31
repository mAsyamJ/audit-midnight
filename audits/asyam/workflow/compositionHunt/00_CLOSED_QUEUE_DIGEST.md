# Closed Queue Digest

Date: 2026-05-30

The AP queue is closed. “Opening” means a closed class can be reused only as one component of a materially different composition.

| AP | Title | Closed status | Tested file / evidence | Why closed | Defended invariant | Untested opening | Component? |
|---|---|---|---|---|---|---|---|
| AP-001 | Take callback temporary state | disproven | `PoC_TakeCallbackReentrancy.t.sol` | nested take has no profit and cap holds | `INV-005`, `INV-023` | callback plus maturity or ratifier mutation | yes |
| AP-002 | Consumed-cap rounding | duplicate/disproven | `PoC_OfferConsumedCapRounding.t.sol` | shared asset/unit caps hold | `INV-011` | shared group across ratified route plus callback | yes |
| AP-003 | reduceOnly exposure | disproven | `PoC_DeepValidationQueues.t.sol` | one-wei exposure crossing reverts | `INV-012` | reduce-only inside multi-offer route after prior state change | yes |
| AP-004 | Solvent-borrower bad debt | disproven | `PoC_LiquidationSolventBadDebt.t.sol` | only consenting oracle risk observed | `INV-007`, `INV-008` | multi-collateral liveness plus maturity sequencing | yes |
| AP-005 | Liquidation over-seize | disproven | `PoC_LiquidationOverSeize.t.sol` | seizure and RCF stay bounded | `INV-010` | flash-funded callback plus alternate market custody | yes |
| AP-006 | Post-maturity liquidation divergence | disproven | `PoC_PostMaturityLiquidation.t.sol` | LIF and seizure bounds hold | `INV-010` | same-block route, flash, and fee update ordering | yes |
| AP-007 | Bitmap desync | covered | native bitmap tests, `CollateralBitmap.spec` | slot/bitmap lifecycle covered | bitmap matches nonzero collateral | reverting oracle on one active index plus liquidation | yes |
| AP-008 | lossFactor over-slash | disproven/known | `PoC_LossFactorOverslash.t.sol` | slash tracks socialized bad debt | `INV-008` | slash plus stale position, fee claim, and withdraw | yes |
| AP-009 | withdrawable overstatement | covered | native fuzz, CVL | backed withdrawal path covered | `INV-003`, `INV-006` | cross-market same-token custody ordering | yes |
| AP-010 | pendingFee/lossFactor desync | duplicate/covered | `PoC_PendingFeeLossFactorSync.t.sol` | view/update sync and terminal guard hold | `INV-004` | slash plus partial repay and fee claim ordering | yes |
| AP-011 | Canceled root reuse | disproven | `PoC_CanceledRootReuse.t.sol` | canceled root cannot take | `INV-016` | canceled offer skipped inside route before valid fallback | yes |
| AP-012 | Delegate grief | duplicate/accepted | Spearbit/Blackthorn | broad scope is intended | `INV-018` | unauthorized power composition only | no |
| AP-013 | Signature field replay | partial, L-01 only | `PoC_SignatureMalleability.t.sol` | only high-s uniqueness issue proven | `INV-017` | delegate revocation and signed-route timing | yes |
| AP-014 | Periphery temporary balance leak | disproven | `PoC_BundleTemporaryBalanceReentrancy.t.sol` | fixed transfers block simple theft | `INV-019` | shared token across markets and nested route | yes |
| AP-015 | Exact target impossible | disproven/known | `PoC_BundleExactFillAlignment.t.sol` | helper aligns with core in tested paths | `INV-020` | one skipped ratified leg plus fee/referral target | yes |
| AP-016 | Helper revert breaks skip | invalid/documented | `PoC_BundleHelperRevertSemantics.t.sol` | helper revert intentionally aborts route | `INV-022` | only if a valid route violates documented guarantee | no |
| AP-017 | Permit2 unintended operation | invalid | source review, native tests | pull binds caller-owned source | pull-token intent | authorized delegate plus third-party route payer | yes |
| AP-018 | Oracle/gate forced victim | disproven | `PoC_EnterGateForcedDebt.t.sol` | enter gate blocks forced debt | `INV-025` | multi-collateral oracle liveness plus maturity | yes |
| AP-019 | Flash repayment bypass | disproven | `PoC_FlashLoanReentrancy.t.sol` | reimbursement and accounting hold | `INV-001` | liquidation callback plus loss update plus repay/withdraw | yes |
| AP-020 | Maturity-second accounting | covered | settlement fee tests, CVL | boundary fee behavior covered | `INV-014` | off-chain route built before boundary, executed after | yes |
| AP-021 | Repay callback reentrancy | duplicate-risk closed | Blackthorn L-19/L-26, current probes | no novel extraction proven | `INV-023` | repay nested inside liquidation or flash ordering | yes |
| AP-022 | CVL market ID aliasing | proven formal only | `PoC_SolvencySpecMarketIdAliasing.t.sol` | production IDs remain distinct | assurance identity | combine with executable multi-market route only | yes |
| AP-023 | Referral budget underflow | invalid | `PoC_DeepValidationQueues.t.sol` | underfunded budget reverts atomically | `INV-021` | exact target plus skipped root plus receiver split | yes |
| AP-024 | Same loan/collateral self-loop | disproven | `Validation_LiveQueues.t.sol` | concrete repay and liquidation unwind funded | custody | cross-market same-token or fee-socialization sequence | yes |
| AP-025 | roleSetter zero brick | proven Low | `PoC_RoleSetterBricking.t.sol` | admin footgun filed | role recoverability | no external exploit opening | no |
| AP-026 | Nested callback composition | partial slices disproven | `PoC_SellCallbackComposition.t.sol`, `PoC_LiquidateCallbackReentrancy.t.sol` | liquidate/flash sell slices do not profit | `INV-013`, `INV-023` | ratifier-root, maturity, or multi-market nested sequence | yes |

## Reuse Rule

No AP item is reopened directly. A later PoC must identify the second domain, the new transition, the new invariant, and why the prior test could not exercise that path.
