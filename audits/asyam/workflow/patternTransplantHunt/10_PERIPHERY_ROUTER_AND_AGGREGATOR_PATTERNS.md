# Periphery Router And Aggregator Patterns

These entries are attack-planning prompts. They are not findings and must pass the local proof and dedup gates.

### PRA-001 - Partial-Success Poison Leg Through MidnightBundles
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `partial-success poison leg` from `MidnightBundles` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `partial-success poison leg` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-002 - Final Transfer Balance Versus Delta Through pullToken
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `final transfer balance versus delta` from `pullToken` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `final transfer balance versus delta` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-003 - Approval Residue Across Routes Through forceApproveMax
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `approval residue across routes` from `forceApproveMax` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `approval residue across routes` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-004 - Mixed-Market Consent Ambiguity Through buy
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `mixed-market consent ambiguity` from `buy` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `mixed-market consent ambiguity` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-005 - Same Maker Group Across Fallback Offers Through buyExact
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `same maker group across fallback offers` from `buyExact` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `same maker group across fallback offers` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-006 - Multiple Roots In One Route Through sell
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `multiple roots in one route` from `sell` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `multiple roots in one route` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-007 - Permit Owner And Economic Beneficiary Differ Through sellExact
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `permit owner and economic beneficiary differ` from `sellExact` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `permit owner and economic beneficiary differ` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-008 - Pull From Caller But Execute For Another Actor Through take
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `pull from caller but execute for another actor` from `take` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `pull from caller but execute for another actor` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-009 - Exact-Target Equality After Skipped Leg Through EcrecoverRatifier
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `exact-target equality after skipped leg` from `EcrecoverRatifier` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `exact-target equality after skipped leg` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-010 - Stale Quote After Fee Change Through MidnightBundles
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `stale quote after fee change` from `MidnightBundles` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `stale quote after fee change` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-011 - Stale Quote After Maturity Change Through pullToken
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `stale quote after maturity change` from `pullToken` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `stale quote after maturity change` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-012 - Non-Escrowed Maker Balance Disappears Through forceApproveMax
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `non-escrowed maker balance disappears` from `forceApproveMax` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `non-escrowed maker balance disappears` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-013 - Bounded Gas Grief After Valid Leg Through buy
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `bounded gas grief after valid leg` from `buy` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `bounded gas grief after valid leg` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-014 - Ratifier Revert Data After Valid Leg Through buyExact
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `ratifier revert data after valid leg` from `buyExact` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `ratifier revert data after valid leg` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-015 - Callback Changes Later Route Observation Through sell
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `callback changes later route observation` from `sell` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `callback changes later route observation` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-016 - Partial-Success Poison Leg Through sellExact
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `partial-success poison leg` from `sellExact` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `partial-success poison leg` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-017 - Final Transfer Balance Versus Delta Through take
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `final transfer balance versus delta` from `take` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `final transfer balance versus delta` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-018 - Approval Residue Across Routes Through EcrecoverRatifier
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `approval residue across routes` from `EcrecoverRatifier` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `approval residue across routes` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-019 - Mixed-Market Consent Ambiguity Through MidnightBundles
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `mixed-market consent ambiguity` from `MidnightBundles` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `mixed-market consent ambiguity` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-020 - Same Maker Group Across Fallback Offers Through pullToken
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `same maker group across fallback offers` from `pullToken` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `same maker group across fallback offers` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-021 - Multiple Roots In One Route Through forceApproveMax
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `multiple roots in one route` from `forceApproveMax` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `multiple roots in one route` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-022 - Permit Owner And Economic Beneficiary Differ Through buy
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `permit owner and economic beneficiary differ` from `buy` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `permit owner and economic beneficiary differ` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-023 - Pull From Caller But Execute For Another Actor Through buyExact
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `pull from caller but execute for another actor` from `buyExact` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `pull from caller but execute for another actor` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-024 - Exact-Target Equality After Skipped Leg Through sell
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `exact-target equality after skipped leg` from `sell` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `exact-target equality after skipped leg` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-025 - Stale Quote After Fee Change Through sellExact
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `stale quote after fee change` from `sellExact` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `stale quote after fee change` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-026 - Stale Quote After Maturity Change Through take
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `stale quote after maturity change` from `take` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `stale quote after maturity change` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-027 - Non-Escrowed Maker Balance Disappears Through EcrecoverRatifier
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `non-escrowed maker balance disappears` from `EcrecoverRatifier` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `non-escrowed maker balance disappears` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-028 - Bounded Gas Grief After Valid Leg Through MidnightBundles
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `bounded gas grief after valid leg` from `MidnightBundles` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `bounded gas grief after valid leg` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-029 - Ratifier Revert Data After Valid Leg Through pullToken
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `ratifier revert data after valid leg` from `pullToken` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `ratifier revert data after valid leg` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### PRA-030 - Callback Changes Later Route Observation Through forceApproveMax
- Status: `hypothesis_only`.
- Direct Midnight equivalent: Map `callback changes later route observation` from `forceApproveMax` to the underlying core call and final token movement.
- Prior tests: Earlier PoCs cover direct residue, exact-fill, helper-revert, Permit2, and temporary-balance classes.
- Untested twist: Require `callback changes later route observation` to add a distinct state transition, consent boundary, or post-leg economic effect.
- PoC plan: Use standard tokens and local mocks, then assert explicit user balance bounds and atomic rollback.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.
