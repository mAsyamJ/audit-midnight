# Execution Plan

Date: 2026-05-31

## Baseline

Fresh logs are saved in this workspace for build, full tests, prior composition probes, and prior exploratory probes.

## First Five

1. `PoC_Blackbox_DeferredPositionUpdate.sol`
   - Reuse `Config.t.sol` and standard oracle.
   - Open two borrower positions, realize bounded bad debt, compare stored/effective lender state, exercise withdrawal.
   - Run: `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_DeferredPositionUpdate.sol' -vvvv`

2. `PoC_Blackbox_BadDebtRecoverability.sol`
   - Reuse `Config.t.sol`; no malicious oracle mock.
   - Compute recoverability before and after partial liquidation, then try zero-realization.
   - Run: `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_BadDebtRecoverability.sol' -vvvv`

3. `PoC_Blackbox_UserIntentBundle.sol`
   - Reuse `Config.t.sol`, `MidnightBundles`, and `Take` structs.
   - Invalidate a preferred leg, execute valid fallback, assert spend/proceeds/units/debt/collateral/residual bounds.
   - Run: `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_UserIntentBundle.sol' -vvvv`

4. `PoC_Blackbox_AuthorizationIntentSplit.sol`
   - Reuse `EcrecoverAuthorizer`, ratifiers, and signature helpers from native tests.
   - Interleave signed grant/revoke and route execution; assert no stale unrelated capability moves assets.
   - Run: `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_AuthorizationIntentSplit.sol' -vvvv`

5. `PoC_Blackbox_QuoteSettlementMismatch.sol`
   - Reuse fee setters and bundle helpers.
   - Quote, change current fee or warp fee breakpoint, execute fallback, assert call bounds or atomic rollback.
   - Run: `forge test --match-path 'test/asyam/poc/blackbox/PoC_Blackbox_QuoteSettlementMismatch.sol' -vvvv`

## Immediate Sixth Probe

Implement `PoC_Blackbox_CrossMarketAggregateAccounting.sol` immediately after the first five because the source stores
settlement fees globally by token while withdrawable remains market-local. Exercise fee claim and lender withdrawal in
both orders and assert aggregate backing.

## Promotion

- Record every result in `POC_RESULTS.md` in this workspace and append a summary to `../POC_RESULTS.md`.
- Create files under `test/asyamFindings/` only for compiling, deduplicated, concrete vulnerabilities.
- Do not edit `src/*` or protocol-authored tests.

## Verification

```bash
forge test --match-path 'test/asyam/poc/blackbox/*.sol' -vvvv
forge test --match-path 'test/asyam/**/*.sol' -vvv
forge test --match-path 'test/asyamFindings/*.sol' -vvv
forge test -vvv
jq empty audits/asyam/workflow/blackboxLogicHunt/blackbox_logic_hunt_graph.json
```
