# Periphery + Core + Ratifier Compositions

Date: 2026-05-30

All rows involve `MidnightBundles`, `Midnight`, and either a ratifier or Midnight authorization.

| # | Three-domain composition | Prior AP overlap | What is new | Target invariant | PoC feasibility |
|---|---|---|---|---|---|
| PCR-01 | canceled root A -> same-group fallback B | AP-002/011/015 | stale root plus shared cap in one route | cap bounded | high |
| PCR-02 | canceled A -> exact-assets B -> referral split | AP-011/015/023 | caught ratifier revert before inverse fill | router zero residue | high |
| PCR-03 | setter root A direct fill -> disable -> bundle B | AP-002/011 | direct/routed interleave | shared cap bounded | high |
| PCR-04 | callback ratifies B during bundled take A | AP-001/011 | root mutation inside callback | no transient extraction | medium |
| PCR-05 | callback cancels later route root | AP-011/026 | mid-route cancellation | target/refund atomic | medium |
| PCR-06 | callback `setConsumed(max)` for later legs | AP-002/012/026 | delegated cancellation during route | route bounds | medium |
| PCR-07 | revoked delegated signer A -> maker fallback B | AP-012/013/015 | mixed authority route | revocation and bounds | high |
| PCR-08 | delegated taker + Permit2 caller + referral | AP-017/023 | role-separated payer/taker/receiver | no third-party drain | high |
| PCR-09 | ERC2612 permit consumed -> canceled-root route | AP-011/017 | swallowed permit revert plus stale route | rollback | medium |
| PCR-10 | signed root + fee update + inverse target | AP-013/015/020 | root-valid but economically stale route | max/min slippage | high |
| PCR-11 | signed A expires -> valid signed B fallback | AP-015/020 | expiry route fallback | bounds hold | high |
| PCR-12 | shared group roots at different ticks + referral | AP-002/023 | cap and fee split after fallback | no overfill/residue | high |
| PCR-13 | reduceOnly signed leg after normal route leg | AP-003/015 | maker side crossing within route | reduceOnly holds | high |
| PCR-14 | ratified route callback nested direct fill | AP-001/002/014 | route-local totals vs nested core fill | cap and targets | medium |
| PCR-15 | ratified market A callback route market B | AP-001/014/024 | cross-market shared token | aggregate custody | medium |
| PCR-16 | delegate builds route then self-revokes | AP-012/013 | auth state changes before execution | no stale privilege | high |
| PCR-17 | setter and ecrecover roots share group | AP-002/011 | heterogeneous ratifiers in one route | group cap | high |
| PCR-18 | root failure after collateral supply in sell route | AP-011/015 | supplied collateral then all offers skip | atomic rollback | high |
| PCR-19 | root failure before collateral withdrawals in buy route | AP-011/015 | fallback success controls later withdrawal | health and authorization | high |
| PCR-20 | multi-market alias-shaped signed offers rejected by route | AP-015/022 | production market identity in periphery | market isolation | high |

## Focus

Implement PCR-01, PCR-02, PCR-08, PCR-10, and PCR-13 first. PCR-15 is valuable after the cross-market helper harness exists. Do not promote stale-route reverts or voluntary delegate behavior as findings.
