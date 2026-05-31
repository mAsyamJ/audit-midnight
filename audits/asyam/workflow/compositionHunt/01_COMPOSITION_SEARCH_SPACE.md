# Composition Search Space

Date: 2026-05-30

## Contract Axes

| Axis | Covered | Underexplored composition edge |
|---|---|---|
| `Midnight.sol` | direct lifecycle and callbacks | cross-function nesting around state-before-transfer windows |
| Ratifiers | cancel/root happy and revert paths | route skip/fallback while roots or delegates differ across offers |
| `HashLib` | hash correctness and Merkle leaf tests | signed-route timing with delegated signer revocation |
| `EcrecoverAuthorizer` | nonce, deadline, malleability | relayer + Permit2 payer + delegated Midnight actor mismatch |
| `MidnightBundles` | ordinary targets and simple balance leak | root skip, fee/referral split, nested route, shared-token markets |
| `TakeAmountsLib` | direct alignment | inverse target after earlier route leg changes state |
| `ConsumableUnitsLib` | direct cap behavior | shared group across mixed root lifecycle |
| Gate | direct enter/liquidator checks | liveness interaction with active oracle set and maturity |
| Oracle | zero/revert semantics known | multi-collateral selective liveness during unwind |
| Callback | take/repay/liquidate/flash slices | cross-function composition with maturity and root state |
| ERC20 | exact non-reentrant model | same standard token reused across market custody buckets |
| Permit2/ERC2612 | native route success | caller, delegated taker, receiver, referral multi-role intent |
| Certora specs | core invariants | periphery exclusion, callback summaries, bounded collateral loops |
| Tests/helpers | broad native coverage | helper assumptions that hide multi-market or nested routes |

## State Axes

| State | Covered | Underexplored composition edge |
|---|---|---|
| `marketState.totalUnits` | direct take/repay/liquidate | nested sequence across slash and partial repay |
| `position.credit/debt/pendingFee` | ordinary update flow | stale lender touch after slash and claim ordering |
| `consumed[maker][group]` | direct grouped cap | same group across roots and bundle fallback |
| `isAuthorized` | direct delegation | delegate, relayer, ratifier signer, bundle caller composition |
| root canceled/ratified state | direct replay rejection | skipped canceled leg followed by valid root in exact route |
| collateral bitmap/balances | lifecycle coverage | active reverting oracle index plus post-maturity liquidation |
| `withdrawable` | direct backing | same loan token across markets plus repayment and slash order |
| `lossFactor` | direct slash bound | stale position, partial repay, continuous fee, withdrawal |
| `continuousFeeCredit` / claimable fees | direct claim tests | fee claim around socialized loss and route execution |
| maturity / fee schedule / tick spacing | boundary tests | quote-before-update and execute-after-update routes |

## Actor Axes

| Actors | Covered | Underexplored composition edge |
|---|---|---|
| maker / taker / lender / borrower | ordinary separation | one actor holding multiple roles across nested routes |
| liquidator / callback | direct nested liquidate | flash-funded repay-withdraw after socialization |
| authorized delegate / relayer | direct authorization | delegated taker with independent payer and referral recipient |
| ratifier / route builder | direct root control | root lifecycle divergence between route legs |
| market creator / oracle or gate deployer | consenting market risk | cross-market shared-token liveness spillover |
| fee setter / fee claimer | role-gated behavior | quote staleness and loss-factor fee-order probes |

## Time Axes

| Time edge | Covered | Underexplored composition edge |
|---|---|---|
| before, at, after maturity | direct functions | route built before boundary and filled after; callback nesting at boundary |
| fee update before execution | known staleness | route leg skip plus fallback and referral exactness |
| root cancel / delegate revoke | direct invalidation | stale route mixes invalid and valid legs |
| oracle/gate liveness change | direct reverts | multi-collateral unwind and post-maturity branch |
| same transaction nesting | callback slices | four-step flash/liquidate/repay/withdraw composition |
| multi-transaction ordering | native fuzz | slash then stale touch then claim then withdrawal |

## Value Axes

| Value | Covered | Underexplored composition edge |
|---|---|---|
| loan and collateral custody | direct accounting | shared standard token across isolated markets |
| credit/debt units | direct deltas | nested update and maturity edge |
| bad debt / `lossFactor` | direct socialization | claimable fee and withdrawable ordering |
| pending and claimable fees | direct claims | stale quote, referral route, and slash composition |
| referral fee | exact boundary | skipped leg plus fallback root |
| flash-loan float | reimbursement | use as temporary funding inside liquidation callback |

## Admission Rule

A composition enters the backlog only if it crosses at least two covered domains, specifies a new transition or invariant, and can be implemented under standard-token assumptions. User-error, admin-only, weird-token-only, dust-only, accepted-risk, and dedup paths remain low-value unless the composition adds a protocol-level impact.
