# State Machine Desync Attacks

Date: 2026-05-31

| ID | State A | State B | Expected coupling | Possible desync sequence | Coverage gap | Required assertion / suggested PoC |
|---|---|---|---|---|---|---|
| SD-001 | stored lender `credit` | `updatePositionView.credit` | Mutating actions use effective credit | slash -> no touch -> withdraw/take | Direct sync tested, cross-action not | Stored/effective/action deltas agree; deferred PoC |
| SD-002 | stored `pendingFee` | effective pending fee | Accrual cannot be skipped by ordering | accrue -> slash -> alternate touch | Dust duplicate risk | Material payout invariant |
| SD-003 | `lastLossFactor` | market `lossFactor` | First touch applies exactly one slash | repeated public touch around claim | Existing one-market tests | Idempotent second touch |
| SD-004 | `lastAccrual` | maturity-capped accrual | Fee accrues once through maturity | warp before/exact/after maturity -> touch | Native tests broad but isolated | Same effective fee after equivalent elapsed time |
| SD-005 | market `withdrawable` | core ERC20 custody | Market claim stays backed | repay A -> fee claim B -> withdraw A | Cross-market aggregate gap | `balance >= aggregate liabilities`; aggregate PoC |
| SD-006 | token-global settlement fee | per-market withdrawable | Global fee cash is reserved | accrue fees A/B -> repay C -> claim -> withdraw | Formal spec exists, runtime path useful | Aggregate backing |
| SD-007 | `continuousFeeCredit` | withdrawable | Fee claims only paid from realized cash | accrue -> partial repay -> claim order | One-market composition closed | Multi-market claim ordering |
| SD-008 | `totalUnits` | sum effective lender credit + fee | Units mirror claims modulo rounding | slash fragmented lenders -> touch subset | Dust probe closed narrowly | Non-dust deficit threshold |
| SD-009 | borrower debt | collateral bitmap | Debt health sees all active collateral | add zero/nonzero collateral -> route debt | Bitmap lifecycle tested alone | Active-risk consent invariant |
| SD-010 | collateral balance | bitmap bit | Zero balance clears active bit | withdraw all -> supply zero -> liquidate | Native direct tests | Bit iff nonzero after sequences |
| SD-011 | consumed group amount | signed offer family | Shared cap has stable economic meaning | opposite-side or cross-token same group | Docs warn configuration | User-error filter PoC |
| SD-012 | root canceled state | route leg availability | Invalid root never fills | build route -> cancel -> independent authorization | Direct canceled fallback closed | No hidden partial side effect |
| SD-013 | setter ratifier root | delegate authorization | Effective root authority matches current actor power | ratify -> revoke -> route | Direct delegate grief closed | Unauthorized root cannot persist if semantics require revocation |
| SD-014 | core authorization | bundler payer | Position authority does not imply token payer authority | authorize delegate -> relayer route | Permit2 caller context closed | No unrelated token loss |
| SD-015 | core authorization | EcrecoverAuthorizer nonce | Signed state change executes once | sign revoke/grant -> interleave calls | Malleability known | One semantic transition per nonce |
| SD-016 | maturity timestamp | settlement fee bucket | Quote and settlement use same current TTM | quote -> warp breakpoint -> route | Stale fee variant narrow | Route bounds survive current fee |
| SD-017 | maturity timestamp | liquidation mode | Post-maturity mode only after boundary | prepare -> exact boundary -> liquidate | Direct maturity covered | No branch mismatch |
| SD-018 | `maxDebt` health | `badDebt` recoverability | Both use same activated collateral set | partial seize -> zero-realize | Optimistic bad debt duplicate risk | Socialized amount bounded by unrecoverable debt |
| SD-019 | RCF `maxRepaid` | residual collateral recoverability | Threshold policy cannot cause hidden discontinuity | just-below threshold -> full liquidate | Native fuzz covers direct | Compare neighboring threshold states |
| SD-020 | market config encoded ID | `toMarket` code storage | Round trip preserves full consent tuple | create similar markets -> event replay | Runtime round-trip tested | Hash of decoded market equals original |
| SD-021 | event `UpdatePosition` delta | stored lazy state | Replay reaches storage state | slash -> touch subset -> claim | Source review only | Event mirror equals storage |
| SD-022 | event `Liquidate.badDebt` | lossFactor delta | Replay can reconstruct social loss | multi-liquidation sequence | Events include latest factor | Replay assertion |
| SD-023 | periphery precomputed units | core current fee and consumed | Helper quote matches core at call time | route leg callback/state transition -> next leg | Direct helper alignment closed | Accepted legs remain bounded |
| SD-024 | bundler pulled balance | final refund/receiver transfers | Route cannot retain or redirect value | mixed successful/skipped legs | Temp balance closed | Router residual zero, recipients exact |
| SD-025 | CVL market summary | production market ID | Formal claims map to runtime identities | reduced tuple alias -> aggregate runtime path | P3-02 formal-only | Runtime IDs isolated; formal blindspot classification |
