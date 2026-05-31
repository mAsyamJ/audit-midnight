# Different-Angle Threat Model

Date: 2026-05-31

| Category | Midnight surface | Why prior tests may miss it | Required proof |
|---|---|---|---|
| User-intent mismatch | `MidnightBundles` route bounds, receiver, referral | Existing tests assert arithmetic, not all economic side effects | Bound-compliant transaction causes non-consenting loss |
| Economic-model mismatch | `liquidate`, `lossFactor`, `withdrawable` | Formula tests isolate calls | Multi-tx sequence socializes recoverable value |
| Quote vs settlement | `settlementFee`, maturity, route loops | Stale fee fallback was narrow | Explicit route guarantee violated after state transition |
| Local vs global invariant | Per-market accounting and token custody | Most harnesses assert one market | Aggregate token liability exceeds custody |
| Per-market vs cross-market | Shared loan token, global settlement fees | Market IDs isolate storage but not ERC20 balance | Valid claim in A starves valid claim in B |
| Position vs aggregate market | Lazy `updatePosition` and `totalUnits` | Touch tests compare view and storage only | Delayed touch changes a material branch or payout |
| Authorization intent vs effect | Core authorization reused by periphery and ratifiers | Broad delegation is documented | Authority obtained or expanded without matching user action |
| Permissionless-market assumption | `touchMarket`, route-selected market | Bad market is usually consented | Victim interacts without selecting the bad market |
| Off-chain route assumptions | `takes[]`, skip semantics, target checks | Existing tests use honest route construction | Valid route args permit economically different settlement |
| Formal abstraction mismatch | CVL summaries and preserved blocks | Specs isolate bodies and abstract callbacks | Executable path omitted by model violates runtime invariant |
| Event/indexer mismatch | `EventsLib`, lazy accrual, social loss | Source review is not replay validation | Event replay misses state needed for loss-avoiding action |
| Incentive-compatible grief to loss | Cancellation, routing, liquidation races | Simple grief is Low | Rational attacker reliably converts grief into victim loss |
| Liveness to solvency | oracle/gate failures and maturity | Chosen-market liveness is intended | Failure propagates across a missing consent boundary |
| Dust drift to material branch | rounding, thresholds, RCF | Prior dust tests measure residue only | Dust flips health, liquidation, cap, or claim branch |
| Partial update across sequence | `repay`, `liquidate`, `take`, `updatePosition` | Unit tests isolate endpoints | Safe individual transitions compose into deficit or freeze |

## Actor Model

The attacker may be a maker, taker, borrower, lender, liquidator, relayer, route builder, market creator, referral
recipient, or a multi-role account. Admin-role-only behavior stays Low or invalid unless an external actor can trigger it.

## Value Model

Track loan-token custody, collateral custody, credit, debt, total units, withdrawable, settlement fees, continuous fees,
loss factor, consumed caps, bitmap state, route refunds, and liquidation proceeds. A hypothesis escalates only if the
final state demonstrates a material non-consenting-user impact.
