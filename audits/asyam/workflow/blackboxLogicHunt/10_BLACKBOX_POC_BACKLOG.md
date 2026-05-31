# Blackbox PoC Backlog

Date: 2026-05-31

### BB-POC-001 — Deferred Position Update

- **Source:** BL-001, SD-001..004, MTX-001.
- **Different root cause:** lazy state consumed by a later decision, not direct loss-factor synchronization.
- **Expected root cause:** stored and effective lender claims diverge until first touch.
- **Contracts/functions:** `Midnight.updatePositionView`, `updatePosition`, `withdraw`, `take`.
- **Setup/sequence:** open credit -> realize bounded bad debt -> leave lender stale -> compare stored/effective -> attempt exit and rollover.
- **Assertion:** all accepted exits and rollovers use effective credit; no material overclaim or lock.
- **Proof/disproof:** material accepted mismatch proves; sync-before-use or atomic revert disproves.
- **Severity ceiling:** Medium if non-dust lender loss or freeze.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_DeferredPositionUpdate.sol`
- **Command:** `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_DeferredPositionUpdate.sol' -vvvv`

### BB-POC-002 — Bad Debt Recoverability

- **Source:** BL-002, SD-018, MTX-013.
- **Different root cause:** recoverability changes across liquidation sequence, not a zero-oracle direct realization.
- **Contracts/functions:** `Midnight.liquidate`, `repay`, `withdrawCollateral`.
- **Setup/sequence:** healthy debt -> realistic bounded price drop -> partial liquidation -> zero-realization -> compare recoverable debt.
- **Assertion:** socialized units never exceed unrecoverable debt under the state used to realize loss.
- **Proof/disproof:** recoverable value remaining after excess slash proves; formula bound disproves.
- **Severity ceiling:** High if repeatable socialization theft; Medium if bounded.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_BadDebtRecoverability.sol`
- **Command:** `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_BadDebtRecoverability.sol' -vvvv`

### BB-POC-003 — User Intent Bundle

- **Source:** BL-003, BL-019, SD-024, MTX-017.
- **Different root cause:** economically different valid fallback, not temporary balance leakage or exact-fill arithmetic.
- **Contracts/functions:** four `MidnightBundles` route variants and `Midnight.take`.
- **Setup/sequence:** construct good and fallback legs -> invalidate good leg -> execute bound-compliant fallback -> inspect debt, collateral, balances.
- **Assertion:** route arguments bound all resulting spend, proceeds, units, and collateral effects.
- **Proof/disproof:** non-consenting value change outside args proves; explicit bound or rollback disproves.
- **Severity ceiling:** Medium.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_UserIntentBundle.sol`
- **Command:** `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_UserIntentBundle.sol' -vvvv`

### BB-POC-004 — Authorization Intent Split

- **Source:** BL-016..018, SD-014..015, MTX-007..008.
- **Different root cause:** composition of separate signed intents, not direct delegate grief or Permit2 caller mismatch.
- **Contracts/functions:** core authorization, `EcrecoverAuthorizer`, ratifiers, bundles.
- **Setup/sequence:** sign grant/revoke and root intents -> interleave submission -> execute route -> inspect unrelated balances.
- **Assertion:** no asset or collateral movement without a current matching capability.
- **Proof/disproof:** stale unrelated capability moves value proves; nonce and authorization checks disprove.
- **Severity ceiling:** High if third-party asset movement.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_AuthorizationIntentSplit.sol`
- **Command:** `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_AuthorizationIntentSplit.sol' -vvvv`

### BB-POC-005 — Quote Settlement Mismatch

- **Source:** BL-011, SD-016, MTX-005.
- **Different root cause:** successful fallback changes economic result after temporal state change, not stale-leg revert.
- **Contracts/functions:** settlement fee schedule, helper libraries, bundle loops.
- **Setup/sequence:** quote -> warp breakpoint or update fee -> execute route -> compare explicit bounds and final position.
- **Assertion:** accepted route remains within current call bounds and has no residual.
- **Proof/disproof:** accepted out-of-bound result proves; bounded result or atomic revert disproves.
- **Severity ceiling:** Medium.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_QuoteSettlementMismatch.sol`
- **Command:** `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_QuoteSettlementMismatch.sol' -vvvv`

### BB-POC-006 — Cross-Market Aggregate Accounting

- **Source:** BL-007..008, BL-021, SD-005..007, MTX-003.
- **Different root cause:** token-global settlement fees versus market-local liabilities, no callback dependence.
- **Contracts/functions:** `take`, `repay`, `withdraw`, `claimSettlementFee`, `claimContinuousFee`.
- **Setup/sequence:** accrue fee A -> repay B -> claim fee -> withdraw B -> reverse ordering.
- **Assertion:** core token balance always covers aggregate same-token withdrawable and claimable settlement fee.
- **Proof/disproof:** valid later claim starved proves; all orderings backed disproves.
- **Severity ceiling:** High.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_CrossMarketAggregateAccounting.sol`
- **Command:** `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_CrossMarketAggregateAccounting.sol' -vvvv`

### BB-POC-007 — Permissionless Market Contamination

- **Source:** BL-009..010, PM-001..004.
- **Different root cause:** bad-market risk crossing consent boundary, not chosen liveness.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_PermissionlessMarketContamination.sol`
- **Sequence/assertion:** relayer routes delegated user toward bad market; prove route rejects mismatch or classify broad consent.
- **Severity ceiling:** Medium.

### BB-POC-008 — Dust to Non-Dust State Flip

- **Source:** BL-026, AD-003, MTX-021.
- **Different root cause:** rounding activates material branch, not residue theft.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_DustToNonDustStateFlip.sol`
- **Sequence/assertion:** repeat bounded micro-defaults and touches; assert no non-dust payout, freeze, or health flip.
- **Severity ceiling:** Medium.

### BB-POC-009 — Event Storage Mismatch

- **Source:** BL-025, SD-021..022, MTX-020.
- **Different root cause:** monitoring reconstruction, not runtime accounting.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_EventStorageMismatch.sol`
- **Sequence/assertion:** replay core events across slash, touch, fee claim, withdrawal; compare replay mirror to storage.
- **Severity ceiling:** Low/P3 unless loss escalation.

### BB-POC-010 — Deferred Loss Factor Withdraw

- **Source:** BL-022, SD-007..008, MTX-022.
- **Different root cause:** fragmented lazy lenders plus claim ordering.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_DeferredLossFactorWithdraw.sol`
- **Sequence/assertion:** touch lender subset, claim fee, exit remaining lenders; aggregate backing modulo dust.
- **Severity ceiling:** Medium.

### BB-POC-011 — RCF Threshold State Flip

- **Source:** BL-013, AD-009, MTX-015.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_RcfThresholdStateFlip.sol`
- **Assertion:** quantify full-vs-partial liquidation at neighboring threshold values and classify intended policy.
- **Severity ceiling:** Medium only if attacker-controlled non-consenting loss.

### BB-POC-012 — Multi-Collateral Liquidation Order

- **Source:** BL-014, AI-017, MTX-014.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_MultiCollateralLiquidationOrder.sol`
- **Assertion:** collateral choice cannot create avoidable social loss beyond documented incentive differences.
- **Severity ceiling:** Medium.

### BB-POC-013 — Bundle Repay Dust Lock

- **Source:** BL-023, AD-025, MTX-011..012.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_BundleRepayDustLock.sol`
- **Assertion:** compare fee-bearing debt-1 and exact debt exits; retain only unauthorized relayer path.
- **Severity ceiling:** Medium if imposed on non-consenting borrower.

### BB-POC-014 — Collateral Supply Atomicity

- **Source:** AD-017, PM-013, MTX-010.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_CollateralSupplyAtomicity.sol`
- **Assertion:** seventeenth activation reverts entire bundle including earlier pulls and supplies.
- **Severity ceiling:** Low unless funds strand.

### BB-POC-015 — Maturity Route Boundary

- **Source:** BL-012, AD-010, MTX-018, MTX-026.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_MaturityRouteBoundary.sol`
- **Assertion:** debt exposure cannot increase after maturity through fallback route.
- **Severity ceiling:** Medium.

### BB-POC-016 — Group Family Ambiguity

- **Source:** BL-006, SD-011, MTX-023..024.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_GroupFamilyAmbiguity.sol`
- **Assertion:** classify same-group opposite-side and cross-token behavior as user configuration unless involuntary effect proven.
- **Severity ceiling:** Low.

### BB-POC-017 — Forced Position Touch

- **Source:** BL-029, AI-019.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_ForcedPositionTouch.sol`
- **Assertion:** permissionless touch cannot create economics beyond already-accrued loss and fee.
- **Severity ceiling:** Low unless reliable loss.

### BB-POC-018 — Bitmap Zero Path

- **Source:** SD-009..010, AD-016, MTX-019.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_BitmapZeroPath.sol`
- **Assertion:** no-op supply/withdraw never activates or clears a nonzero collateral incorrectly.
- **Severity ceiling:** Low.

### BB-POC-019 — Multi-Market Token-As-Collateral

- **Source:** PM-019, AI-024..025.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_TokenAsCollateralAggregate.sol`
- **Assertion:** aggregate custody covers collateral plus withdrawable plus token-global fees where one token serves multiple roles.
- **Severity ceiling:** High.

### BB-POC-020 — Full Event Replay

- **Source:** BL-028, AI-020..021.
- **Path:** `test/asyam/poc/blackbox/PoC_Blackbox_FullEventReplay.sol`
- **Assertion:** event mirror distinguishes full market consent tuple and reconstructs persistent state.
- **Severity ceiling:** P3.
