# Formal Spec Blindspot Compositions

Date: 2026-05-30

These are assurance boundaries. They are not runtime findings without executable Foundry impact.

| # | CVL/spec file | Rule / invariant | Assumption or model limitation | Real-code path | Possible exploit composition | Executable test? | Severity gate |
|---|---|---|---|---|---|---|---|
| F-01 | `Solvency.spec` | `CVL_toId` | hashes loan token, maturity, chain ID, Midnight only | full `IdLib.toId` market hash | aliased model misses shared-token A/B ordering | P3-02 exists; runtime probe COMP-009 | formal Low unless runtime impact |
| F-02 | `NoDivisionByZero.spec` | `equalsGlobalMarket` | compares collateral indexes `0..2` only | markets support up to 128 | index-3 difference prunes valid paths | P3-02 exists | formal Low |
| F-03 | `Healthiness.spec` | `stayHealthy` | filters out `take` | `take` mutates seller then calls callbacks | nested collateral mutation before final health | COMP-027 planned | High only if persistent unhealthy success |
| F-04 | `Healthiness.spec` | `genericCallback` | requires health after havoc | arbitrary callback may reenter | callback root/take/repay composition | COMP-008/015 planned | runtime PoC required |
| F-05 | `Solvency.spec` | `onBuy` / `onSell` | summarized `NONDET`, no reentry | take callbacks are untrusted | route callback consumes shared group | COMP-022 planned | runtime PoC required |
| F-06 | `Solvency.spec` | callbacks dispatcher | known helper dispatch for repay/liquidate/flash | unknown callbacks possible | flash-liquidate-withdraw unwind | COMP-004/014 planned | High if extraction |
| F-07 | `Solvency.spec` | token summaries | exact non-reentrant ERC20 | standard token only in scope | same token used across market roles | COMP-007/018 planned | runtime standard-token PoC |
| F-08 | all core specs | scene scope | periphery not modeled | `MidnightBundles` loops, permits, refunds | canceled-root fallback referral residue | COMP-001/002 planned | Medium if caller/protocol loss |
| F-09 | `Solvency.conf` | loop model | optimistic loop, `loop_iter: 2` | liquidation bitmap up to borrower cap | 3+ collateral oracle/gate path | COMP-006 planned | classify liveness vs loss |
| F-10 | `Healthiness.spec` | collateral length bounds | selected rules require <=2 or <=3 | production supports more | callback or liquidation on later index | COMP-006/027 planned | runtime PoC required |
| F-11 | `Reverts.spec` | oracle rules | controlled zero/revert summaries | multiple active oracles with mixed liveness | cleanup deadlock after borrow | COMP-020 planned | usually market-risk Low |
| F-12 | `LossFactor.spec` | isolated arithmetic | no periphery and simplified callback data | fee claim/repay/withdraw permutations | social-loss first-claimer path | COMP-003/011 planned | High if custody deficit |
| F-13 | `BalanceEffects.spec` | per-call deltas | single-call assertions | nested callback interleavings | liquidation precredit then withdraw | COMP-014 planned | High if unpaid extraction |
| F-14 | math specs | mulDiv local properties | local precision bounds | repeated route fills and fee accrual | dust-to-material amplifier | COMP-013/030 planned | Medium only with realistic materiality |
| F-15 | core CVL suite | maturity reasoning | method-local timestamp branch | off-chain route quoted before boundary | fee/root fallback after maturity transition | COMP-010/021 planned | Medium only if bounds bypassed |

## Formal Review Rule

For every CVL closure used later, inspect summaries, `preserved` assumptions, method filters, collateral bounds, external-call resolution, and identity summaries. Keep formal-only gaps separate from production exploit claims.
