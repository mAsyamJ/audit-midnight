# Blackbox Logic Hunt PoC Results

Date: 2026-05-31

## Summary

The blackbox logic pass implemented seven focused exploratory contracts and one composite invariant campaign. None
demonstrated a new deduplicated High or Medium issue under Midnight's documented standard-token assumptions.

| ID | Test | Status | Closure evidence |
|---|---|---|---|
| BB-POC-001 | `test/asyam/poc/blackbox/PoC_Blackbox_DeferredPositionUpdate.sol` | **disproven** | A stored lender position can remain stale after a loss, but any value-moving withdrawal first applies the effective loss. Withdrawing stale credit reverts; withdrawing effective credit succeeds. |
| BB-POC-002 | `test/asyam/poc/blackbox/PoC_Blackbox_BadDebtRecoverability.sol` | **disproven** | With a standard nonzero oracle, zero-seize liquidation socializes only formula-bounded unrecoverable debt. Repeating realization while debt is recoverable does not apply another slash. |
| BB-POC-003 | `test/asyam/poc/blackbox/PoC_Blackbox_UserIntentBundle.sol` | **disproven** | An expired preferred sell leg can skip and use a valid fallback, but the executed route remains within the caller's explicit debt and proceeds bounds. |
| BB-POC-004 | `test/asyam/poc/blackbox/PoC_Blackbox_AuthorizationIntentSplit.sol` | **duplicate-risk / accepted signature semantics** | An unused user-signed grant can restore an operator after a direct revocation. The user created that signed capability and can revoke the helper or consume its nonce. This is adjacent to the already-audited broad/transitive authorization revocation-delay family, so it is not promoted as a new finding. |
| BB-POC-005 | `test/asyam/poc/blackbox/PoC_Blackbox_QuoteSettlementMismatch.sol` | **disproven** | Raising settlement fees can skip a stale preferred leg, but a valid fallback settles within the current call bounds. The skipped leg does not leave partial economic state. |
| BB-POC-006 | `test/asyam/poc/blackbox/PoC_Blackbox_CrossMarketAggregateAccounting.sol` | **disproven** | A token-global settlement fee and market-local lender withdrawal remain jointly backed across two markets in either claim/withdraw order. |
| BB-POC-019 | `test/asyam/poc/blackbox/PoC_Blackbox_TokenAsCollateralAggregate.sol` | **disproven** | When a token is simultaneously a loan token, collateral token, and fee token across markets, fee claim, lender withdrawal, and collateral exit remain backed in both tested exit orders. |
| INV-BB-001 | `test/asyam/invariant/composite/Invariant_CrossMarketAggregateAccounting.t.sol` | **disproven by invariant campaign** | Across 256 fuzz runs, every permutation of market-A lender withdrawal, market-B lender withdrawal, same-token collateral exit, and token-global fee claim preserved aggregate custody backing after every action. |

## Commands

```bash
forge test --match-path 'test/asyam/poc/blackbox/*.sol' -vvv
forge test --match-path 'test/asyam/invariant/composite/*.sol' -vvv
```

Logs:

```text
audits/asyam/workflow/blackboxLogicHunt/blackbox_poc_tests.log
audits/asyam/workflow/blackboxLogicHunt/composite_invariant_tests.log
```

## Promotion Gate

No new regression was added under `test/asyamFindings/`. The explored paths either preserved the target invariant or
remained inside already-audited authorization semantics.

## Residual Source Review

`updatePositionView(market, id, user)` and `isHealthy(market, id, borrower)` accept a market and ID separately. A caller
can produce misleading view results by supplying a mismatched pair, but this is not an exploitable core path:

- their NatSpec explicitly requires the ID to correspond to the market;
- all state-changing core call sites derive the ID from `touchMarket(market)` before using either helper;
- no periphery state transition relies on an externally supplied ID/market pair.

Keep this as an integration caution, not a Cantina finding.

## Final Verification

| Command | Result | Log |
|---|---|---|
| `forge fmt --check test/asyam/poc/blackbox test/asyam/invariant/composite` | pass | terminal check |
| `jq empty audits/asyam/workflow/blackboxLogicHunt/blackbox_logic_hunt_graph.json` | pass | terminal check |
| `forge build` | pass | `final_build.log` |
| `forge test --match-path 'test/asyam/**/*.sol' -vvv` | **87/87 passed** | `final_exploratory_tests.log` |
| `forge test --match-path 'test/asyamFindings/*.sol' -vvv` | **14/14 passed** | `final_validation_tests.log` |
| `forge test -vvv` | **474/474 passed** | `final_full_tests.log` |
