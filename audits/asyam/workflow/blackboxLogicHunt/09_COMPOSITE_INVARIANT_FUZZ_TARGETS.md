# Composite Invariant Fuzz Targets

Date: 2026-05-31

These are designs for later handlers. They are not implemented in this phase.

### INV-BB-001 — CrossMarketAggregateAccountingInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_CrossMarketAggregateAccounting.t.sol`
- **Handlers:** create same-token market, borrow, repay, withdraw, accrue/claim settlement fee, accrue/claim continuous fee.
- **Actors:** lenders, borrowers, fee claimer, market creator.
- **Tracked state:** token custody, collateral custody, all touched-market withdrawable, token-global settlement fees.
- **Invariant:** custody is at least aggregate withdrawable plus token-global settlement fees plus token-as-collateral custody.
- **Ghosts:** touched market IDs and expected collateral token totals.
- **Exclude:** malicious ERC20 and admin misconfiguration.
- **Discovery class:** cross-market deficit.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_CrossMarketAggregateAccounting.t.sol' -vvvv`

### INV-BB-002 — DeferredPositionUpdateInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_DeferredPositionUpdate.t.sol`
- **Handlers:** borrow, repay, create bounded bad debt, touch arbitrary lender, withdraw effective credit.
- **Actors:** fragmented lenders, borrowers, liquidator.
- **Tracked state:** stored/effective credit, pending fee, last loss factor, last accrual.
- **Invariant:** first touch equals pre-touch view; second touch is idempotent at fixed timestamp; exits cannot exceed effective claim.
- **Ghosts:** lender set and aggregate effective credits.
- **Exclude:** known one-wei lender rounding.
- **Discovery class:** lazy-state material branch flip.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_DeferredPositionUpdate.t.sol' -vvvv`

### INV-BB-003 — MaturityBoundaryStateMachineInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_MaturityBoundaryStateMachine.t.sol`
- **Handlers:** warp bounded timestamp, take, liquidate normal/post-maturity, repay.
- **Actors:** borrower, lender, liquidator.
- **Tracked state:** maturity, debt delta, seized collateral, LIF.
- **Invariant:** exposure does not increase post-maturity and each liquidation mode respects its boundary.
- **Ghosts:** last successful debt increase timestamp.
- **Exclude:** audited maturity-edge class unless a new sequence changes root cause.
- **Discovery class:** temporal branch inconsistency.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_MaturityBoundaryStateMachine.t.sol' -vvvv`

### INV-BB-004 — RatifierRouteConsumedInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_RatifierRouteConsumed.t.sol`
- **Handlers:** ratify/cancel root, set consumed, direct take, route take.
- **Actors:** maker, delegate, relayer, taker.
- **Tracked state:** roots, groups, consumed caps, refunds.
- **Invariant:** accepted consumption never exceeds signed cap; failed routes revert atomically.
- **Ghosts:** signed family cap.
- **Exclude:** direct cap rounding and canceled-root replay.
- **Discovery class:** intent-family composition.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_RatifierRouteConsumed.t.sol' -vvvv`

### INV-BB-005 — DelegatedAuthorizationIntentInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_DelegatedAuthorizationIntent.t.sol`
- **Handlers:** authorize, revoke, signed authorize, root set/cancel, bundle route.
- **Actors:** authorizer, delegate, relayer, unrelated account.
- **Tracked state:** authorization graph, nonces, roots, token and collateral deltas.
- **Invariant:** an unrelated account loses no assets without a matching direct or signed capability.
- **Ghosts:** accepted user-intent edges.
- **Exclude:** voluntary broad-delegate actions.
- **Discovery class:** ambient authority escalation.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_DelegatedAuthorizationIntent.t.sol' -vvvv`

### INV-BB-006 — BundleUserIntentInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_BundleUserIntent.t.sol`
- **Handlers:** four route variants, invalidate leg, warp, set fee, set consumed.
- **Actors:** route builder, delegated taker, makers, referral recipient.
- **Tracked state:** spend, proceeds, units, debt, collateral, refund, router residue.
- **Invariant:** explicit max/min arguments and atomic rollback hold across valid fallback routes.
- **Ghosts:** pre-route user balance snapshot.
- **Exclude:** documented stale quote revert and user-selected receiver loss.
- **Discovery class:** bound-compliant intent mismatch.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_BundleUserIntent.t.sol' -vvvv`

### INV-BB-007 — BadDebtRecoverabilityInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_BadDebtRecoverability.t.sol`
- **Handlers:** partial liquidate, zero-realize, repay, collateral change, bounded price change.
- **Actors:** borrower, lenders, liquidator.
- **Tracked state:** debt, collateral recoverable at max LIF, loss-factor delta.
- **Invariant:** newly socialized debt is no greater than debt unrecoverable at the state used for realization.
- **Ghosts:** pre/post recoverable debt mirror.
- **Exclude:** malicious zero oracle and known optimistic formula unless composition differs.
- **Discovery class:** avoidable social loss.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_BadDebtRecoverability.t.sol' -vvvv`

### INV-BB-008 — LossFactorWithdrawableCouplingInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_LossFactorWithdrawableCoupling.t.sol`
- **Handlers:** repay, bad-debt realization, touch subset, claim fee, withdraw.
- **Actors:** fragmented lenders, borrowers, fee claimer.
- **Tracked state:** total units, effective lender credit, fee credit, withdrawable, custody.
- **Invariant:** all withdrawal orders remain backed modulo declared dust.
- **Ghosts:** touched lenders and cumulative paid assets.
- **Exclude:** one-wei per-lender residue.
- **Discovery class:** order-dependent deficit.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_LossFactorWithdrawableCoupling.t.sol' -vvvv`

### INV-BB-009 — OracleGateConsentBoundaryInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_OracleGateConsentBoundary.t.sol`
- **Handlers:** create market, toggle oracle/gate, supply, route, borrow, liquidate.
- **Actors:** creator, delegated user, route builder, lender.
- **Tracked state:** selected market IDs and user intent edges.
- **Invariant:** liveness failure affects only actors with an explicit edge to the selected market.
- **Ghosts:** market-consent relation.
- **Exclude:** chosen bad-market risk.
- **Discovery class:** permissionless contamination.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_OracleGateConsentBoundary.t.sol' -vvvv`

### INV-BB-010 — FeeScheduleQuoteSettlementInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_FeeScheduleQuoteSettlement.t.sol`
- **Handlers:** quote snapshot, warp, set market fee, route execute.
- **Actors:** fee setter, route user, makers.
- **Tracked state:** quoted/current fee, accepted units, spend, proceeds.
- **Invariant:** successful route remains inside explicit current call bounds.
- **Ghosts:** route argument snapshots.
- **Exclude:** stale quote revert only.
- **Discovery class:** quote-settlement mismatch.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_FeeScheduleQuoteSettlement.t.sol' -vvvv`

### INV-BB-011 — CollateralBitmapIndexInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_CollateralBitmapIndex.t.sol`
- **Handlers:** supply/withdraw zero and nonzero collateral at bounded indices, repay, liquidate.
- **Actors:** borrower, delegate, liquidator.
- **Tracked state:** bitmap and all collateral balances.
- **Invariant:** a bit is active exactly when its collateral balance is nonzero.
- **Ghosts:** active index set.
- **Exclude:** out-of-range invalid input.
- **Discovery class:** bitmap/liveness desync.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_CollateralBitmapIndex.t.sol' -vvvv`

### INV-BB-012 — MultiRoleAttackerSequenceInvariant

- **Suggested file:** `test/asyam/invariant/composite/Invariant_MultiRoleAttackerSequence.t.sol`
- **Handlers:** maker offer, taker route, borrower debt, liquidator action, relayer auth.
- **Actors:** one attacker with multiple roles plus honest lender/borrower.
- **Tracked state:** attacker net assets and each honest user's liabilities.
- **Invariant:** attacker cannot externalize a gain beyond disclosed price or liquidation incentive without a matching victim-authorized edge.
- **Ghosts:** attacker net-flow mirror.
- **Exclude:** normal maker spread and liquidation reward.
- **Discovery class:** economic composition.
- **Command:** `forge test --match-path 'test/asyam/invariant/composite/Invariant_MultiRoleAttackerSequence.t.sol' -vvvv`
