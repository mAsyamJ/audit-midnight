# Pattern Based PoC Backlog

Backlog entries are hypotheses only. Implement only after a fresh dedup pass.

### PT-POC-001 - Duplicate-token flash-array settlement
- Pattern source: `duplicate batch-asset entries`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `flashLoan`.
- Actors: permissionless caller and local repayment callback.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Repeat one standard token in `tokens[]`, vary split amounts and order, overlap protocol-held custody, and compare against one aggregated loan.
- Expected invariant: Custody after callback equals custody before callback for each token and liabilities remain backed.
- Expected assertion: Custody after callback equals custody before callback for each token and liabilities remain backed.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_DuplicateTokenFlashArray.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_DuplicateTokenFlashArray.t.sol -vvvv`.
- Priority: `P0`.

### PT-POC-002 - Multicall state-transition composition
- Pattern source: `multicall semantic reuse`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `multicall plus public or legitimately authorized core methods`.
- Actors: permissionless actor or valid delegate.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Batch state transitions that normally occur across transactions and compare with sequential execution.
- Expected invariant: No batching-only debt escape, collateral escape, cap bypass, or third-party transfer.
- Expected assertion: No batching-only debt escape, collateral escape, cap bypass, or third-party transfer.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_MulticallStateTransition.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_MulticallStateTransition.t.sol -vvvv`.
- Priority: `P0`.

### PT-POC-003 - Liquidation-order social-loss divergence
- Pattern source: `liquidator-selected basket ordering`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `liquidate`.
- Actors: borrower, lender, and liquidator.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Create equivalent multi-collateral positions, liquidate collateral indexes in alternate orders, and reconcile private proceeds plus social loss.
- Expected invariant: Equivalent initial positions cannot create avoidable lender loss solely from attacker-selected order.
- Expected assertion: Equivalent initial positions cannot create avoidable lender loss solely from attacker-selected order.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_LiquidationOrderSocialLoss.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_LiquidationOrderSocialLoss.t.sol -vvvv`.
- Priority: `P0`.

### PT-POC-004 - Continuous-fee claim context switch
- Pattern source: `lazy claim context change`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `claimContinuousFee / _updatePosition / withdraw / liquidate`.
- Actors: fragmented lenders, borrower, fee claimer.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Accrue fees, touch lender subsets, create bounded loss, claim, withdraw, and compare eager-touch control.
- Expected invariant: Aggregate lender payouts plus fee claim remain backed and control-equivalent.
- Expected assertion: Aggregate lender payouts plus fee claim remain backed and control-equivalent.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_ClaimContextSwitch.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_ClaimContextSwitch.t.sol -vvvv`.
- Priority: `P0`.

### PT-POC-005 - Partial-success poison route
- Pattern source: `aggregator earlier-effect plus hostile later leg`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `MidnightBundles loops / take / ratifier`.
- Actors: route caller and local hostile ratifier.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Execute a valid leg before a bounded failing or gas-heavy leg and inspect atomicity or continuation.
- Expected invariant: No stranded collateral or preserved unintended partial economics.
- Expected assertion: No stranded collateral or preserved unintended partial economics.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_PartialSuccessPoisonRoute.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_PartialSuccessPoisonRoute.t.sol -vvvv`.
- Priority: `P0`.

### PT-POC-006 - Ratified family semantic collision
- Pattern source: `Merkle leaf family mismatch`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `HashLib / EcrecoverRatifier / setConsumed`.
- Actors: maker, relayer, taker.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Construct signed roots and groups with distinct economic family expectations.
- Expected invariant: One family cannot consume or unlock another without equivalent maker intent.
- Expected assertion: One family cannot consume or unlock another without equivalent maker intent.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_RatifierFamilySemantic.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_RatifierFamilySemantic.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-007 - Involuntary oracle-route contamination
- Pattern source: `permissionless bad-market consent leak`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `MidnightBundles / IOracle / withdrawCollateral`.
- Actors: route builder and victim.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Mix a bad-liveness market into route execution and prove whether victim consent is explicit.
- Expected invariant: No unchosen market exposure can force a later loss.
- Expected assertion: No unchosen market exposure can force a later loss.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_OracleRouteConsent.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_OracleRouteConsent.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-008 - RCF threshold collateral-order flip
- Pattern source: `dust-to-material liquidation threshold`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `liquidate`.
- Actors: borrower, lender, liquidator.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Place state around RCF and compare collateral order with a one-wei perturbation.
- Expected invariant: One wei cannot trigger non-dust avoidable lender loss.
- Expected assertion: One wei cannot trigger non-dust avoidable lender loss.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_RcfCollateralOrderFlip.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_RcfCollateralOrderFlip.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-009 - Permit receiver-referral split
- Pattern source: `signed pull versus economic beneficiary`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `MidnightBundles / Permit2 / ERC2612`.
- Actors: token owner, relayer, receiver, referral recipient.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Hold pull authority constant while changing route beneficiary fields.
- Expected invariant: Signed token pull cannot fund an unbound economic beneficiary.
- Expected assertion: Signed token pull cannot fund an unbound economic beneficiary.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_PermitBeneficiarySplit.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_PermitBeneficiarySplit.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-010 - Read-only intermediate-state route influence
- Pattern source: `transient observation`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `callback / oracle / MidnightBundles`.
- Actors: maker callback and route caller.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Observe intermediate state in one leg and use it to alter a later leg.
- Expected invariant: Later settlement remains backed and within user bounds.
- Expected assertion: Later settlement remains backed and within user bounds.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_IntermediateObservation.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_IntermediateObservation.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-011 - Standard-token approval residue sequence
- Pattern source: `approval lifecycle mismatch`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `forceApproveMax / pullToken`.
- Actors: bundle caller.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Run repeated standard-token routes and inspect allowances plus custody.
- Expected invariant: No later route can move funds beyond fresh caller-authorized pull.
- Expected assertion: No later route can move funds beyond fresh caller-authorized pull.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_ApprovalResidue.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_ApprovalResidue.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-012 - ERC2612 tolerate-front-run context switch
- Pattern source: `permit front-run semantic change`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `pullToken`.
- Actors: owner, relayer.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Consume permit first, leave allowance, then execute changed route.
- Expected invariant: Fallback allowance cannot widen economic intent.
- Expected assertion: Fallback allowance cannot widen economic intent.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_Erc2612ContextSwitch.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_Erc2612ContextSwitch.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-013 - Gate liveness maturity escalation
- Pattern source: `liveness-to-loss`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `IGate / maturity / withdrawCollateral / liquidate`.
- Actors: route victim and market adversary.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Acquire position indirectly, change gate behavior, cross maturity, attempt exit and liquidation.
- Expected invariant: Indirect exposure cannot force avoidable non-dust loss.
- Expected assertion: Indirect exposure cannot force avoidable non-dust loss.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_GateMaturityEscalation.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_GateMaturityEscalation.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-014 - Shared-token nested callback aggregate custody
- Pattern source: `per-market versus aggregate backing`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `take / callback / multiple markets`.
- Actors: maker callback and taker.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Use shared loan token markets and a nested backed state action.
- Expected invariant: Aggregate custody covers aggregate liabilities.
- Expected assertion: Aggregate custody covers aggregate liabilities.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_SharedTokenNestedCustody.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_SharedTokenNestedCustody.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-015 - Maker-liquidity disappearance exact route
- Pattern source: `non-escrowed liquidity race`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `buyExact / sellExact`.
- Actors: maker and route caller.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Remove maker liquidity after route planning and rely on fallback legs.
- Expected invariant: Exact bounds hold or transaction reverts atomically.
- Expected assertion: Exact bounds hold or transaction reverts atomically.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_NonEscrowedLiquidityRace.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_NonEscrowedLiquidityRace.t.sol -vvvv`.
- Priority: `P1`.

### PT-POC-016 - Root replacement fallback economics
- Pattern source: `root lifecycle versus prepared route`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `ratifier / MidnightBundles`.
- Actors: maker, delegate, relayer.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Partially consume, cancel, re-ratify different root, and execute prepared route.
- Expected invariant: Prepared route cannot exceed explicit user bounds.
- Expected assertion: Prepared route cannot exceed explicit user bounds.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_RootReplacementFallback.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_RootReplacementFallback.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-017 - Collateral index activation permutation
- Pattern source: `bitmap ordering`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `supplyCollateral / withdrawCollateral / liquidate`.
- Actors: borrower and liquidator.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Activate and zero collateral indexes in permutations before liquidation.
- Expected invariant: Bitmap-selected set equals nonzero balance set.
- Expected assertion: Bitmap-selected set equals nonzero balance set.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_CollateralActivationOrder.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_CollateralActivationOrder.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-018 - Maximum collateral index boundary
- Pattern source: `array index boundary`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `createMarket / liquidate`.
- Actors: market creator, borrower, liquidator.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Exercise the highest valid collateral index and liquidation.
- Expected invariant: Selected collateral is the intended array member.
- Expected assertion: Selected collateral is the intended array member.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_MaxCollateralIndex.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_MaxCollateralIndex.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-019 - Continuous-fee threshold health flip
- Pattern source: `dust-to-material branch`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `_updatePosition / withdrawCollateral`.
- Actors: borrower and lender.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Accrue one wei around fee threshold before health-sensitive exit.
- Expected invariant: Dust cannot enable material collateral escape or forced retention.
- Expected assertion: Dust cannot enable material collateral escape or forced retention.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_FeeHealthThreshold.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_FeeHealthThreshold.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-020 - Tick threshold liquidation branch
- Pattern source: `price precision branch`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `TickLib / take / liquidate`.
- Actors: maker, borrower, liquidator.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Exercise adjacent ticks then follow lifecycle into liquidation.
- Expected invariant: Precision difference cannot externalize non-dust loss.
- Expected assertion: Precision difference cannot externalize non-dust loss.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_TickLiquidationThreshold.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_TickLiquidationThreshold.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-021 - Maturity quote route lifecycle
- Pattern source: `time-of-quote versus settlement`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `MidnightBundles / take`.
- Actors: route caller and makers.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Build fallback route before maturity and execute at the exact boundary.
- Expected invariant: Bounds hold or route reverts atomically.
- Expected assertion: Bounds hold or route reverts atomically.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_MaturityRouteQuote.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_MaturityRouteQuote.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-022 - Relayer authorization referral composition
- Pattern source: `valid grant with beneficiary substitution`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `EcrecoverAuthorizer / MidnightBundles`.
- Actors: user, relayer, referral recipient.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Use valid authorization while varying referral and receiver.
- Expected invariant: No unbound beneficiary receives user-funded value.
- Expected assertion: No unbound beneficiary receives user-funded value.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_RelayerReferralIntent.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_RelayerReferralIntent.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-023 - Ratifier return-data grief after valid leg
- Pattern source: `external-call grief to value loss`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `ratifier / MidnightBundles`.
- Actors: route caller and hostile ratifier.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Use bounded large return or revert data after an earlier valid leg.
- Expected invariant: Failure rolls back or cannot force third-party economic loss.
- Expected assertion: Failure rolls back or cannot force third-party economic loss.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_RatifierReturnDataGrief.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_RatifierReturnDataGrief.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-024 - Event-storage reconstruction mismatch
- Pattern source: `monitoring blindspot`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `events / _updatePosition`.
- Actors: indexer and lenders.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Replay events around lazy loss and fee settlement and compare storage.
- Expected invariant: Any reconstruction gap is documented; promote only with concrete economic escalation.
- Expected assertion: Any reconstruction gap is documented; promote only with concrete economic escalation.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_EventStorageMismatch.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_EventStorageMismatch.t.sol -vvvv`.
- Priority: `P2`.

### PT-POC-025 - Lazy-loss eager-touch control
- Pattern source: `deferred update order`.
- Why net-new: Tests a transplanted mechanism boundary rather than reopening a previously closed direct class.
- Files/functions: `_updatePosition / liquidate / withdraw`.
- Actors: multiple lenders and borrower.
- Setup: Use standard ERC20s, real core entrypoints, and minimal local mocks only.
- Transaction sequence: Compare eager-touch control with adversarial subset-touch ordering.
- Expected invariant: Aggregate redemption value is ordering-independent.
- Expected assertion: Aggregate redemption value is ordering-independent.
- Impact if true: Promote only for realistic non-dust harm to a non-consenting actor.
- Likelihood if true: Reassess after the local trace establishes reachable preconditions.
- False-positive traps: Intended market risk, caller-selected bad route, delegated authority, weird-token behavior, dust-only drift, or audited duplicate.
- Suggested test path: `test/asyam/poc/pattern/PoC_Pattern_LazyLossControl.t.sol`.
- Run command: `forge test --match-path test/asyam/poc/pattern/PoC_Pattern_LazyLossControl.t.sol -vvvv`.
- Priority: `P2`.
