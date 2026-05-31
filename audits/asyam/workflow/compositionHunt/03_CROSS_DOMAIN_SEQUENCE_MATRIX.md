# Cross-Domain Sequence Matrix

Date: 2026-05-30

Each row is one concrete later-test sequence. “Failure” is the hypothesized break to assert against, not an established bug.

| # | Flow | Initial state | Action 1 | Action 2 | Action 3 | Action 4 | Final invariant check | Expected failure | Priority |
|---|---|---|---|---|---|---|---|---|---|
| S-001 | ratified | roots A/B share group | cancel A | bundle takes A | fallback takes B | withdraw collateral | consumed <= cap | cap bypass | P0 |
| S-002 | periphery | A canceled, B valid | exact-assets route A/B | skip A | fill B | pay referral | router balance zero | residue/refund mismatch | P0 |
| S-003 | liquidated | stale lender credit | liquidate bad debt | repay other debt | claim fee | lender withdraw | custody >= claims | deficit | P0 |
| S-004 | flash | matured borrower | flash loan | post-maturity liquidate | callback withdraw | repay flash | no excess attacker gain | temporary-balance drain | P0 |
| S-005 | delegated | taker delegates caller | Permit2 pull | buy route | withdraw taker collateral | split referral/refund | payer and receiver intent | unauthorized movement | P0 |
| S-006 | maturity | seller near maturity | warp `maturity` | take | callback repay | final health check | no new matured debt | lock bypass | P1 |
| S-007 | multi-market | A/B share loan token | route sell A | callback route B | withdraw B | settle A | aggregate custody cover | cross-market drain | P1 |
| S-008 | callback | root B disabled | take A | callback ratify B | nested take B | finish A | caps and custody | transient extraction | P1 |
| S-009 | formal | prod-distinct alias markets | repay A | withdraw B | repay B | withdraw A | market isolation | runtime identity leak | P1 |
| S-010 | periphery | quote under fee F | increase fee | exact route A/B | skip A | fallback B | caller bounds hold | adverse fill | P1 |
| S-011 | liquidated | A repay-backed, B bad debt | repay A | liquidate B | update lender | withdraw | credit <= backing | first withdrawer edge | P0 |
| S-012 | periphery | maker near exposure crossing | fill normal leg | size reduceOnly leg | take reduceOnly | finalize route | no exposure increase | reduceOnly route bypass | P1 |
| S-013 | multi-market | repeated small positions | loop small takes | update positions | liquidate | claim/withdraw | material drift absent | amplified dust | P2 |
| S-014 | liquidated | lender and liquidator callback | liquidate repay-input | callback withdraw | source repayment | outer pull | custody restored | unpaid withdrawal | P0 |
| S-015 | ratified | setter roots A/B enabled | direct take A | disable A | bundle A/B | fallback B | shared cap holds | direct/routed cap gap | P1 |
| S-016 | delegated | signed permit and stale route | consume ERC2612 permit | cancel root A | route A/B | inspect balances | atomic rollback | caller loss | P2 |
| S-017 | multi-market | token is collateral A and loan A/B | repay-and-withdraw A | lender withdraw B | reverse order | compare claims | aggregate coverage | token-role double use | P1 |
| S-018 | liquidated | gated underwater debt | deny liquidator | warp maturity | allow liquidator | slash/withdraw | intended loss only | timing unfairness | P2 |
| S-019 | maturity | active dust collateral oracle | oracle reverts | try clear dust | warp mature | liquidate other collateral | classify liveness | unwind deadlock | P2 |
| S-020 | periphery | offer A near expiry | warp expiry+1 | exact route A/B | fallback B | pay referral | explicit min/max holds | worse silent fill | P2 |
| S-021 | callback | route legs share group | route takes A | A callback direct takes C | route sizes B | finish/refund | cap and target atomic | nested consumption drift | P0 |
| S-022 | callback | callback is maker delegate | route takes A | callback `setConsumed(max)` | route skips B | fallback C | route guarantees hold | in-route cancellation loss | P1 |
| S-023 | flash | shared token and router float | flash | bundle sell | liquidate | withdraw/repay flash | one obligation per token | double-use float | P0 |
| S-024 | ratified | signed boundary offers | quote | fee setter updates | execute signed route | inspect fills | user bounds hold | signed quote asymmetry | P2 |
| S-025 | callback | A pre-, B post-maturity | take A | callback take/repay B | withdraw B | complete A | per-market isolation | maturity cross-market drain | P1 |
| S-026 | formal | seller has 2 collaterals | take | callback withdraw collateral | callback repay | finish | seller healthy and bitmap valid | `take` proof-gap exploit | P1 |
| S-027 | multi-market | bad debt A, cash B | liquidate A | claim fee A | withdraw B | reverse order | aggregate custody | first-claimer insolvency | P1 |
| S-028 | ratified | signer A revoked, maker B valid | build route | revoke signer A | route A/B | fallback B | no A execution, bounds hold | revocation route asymmetry | P2 |
| S-029 | multi-market | A drift, B large claims | routed microfills A | update | liquidate A | withdraw A/B | no material deficit | dust-to-loss amplifier | P2 |
| S-030 | normal direct | maker roots share group | direct take A | direct take B | set consumed max | take C | monotonic consumed | cap regression | P2 |
| S-031 | periphery | empty/invalid first leg | route helper sizes A | core A reverts | helper sizes B | exact finalize | strict equality | unexpected partial success | P2 |
| S-032 | delegated | delegate controls taker only | delegate route sell | supply collateral | receive loan token elsewhere | revoke delegate | explicit authority scope | receiver confusion | P2 |
| S-033 | callback | sell offer has maker callback | take sell | callback flash loan | nested repay | complete transfers | balance delta exact | callback funding reuse | P1 |
| S-034 | liquidated | two active collaterals | liquidate index 0 | callback supplies index 1 | outer pulls repayment | second liquidation | bitmap/health consistent | loop snapshot inconsistency | P1 |
| S-035 | maturity | quote at `maturity-1` | warp `maturity` | bundle exact route | callback nested take | settle | fee and debt rules current | boundary route drift | P1 |
| S-036 | maturity | debt at maturity | warp `maturity+1` | post-maturity liquidate | repay remainder | withdraw collateral | LIF and custody bounded | unwind over-credit | P1 |
| S-037 | flash | lender claim available | flash shared token | withdraw lender claim | route repayment | repay flash | no deficit | flash backs own repayment | P1 |
| S-038 | ratified | canceled A, direct B consumed | cancel A | direct take B | bundle A/B | route fallback | cap across calls | stale helper cap | P1 |
| S-039 | periphery | referral recipient = caller | exact sell route | callback nested buy route | transfer referral | transfer receiver | no router residual | split accounting overlap | P2 |
| S-040 | normal direct | stale fee credit after slash | liquidate | claim continuous fee | update lender | claim again | no overclaim | double claim | P1 |
| S-041 | multi-market | A/B shared token and fee claimer | repay A | claim fee B | withdraw A | liquidate B | aggregate coverage | fee source confusion | P1 |
| S-042 | delegated | maker delegates signer then revokes | sign root | revoke | callback nested route | direct take | revoked root unusable | authority resurrection | P1 |
| S-043 | callback | seller locked by outer take | nested withdraw collateral | nested liquidate same seller | nested repay | return callback | lock clears and health holds | persistent lock/health bypass | P1 |
| S-044 | liquidated | bad debt plus repayment input | liquidate zero repay first | slash | liquidate repay input | withdraw lender | no over-socialization | duplicated recovery | P1 |
| S-045 | maturity | root valid until expiry | warp maturity+1 before expiry | bundle buy reduce debt | withdraw collateral | claim fees | post-maturity only debt reduction | matured exposure increase | P1 |
| S-046 | periphery | same group offers different roots | route units target | callback cancel later root | fallback third root | refund | final units exact | skipped-leg residue | P1 |
| S-047 | flash | liquidator gate allows callback | flash | callback liquidate | nested route sell collateral proceeds | repay | only incentive profit | gated float extraction | P1 |
| S-048 | formal | 4-collateral market index 3 differs | touch A/B | supply index 3 A | borrow A | withdraw B | production IDs isolate | alias-assisted runtime path | P2 |
| S-049 | delegated | caller authorized for borrower | repay-and-withdraw route | referral to caller | collateral to third receiver | revoke | token and collateral deltas authorized | broad delegate drain classification | P2 |
| S-050 | multi-market | same token collateral and fees | repay/withdraw A | claim settlement fee B | lender withdraw B | inspect A collateral | aggregate custody includes roles | token-role liability overlap | P1 |

## Flow Coverage

The rows cover normal direct, periphery, ratified, delegated, callback, liquidated, maturity-boundary, flash-loan, and multi-market flows. The P0 rows are the first implementation candidates; P2 rows are classification or false-positive filters unless a stronger impact appears.
