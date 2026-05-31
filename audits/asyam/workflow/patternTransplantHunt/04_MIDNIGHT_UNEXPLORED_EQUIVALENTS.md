# Midnight Unexplored Equivalents

All entries are transplanted hypotheses. `new_poc_queue` means locally testable, not proven.

### MUE-001 - Duplicate-token flash-array settlement
- External pattern source: Historical `duplicate-token flash-array settlement` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `Midnight.flashLoan`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `Midnight.flashLoan` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Repeat one standard ERC20 in tokens[] with split amounts, overlap held custody, repay callback, and compare aggregate backing.
- Expected invariant break: Each token leaves the call with custody unchanged after the sum of obligations.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `Midnight.flashLoan` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-002 - Multicall state-transition composition
- External pattern source: Historical `multicall state-transition composition` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `Midnight.multicall`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `Midnight.multicall` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Batch permissionless or legitimately authorized actions that are normally separated by an observation boundary.
- Expected invariant break: Batching cannot escape debt, collateral health, cap, or custody checks.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `Midnight.multicall` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-003 - Liquidation-order private-gain divergence
- External pattern source: Historical `liquidation-order private-gain divergence` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `Midnight.liquidate`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `Midnight.liquidate` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Liquidate equivalent multi-collateral positions in alternate order and compare proceeds plus social loss.
- Expected invariant break: Collateral ordering cannot create avoidable lender loss beyond documented incentives.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `Midnight.liquidate` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-004 - Lazy fee-claim context switch
- External pattern source: Historical `lazy fee-claim context switch` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `claimContinuousFee / withdraw`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `claimContinuousFee / withdraw` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Touch only a subset of lenders around accrued fees, bounded bad debt, claim, repay, and withdrawal.
- Expected invariant break: Claim plus lender withdrawals remains backed and order-independent.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `claimContinuousFee / withdraw` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-005 - Partial-success poison route
- External pattern source: Historical `partial-success poison route` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `MidnightBundles take loops`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `MidnightBundles take loops` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Execute a valid route leg, then a bounded failing or gas-heavy ratifier leg, then inspect rollback or continuation.
- Expected invariant break: Route failure cannot strand collateral or preserve partial unintended economics.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `MidnightBundles take loops` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-006 - Ratified Merkle leaf economic-family collision
- External pattern source: Historical `ratified merkle leaf economic-family collision` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `HashLib / EcrecoverRatifier / setConsumed`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `HashLib / EcrecoverRatifier / setConsumed` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Compare signed leaves whose local fields are valid but whose group meaning crosses order families.
- Expected invariant break: One maker-signed economic family cannot consume or unlock another without equivalent intent.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `HashLib / EcrecoverRatifier / setConsumed` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-007 - Involuntary oracle-liveness route contamination
- External pattern source: Historical `involuntary oracle-liveness route contamination` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `MidnightBundles / IOracle`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `MidnightBundles / IOracle` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Route an actor through a market whose oracle liveness later blocks a time-sensitive exit.
- Expected invariant break: A victim cannot acquire unsafe-market exposure without explicit consent.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `MidnightBundles / IOracle` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-008 - RCF one-wei flip after collateral-order choice
- External pattern source: Historical `rcf one-wei flip after collateral-order choice` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `Midnight.liquidate`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `Midnight.liquidate` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Place state around the RCF boundary and compare selected collateral order.
- Expected invariant break: A tiny threshold change cannot enable non-dust private extraction.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `Midnight.liquidate` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-009 - Permit receiver-referral semantic split
- External pattern source: Historical `permit receiver-referral semantic split` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `MidnightBundles / Permit2 / ERC2612`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `MidnightBundles / Permit2 / ERC2612` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Use valid pull authority while varying receiver and referral in an economically distinct route.
- Expected invariant break: Token-pull consent cannot authorize an unbound economic beneficiary.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `MidnightBundles / Permit2 / ERC2612` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-010 - Read-only intermediate-state route influence
- External pattern source: Historical `read-only intermediate-state route influence` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `ICallbacks / IOracle / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `ICallbacks / IOracle / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Observe intermediate state during one leg and use it to select or affect a later leg.
- Expected invariant break: Intermediate observations cannot create an unbacked later settlement.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `ICallbacks / IOracle / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-011 - Flash empty-array callback as route primitive
- External pattern source: Historical `flash empty-array callback as route primitive` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `Midnight.flashLoan / ICallbacks`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `Midnight.flashLoan / ICallbacks` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Invoke callback with empty arrays only as a component of a later state transition.
- Expected invariant break: Empty temporary-liquidity calls cannot bypass an unrelated invariant.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `Midnight.flashLoan / ICallbacks` with an adversarial/control comparison.
- Dedup notes: Status `dedup_only`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-012 - Force-approve residue under standard token
- External pattern source: Historical `force-approve residue under standard token` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `MidnightBundles.forceApproveMax`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `MidnightBundles.forceApproveMax` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Execute repeated standard-token routes and inspect allowances plus token custody.
- Expected invariant break: Residual allowance cannot move caller funds outside caller-authorized pulls.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `MidnightBundles.forceApproveMax` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-013 - ERC2612 tolerate-front-run semantic change
- External pattern source: Historical `erc2612 tolerate-front-run semantic change` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `MidnightBundles.pullToken`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `MidnightBundles.pullToken` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Front-run permit consumption, retain allowance, and execute a different route context.
- Expected invariant break: Tolerance cannot widen the economic intent beyond the allowance owner decision.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `MidnightBundles.pullToken` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-014 - Gate liveness plus maturity exit loss
- External pattern source: Historical `gate liveness plus maturity exit loss` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `IGate / liquidate / withdrawCollateral`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `IGate / liquidate / withdrawCollateral` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Combine a route-acquired market position, gate liveness change, and maturity boundary.
- Expected invariant break: A third party cannot force time-sensitive loss through indirect gate exposure.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `IGate / liquidate / withdrawCollateral` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-015 - Multi-market aggregate custody after nested callback
- External pattern source: Historical `multi-market aggregate custody after nested callback` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `take / callback / shared loan token`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `take / callback / shared loan token` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Use standard shared token markets and a later callback state action, then reconcile aggregate custody.
- Expected invariant break: Per-market local settlement composes into aggregate token backing.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `take / callback / shared loan token` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-016 - Settlement fee claim around shared custody
- External pattern source: Historical `settlement fee claim around shared custody` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `claimSettlementFee / shared token markets`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `claimSettlementFee / shared token markets` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Accrue and claim fees while another market uses the same standard token and compare custody.
- Expected invariant break: Claims cannot spend backing attributable to another market.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `claimSettlementFee / shared token markets` with an adversarial/control comparison.
- Dedup notes: Status `dedup_only`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-017 - Maker liquidity disappearance after partial route
- External pattern source: Historical `maker liquidity disappearance after partial route` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `MidnightBundles / take`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `MidnightBundles / take` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Build multiple-leg route where non-escrowed maker balance vanishes after an earlier valid leg.
- Expected invariant break: User aggregate bounds and atomicity hold despite disappearing maker liquidity.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `MidnightBundles / take` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-018 - Root replacement changes fallback economics
- External pattern source: Historical `root replacement changes fallback economics` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `EcrecoverRatifier / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `EcrecoverRatifier / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Consume partially, cancel root, activate a semantically different root, execute prepared route.
- Expected invariant break: Prepared route cannot violate explicit user bounds after root lifecycle change.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `EcrecoverRatifier / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-019 - Repeated collateral index activation order
- External pattern source: Historical `repeated collateral index activation order` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `supplyCollateral / withdrawCollateral / liquidate`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `supplyCollateral / withdrawCollateral / liquidate` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Activate and zero multiple indexes in differing orders before liquidation.
- Expected invariant break: Bitmap and balances select the same collateral set.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `supplyCollateral / withdrawCollateral / liquidate` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-020 - Index boundary at maximum collateral length
- External pattern source: Historical `index boundary at maximum collateral length` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `createMarket / liquidate`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `createMarket / liquidate` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Exercise highest valid collateral index with alternate activation order.
- Expected invariant break: Collateral index arithmetic cannot address the wrong asset.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `createMarket / liquidate` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-021 - Zero-withdraw bitmap transition as composition component
- External pattern source: Historical `zero-withdraw bitmap transition as composition component` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `withdrawCollateral`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `withdrawCollateral` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Issue zero withdrawal before later oracle/gate and liquidation actions.
- Expected invariant break: Zero-value calls cannot alter later non-dust decisions.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `withdrawCollateral` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-022 - Continuous-fee threshold flips health decision
- External pattern source: Historical `continuous-fee threshold flips health decision` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `_updatePosition / withdrawCollateral`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `_updatePosition / withdrawCollateral` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Accrue exactly around fee rounding boundary before health-sensitive action.
- Expected invariant break: Dust cannot trigger material collateral retention or escape.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `_updatePosition / withdrawCollateral` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-023 - Tick conversion one-wei liquidation branch
- External pattern source: Historical `tick conversion one-wei liquidation branch` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `TickLib / take / liquidate`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `TickLib / take / liquidate` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Set prices around tick conversion and follow through liquidation.
- Expected invariant break: Precision remainder cannot create non-dust social loss.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `TickLib / take / liquidate` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-024 - Route quote survives maturity transition
- External pattern source: Historical `route quote survives maturity transition` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `MidnightBundles / take / maturity`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `MidnightBundles / take / maturity` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Build route before maturity and execute at boundary with fallback offers.
- Expected invariant break: Lifecycle change cannot silently widen user economics.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `MidnightBundles / take / maturity` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-025 - Relayer combines signed authorization and referral
- External pattern source: Historical `relayer combines signed authorization and referral` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `EcrecoverAuthorizer / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `EcrecoverAuthorizer / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Use an authorized relayer with a valid grant and substitute route beneficiary fields.
- Expected invariant break: Grant semantics remain bounded to user-authorized economic effects.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `EcrecoverAuthorizer / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-026 - Ratifier return-data grief after earlier route effect
- External pattern source: Historical `ratifier return-data grief after earlier route effect` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `ratifier / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `ratifier / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Use bounded oversized return or revert data in a later route leg.
- Expected invariant break: A hostile leg cannot preserve earlier unintended state or force third-party loss.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `ratifier / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-027 - Oracle return-data grief during protective action
- External pattern source: Historical `oracle return-data grief during protective action` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `IOracle / withdrawCollateral / liquidate`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `IOracle / withdrawCollateral / liquidate` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Use bounded oracle failure only after indirect route exposure.
- Expected invariant break: Liveness fault cannot become involuntary solvency loss.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `IOracle / withdrawCollateral / liquidate` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-028 - Callback later-leg gas grief
- External pattern source: Historical `callback later-leg gas grief` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `take callback / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `take callback / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Spend bounded gas after one successful route leg and inspect transaction atomicity.
- Expected invariant break: Callback grief cannot strand route-owned value.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `take callback / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-029 - Consumed semantic collision across market IDs
- External pattern source: Historical `consumed semantic collision across market ids` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `setConsumed / HashLib / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `setConsumed / HashLib / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Reuse group identifier across markets with distinct economic meaning.
- Expected invariant break: Consumed accounting cannot cross maker intent boundaries unexpectedly.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `setConsumed / HashLib / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-030 - Formal external-call summary excludes route state
- External pattern source: Historical `formal external-call summary excludes route state` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `certora/** / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `certora/** / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Map unresolved calls and unmodelled periphery into an executable harness plan.
- Expected invariant break: Formal assurance gaps require runtime reproduction before severity promotion.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `certora/** / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `methodology_only`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-031 - Event reconstruction misses lazy position settlement
- External pattern source: Historical `event reconstruction misses lazy position settlement` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `events / _updatePosition`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `events / _updatePosition` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Replay emitted events around lazy fee and loss updates and compare storage.
- Expected invariant break: Indexers can reconstruct economically relevant state or docs identify limitation.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `events / _updatePosition` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-032 - Claimable fee zero-to-nonzero discontinuity
- External pattern source: Historical `claimable fee zero-to-nonzero discontinuity` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `claimContinuousFee`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `claimContinuousFee` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Cross minimum claim threshold then continue into lender withdrawal.
- Expected invariant break: Claim threshold cannot shift a material liability.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `claimContinuousFee` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-033 - Withdrawal equality branch after loss update
- External pattern source: Historical `withdrawal equality branch after loss update` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `withdraw / _updatePosition`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `withdraw / _updatePosition` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Place lender claim one wei around withdrawable equality after bounded social loss.
- Expected invariant break: Equality boundary cannot externalize another lender's backing.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `withdraw / _updatePosition` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-034 - Non-escrowed maker balance race plus exact route
- External pattern source: Historical `non-escrowed maker balance race plus exact route` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `MidnightBundles buyExact / sellExact`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `MidnightBundles buyExact / sellExact` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Remove maker balance between quote and route while preserving alternate offers.
- Expected invariant break: Exact-route bounds remain enforced under liquidity race.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `MidnightBundles buyExact / sellExact` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-035 - Market creator plus route-builder consent mismatch
- External pattern source: Historical `market creator plus route-builder consent mismatch` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `createMarket / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `createMarket / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Place a malicious quality market into mixed route and prove whether user consent is explicit.
- Expected invariant break: Permissionless creation cannot contaminate an unrelated user position.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `createMarket / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-036 - Multi-collateral oracle asymmetry after partial repay
- External pattern source: Historical `multi-collateral oracle asymmetry after partial repay` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `repay / liquidate / IOracle`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `repay / liquidate / IOracle` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Partially repay before asymmetric oracle liveness and order-selective liquidation.
- Expected invariant break: Repay cannot worsen recoverability through order-dependent accounting.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `repay / liquidate / IOracle` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-037 - Flash duplicate array plus multicall nesting
- External pattern source: Historical `flash duplicate array plus multicall nesting` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `flashLoan / multicall`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `flashLoan / multicall` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Use repeated tokens and callback multicall without direct repayment bypass assumptions.
- Expected invariant break: Nested standard-token settlement remains aggregate-backed.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `flashLoan / multicall` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-038 - Ratified root same-leaf duplicate proof
- External pattern source: Historical `ratified root same-leaf duplicate proof` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `HashLib / ratifier`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `HashLib / ratifier` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Test duplicated proof elements and repeated leaf consumption as economic-family component.
- Expected invariant break: Proof structure cannot widen fill authority.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `HashLib / ratifier` with an adversarial/control comparison.
- Dedup notes: Status `dedup_only`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-039 - Maturity quote plus authorization revocation ordering
- External pattern source: Historical `maturity quote plus authorization revocation ordering` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `take / setIsAuthorized / MidnightBundles`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `take / setIsAuthorized / MidnightBundles` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Prepare route, change delegation, cross maturity, and execute.
- Expected invariant break: Authorization and lifecycle checks bind at settlement.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `take / setIsAuthorized / MidnightBundles` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.

### MUE-040 - LossFactor control execution with all positions touched
- External pattern source: Historical `lossfactor control execution with all positions touched` mechanism from the taxonomy and public report corpus.
- Midnight equivalent: `_updatePosition / liquidate / withdraw`.
- Why previous process may have missed it: Earlier PoCs closed simpler direct variants; this entry adds a distinct mechanism boundary.
- Files/functions: `_updatePosition / liquidate / withdraw` and adjacent accounting or periphery helpers.
- State variables: `marketState`, `position`, `consumed`, `withdrawable`, `lossFactor`, token custody, or route-local balances as applicable.
- Actors: Permissionless caller, maker, lender, borrower, liquidator, relayer, or controlled local callback as applicable.
- Attack sequence: Compare adversarial touch order with eager-touch control.
- Expected invariant break: Lazy updates cannot change aggregate redemption value.
- Expected impact: Promote only for reliable non-dust harm affecting a non-consenting actor.
- False-positive risk: High until a compiling Foundry PoC distinguishes intended semantics and prior audited roots.
- Suggested PoC: Start from `_updatePosition / liquidate / withdraw` with an adversarial/control comparison.
- Dedup notes: Status `new_poc_queue`. Recheck `03_DEDUP_MAP.md` and `POC_RESULTS.md` before implementation.
