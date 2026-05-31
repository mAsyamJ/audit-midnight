# Edge Case Matrix

Date: 2026-05-30

| # | Dimension | Edge value | Functions | Test exists? | PoC priority | AP link |
|---|---|---|---|---|---|---|
| 1 | units | 0 | take, liquidate | partial | Low | — |
| 2 | units | 1 wei | take | yes fuzz | Med | AP-003 closed |
| 3 | units | max uint128 | take | partial | Low | — |
| 4 | maturity | `now == maturity` | take, settlementFee | partial | **High** | AP-020 |
| 5 | maturity | `now = maturity + 1` | take debt rule | yes | Med | AP-020 |
| 6 | maturity | `now = maturity - 1` | take | yes | Low | — |
| 7 | maxAssets | >0, maxUnits=0 | take | yes | — | AP-002 closed |
| 8 | maxUnits | >0, maxAssets=0 | take | yes | — | AP-002 closed |
| 9 | lossFactor | `type(uint128).max` | take | yes | — | reverts |
| 10 | lossFactor | just increased | updatePosition | partial | Med | AP-010 |
| 11 | postMaturityMode | true | liquidate | yes | Med | AP-006 |
| 12 | postMaturityMode | false | liquidate | yes | — | — |
| 13 | liquidate | seized=0, repaid=0 | liquidate | yes | dup-risk | Spearbit |
| 14 | liquidate | seized>0, repaid=0 | liquidate | yes | Med | AP-005 |
| 15 | liquidate | seized=0, repaid>0 | liquidate | yes | — | — |
| 16 | collateralIndex | inactive slot | liquidate | partial | Med | — |
| 17 | collateralIndex | wrong index in loop | liquidate | partial | Low | — |
| 18 | bitmap | max 128 collaterals | supplyCollateral | yes | — | AP-007 |
| 19 | bitmap | clear bit on zero withdraw | withdrawCollateral | yes | — | C-033 covered |
| 20 | tick | 0 | take | yes | dup L-24 | — |
| 21 | tick | not multiple of tickSpacing | take | yes | — | reverts |
| 22 | tick | max tick | take | partial | Low | — |
| 23 | buyerPrice | > WAD | bundles | yes revert | — | intended |
| 24 | loanToken == collateral | same address | take, repay, liq | yes promoted | closed | C-31 |
| 25 | oracle price | 0 | liquidate, health | yes | dup | Spearbit |
| 26 | oracle price | revert | withdrawCollateral | yes | accepted | — |
| 27 | gate | enter blocks credit | take | yes | accepted | — |
| 28 | gate | liquidator blocks | liquidate | yes | accepted | — |
| 29 | reduceOnly | buy, debt to zero | take | yes | closed | C-12 |
| 30 | reduceOnly | buy, +1 wei over | take | yes | closed | Validation_LiveQueues |
| 31 | referral | 100% fee WAD-1 | bundle buy | yes | closed | C-29 |
| 32 | referral | budget - 1 wei | bundle buy units | yes | invalid | C-29 |
| 33 | selfTake | maker == taker | take | yes | — | reverts |
| 34 | offer | expired / not started | take | yes | — | reverts |
| 35 | flashLoan | 0 amount | flashLoan | partial | Low | AP-019 |
| 36 | setConsumed | type(uint256).max | setConsumed | yes | — | intended cancel |

**30+ cells** — prioritize rows 4–5, 10–11, 14, 18 for open PoC work.
