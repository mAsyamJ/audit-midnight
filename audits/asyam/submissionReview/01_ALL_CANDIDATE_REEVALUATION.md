# All Candidate Reevaluation

Date: 2026-05-31

## Method

Each evidence-backed candidate receives a detailed canonical entry. Repeated
research queues are registered by source ID and mapped to a final disposition.
This prevents duplicate hypotheses from inflating the finding count while
preserving traceability.

Default rules for queue registers:

- A tested candidate inherits the recorded local PoC result.
- An unimplemented planning entry is `DO_NOT_SUBMIT_INVALID_UNVALIDATED`.
- A Spearbit or Blackthorn item is `DO_NOT_SUBMIT_DUPLICATE`.
- A Hashlock-only item is hypothesis input, not a finding.
- A dust-only, intended, consenting-market-only, admin-only, or revert-only path
  cannot become a High or Medium claim.

## Detailed Canonical Entries

### CAND-001 - L-01 ECDSA high-s signature malleability

- Source: Local audit PoC; Hashlock L-01 hypothesis.
- Current status: Proven.
- Existing file: `audits/asyam/findings/cantina-L01-signature-malleability.md`.
- Existing PoC: `test/asyamFindings/PoC_SignatureMalleability.t.sol`.
- Command: `forge test --match-path test/asyamFindings/PoC_SignatureMalleability.t.sol -vvv`.
- Result: `2 passed, 0 failed`.
- Previous severity guess: Low.
- Re-evaluated severity ceiling: Low.
- Impact: Raw-signature canonicality and integration inconsistency.
- Likelihood: Medium; malleation is public arithmetic.
- Is impact non-dust?: Yes, but operational rather than fund loss.
- Is it duplicate?: No accepted Spearbit / Blackthorn duplicate found locally.
- Is it in scope?: Yes.
- Is it intended behavior?: No.
- Is it user-error/front-end manageable?: No.
- Is it admin-only?: No.
- Does it rely on weird ERC20 behavior?: No.
- Does it rely on consenting malicious market?: No.
- Does it require unvalidated AI claim?: No; local PoC proves it.
- Submit decision: Submit.
- Reason: Defensible Low with a concrete fix and no H/M overclaim.

### CAND-002 - P3-01 `roleSetter` zero-address bricking

- Source: Local audit PoC; AP-025.
- Current status: Proven administrative footgun.
- Existing file: `audits/asyam/findings/cantina-P3-01-role-setter-bricking.md`.
- Existing PoC: `test/asyamFindings/PoC_RoleSetterBricking.t.sol`.
- Command: `forge test --match-path test/asyamFindings/PoC_RoleSetterBricking.t.sol -vvv`.
- Result: `1 passed, 0 failed`.
- Previous severity guess: Low.
- Re-evaluated severity ceiling: Low at most.
- Impact: Permanent role-administration freeze.
- Likelihood: Low.
- Is impact non-dust?: Operationally yes.
- Is it duplicate?: No local accepted duplicate found.
- Is it in scope?: Scope judgment required.
- Is it intended behavior?: No, but only admin can trigger it.
- Is it user-error/front-end manageable?: Primarily operational.
- Is it admin-only?: Yes.
- Does it rely on weird ERC20 behavior?: No.
- Does it rely on consenting malicious market?: No.
- Does it require unvalidated AI claim?: No.
- Submit decision: Maybe.
- Reason: Hold unless Cantina accepts admin-only operational footguns.

### CAND-003 - P3-02 CVL market-ID summary aliasing

- Source: AP-022; formal-gap review.
- Current status: Proven formal model mismatch.
- Existing file: `audits/asyam/findings/cantina-P3-02-solvency-spec-market-id-aliasing.md`.
- Existing PoC: `test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol`.
- Command: `forge test --match-path test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol -vvvv`.
- Result: `2 passed, 0 failed`.
- Previous severity guess: Informational / P3.
- Re-evaluated severity ceiling: Informational.
- Impact: Valid production states may be collapsed or pruned by CVL summaries.
- Likelihood: Medium for multi-market configurations.
- Is impact non-dust?: Formal assurance impact only.
- Is it duplicate?: No local accepted duplicate found.
- Is it in scope?: Yes as Informational formal review.
- Is it intended behavior?: No.
- Is it user-error/front-end manageable?: No.
- Is it admin-only?: No.
- Does it rely on weird ERC20 behavior?: No.
- Does it rely on consenting malicious market?: No.
- Does it require unvalidated AI claim?: No.
- Submit decision: Submit.
- Reason: Precise Informational model-assurance gap with no runtime overclaim.

### CAND-004 - L-02 tiny repayment liquidation gas grief

- Source: HPH-POC-001.
- Current status: Proven repairable stale-transaction gas grief.
- Existing file: `audits/asyam/findings/cantina-L02-tiny-repay-liquidation-gas-grief.md`.
- Existing PoC: `test/asyam/poc/historical/PoC_Hist_TinyRepayLiquidationGrief.t.sol`.
- Command: `forge test --match-path test/asyam/poc/historical/PoC_Hist_TinyRepayLiquidationGrief.t.sol -vvvv`.
- Result: `3 passed, 0 failed`.
- Previous severity guess: Low / Gas / Informational.
- Re-evaluated severity ceiling: Gas / Informational, Low at most.
- Impact: A stale exact full-debt liquidation can waste gas.
- Likelihood: Medium for exact-input bots.
- Is impact non-dust?: No.
- Is it duplicate?: Maybe; adjacent to acknowledged Spearbit front-run invalidation.
- Is it in scope?: Possibly.
- Is it intended behavior?: State changes naturally invalidate stale quotes.
- Is it user-error/front-end manageable?: Integration-manageable by refresh/retry.
- Is it admin-only?: No.
- Does it rely on weird ERC20 behavior?: No.
- Does it rely on consenting malicious market?: No.
- Does it require unvalidated AI claim?: No.
- Submit decision: Maybe.
- Reason: Hold for human duplicate review; do not mark submit-ready.

### CAND-005 - L-03 RCF top-up liquidation gas grief

- Source: HPH-POC-002; PT-POC-008; BB-POC-011.
- Current status: Proven RCF branch transition; H/M escalation disproven.
- Existing file: `audits/asyam/findings/cantina-L03-rcf-topup-liquidation-gas-grief.md`.
- Existing PoC: `test/asyam/poc/historical/PoC_Hist_RcfTopUpLiquidationGrief.t.sol`.
- Command: `forge test --match-path test/asyam/poc/historical/PoC_Hist_RcfTopUpLiquidationGrief.t.sol -vvvv`.
- Result: `3 passed, 0 failed`.
- Previous severity guess: Low / Gas / Informational.
- Re-evaluated severity ceiling: Informational.
- Impact: A stale full-close quote can revert; adaptive liquidation succeeds.
- Likelihood: Medium at a narrow threshold.
- Is impact non-dust?: No.
- Is it duplicate?: High duplicate and policy-overlap risk.
- Is it in scope?: Weak.
- Is it intended behavior?: Yes; RCF is designed to limit liquidation.
- Is it user-error/front-end manageable?: Integration-manageable.
- Is it admin-only?: No.
- Does it rely on weird ERC20 behavior?: No.
- Does it rely on consenting malicious market?: No.
- Does it require unvalidated AI claim?: No.
- Submit decision: Do not submit.
- Reason: Archive as intended policy behavior.

### CAND-006 - unused signed authorization restores revoked operator

- Source: BB-POC-004 authorization-intent probe.
- Current status: Proven trace; accepted semantics.
- Existing file: None.
- Existing PoC: `test/asyam/poc/blackbox/PoC_Blackbox_AuthorizationIntentSplit.sol`.
- Command: `forge test --match-path test/asyam/poc/blackbox/PoC_Blackbox_AuthorizationIntentSplit.sol -vvvv`.
- Result: Passed.
- Previous severity guess: Duplicate-risk / accepted semantics.
- Re-evaluated severity ceiling: Informational at most.
- Impact: A still-valid user-signed grant can be submitted after direct revoke.
- Likelihood: Depends on a user-created signature.
- Is impact non-dust?: Potential authority restoration, but user-authorized.
- Is it duplicate?: Adjacent to revocation-delay coverage.
- Is it in scope?: Weak.
- Is it intended behavior?: Accepted permit-style semantics.
- Is it user-error/front-end manageable?: User-signature lifecycle issue.
- Is it admin-only?: No.
- Does it rely on weird ERC20 behavior?: No.
- Does it rely on consenting malicious market?: No.
- Does it require unvalidated AI claim?: No.
- Submit decision: Do not submit.
- Reason: No escalation beyond signed capability.

### CAND-007 - HPH-POC-003 self-liquidation callback capture

- Source: Historical-pattern implementation.
- Current status: Disproven / intended behavior.
- Existing file: None.
- Existing PoC: `test/asyam/poc/historical/PoC_Hist_SelfLiquidationCallbackCapture.t.sol`.
- Command: `forge test --match-path test/asyam/poc/historical/PoC_Hist_SelfLiquidationCallbackCapture.t.sol -vvvv`.
- Result: `5 passed, 0 failed`.
- Previous severity guess: Potential H/M if externalized loss existed.
- Re-evaluated severity ceiling: None.
- Impact: No exploit impact demonstrated.
- Likelihood: N/A.
- Is impact non-dust?: No exploit impact.
- Is it duplicate?: Closure extends callback queues.
- Is it in scope?: Tested in scope.
- Is it intended behavior?: Yes; incentive is bounded and fully charged.
- Is it user-error/front-end manageable?: N/A.
- Is it admin-only?: No.
- Does it rely on weird ERC20 behavior?: No.
- Does it rely on consenting malicious market?: No.
- Does it require unvalidated AI claim?: No.
- Submit decision: Do not submit.
- Reason: No accounting or economic invariant break.

## Attack-Plan Queue Register

| ID | Title | Final disposition |
|---|---|---|
| AP-001 | Take callback monetizes temporary state | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-002 | Consumed cap bypass via rounding | `DO_NOT_SUBMIT_DUPLICATE` / disproven |
| AP-003 | `reduceOnly` increases maker exposure | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-004 | Bad debt on economically solvent borrower | `DO_NOT_SUBMIT_CONSENTING_MARKET` / disproven |
| AP-005 | Liquidation over-seize collateral | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-006 | Post-maturity liquidation model divergence | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-007 | Multi-collateral bitmap desync | `DO_NOT_SUBMIT_INVALID` - covered |
| AP-008 | `lossFactor` over-slash lenders | `DO_NOT_SUBMIT_DUPLICATE` / disproven |
| AP-009 | `withdrawable` exceeds loan-token custody | `DO_NOT_SUBMIT_INVALID` - covered |
| AP-010 | `pendingFee` / `lossFactor` desync | `DO_NOT_SUBMIT_DUPLICATE` / covered |
| AP-011 | Canceled ratifier-root reuse | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-012 | Delegate grief exceeds intent | `DO_NOT_SUBMIT_DUPLICATE` |
| AP-013 | Signature field replay beyond malleability | L-01 only; wider replay disproven |
| AP-014 | Periphery temporary balance leakage | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-015 | Exact target falsely impossible | `DO_NOT_SUBMIT_DUPLICATE` / disproven |
| AP-016 | Helper revert breaks documented skip | `DO_NOT_SUBMIT_INTENDED` |
| AP-017 | Permit2 unintended operation | `DO_NOT_SUBMIT_INVALID` |
| AP-018 | Oracle / gate forced on victim | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-019 | Flash-loan repayment bypass | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-020 | Maturity-second accounting | `DO_NOT_SUBMIT_DUPLICATE` / covered |
| AP-021 | Repay callback reentrancy | `DO_NOT_SUBMIT_DUPLICATE` |
| AP-022 | CVL market-ID aliasing | P3-02 `SUBMIT_INFORMATIONAL` |
| AP-023 | Referral budget underflow | `DO_NOT_SUBMIT_INVALID` |
| AP-024 | Same loan / collateral self-loop insolvency | `DO_NOT_SUBMIT_INVALID` - disproven |
| AP-025 | `roleSetter` zero brick | P3-01 `HOLD_WEAK` |
| AP-026 | Nested callback composition | `DO_NOT_SUBMIT_INVALID` - disproven |

## Composition Queue Register

Implemented composition probes are closed by
`workflow/compositionHunt/12_POC_RESULTS.md`. Unimplemented rows remain planning
hypotheses only.

| IDs | Candidate families | Final disposition |
|---|---|---|
| COMP-001..COMP-005 | Ratifier fallback, exact target, loss/fee order, maturity flash, delegated Permit2 | `DO_NOT_SUBMIT_INVALID` - disproven |
| COMP-006..COMP-010 | Oracle liveness, shared custody, callback root, formal alias runtime probe, fee route | `DO_NOT_SUBMIT_INVALID` / intended |
| COMP-011..COMP-015 | Partial repay slash, reduce-only route, dust drift, callback cash, maturity callback | `DO_NOT_SUBMIT_INVALID` / dust-only |
| COMP-016..COMP-020 | Shared groups, permit stale root, cross-market custody, gate delay, oracle cleanup | `DO_NOT_SUBMIT_INVALID` / consenting-market |
| COMP-021..COMP-025 | Expired fallback, callback fill, cancellation, flash bundle, fee-root quote | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` unless implemented closure exists |
| COMP-026..COMP-030 | Cross-market maturity, health proof, fee claim, revoked signer, dust socialization | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` unless implemented closure exists |

## Blackbox Queue Register

| IDs | Candidate families | Final disposition |
|---|---|---|
| BB-POC-001..BB-POC-006 | Deferred update, bad debt, bundle bounds, auth intent, quote mismatch, cross-market aggregate | `DO_NOT_SUBMIT_INVALID` / accepted semantics |
| BB-POC-007..BB-POC-010 | Permissionless contamination, dust flip, event mismatch, deferred loss-factor withdraw | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` unless implemented closure exists |
| BB-POC-011 | RCF threshold flip | L-03 `DO_NOT_SUBMIT_INTENDED` |
| BB-POC-012..BB-POC-018 | Collateral order, repay dust, supply atomicity, maturity route, groups, forced touch, bitmap | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` unless implemented closure exists |
| BB-POC-019 | Token-as-collateral aggregate | `DO_NOT_SUBMIT_INVALID` - disproven |
| BB-POC-020 | Full event replay | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` |

## Pattern-Transplant Queue Register

These are planning hypotheses, not findings.

| IDs | Candidate families | Final disposition |
|---|---|---|
| PT-POC-001..PT-POC-005 | Flash array, multicall, liquidation order, fee context, poison route | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` |
| PT-POC-006..PT-POC-010 | Ratified family, oracle route, RCF flip, permit split, read-only influence | `DO_NOT_SUBMIT_INVALID_UNVALIDATED`; PT-008 maps to archived L-03 |
| PT-POC-011..PT-POC-015 | Approval residue, ERC2612 front-run, gate maturity, callback custody, maker liquidity | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` |
| PT-POC-016..PT-POC-020 | Root fallback, collateral permutation, max index, fee health, tick branch | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` |
| PT-POC-021..PT-POC-025 | Maturity route, relayer auth, proof grief, event replay, lazy loss | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` |

## Historical-Pattern Queue Register

| IDs | Candidate families | Final disposition |
|---|---|---|
| HPH-POC-001 | Tiny repay liquidation grief | L-02 `MAYBE_DUPLICATE_DO_NOT_SUBMIT_UNLESS_REVIEWED` |
| HPH-POC-002 | RCF top-up liquidation grief | L-03 `DO_NOT_SUBMIT_INTENDED` |
| HPH-POC-003 | Self-liquidation callback capture | `DO_NOT_SUBMIT_INTENDED` - disproven |
| HPH-POC-004..HPH-POC-010 | Fanout gas, poison leg, maturity strategy, ratifier proof, ticks, flash observation, CVL multicall | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` |
| HPH-POC-011..HPH-POC-017 | Callback re-supply, quote invalidation, collateral fanout, first touch, forced update, gate recovery, liquidity disappearance | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` |
| HPH-POC-018..HPH-POC-025 | Proof work, order gas, callback pull, duplicate collateral, events, claim recycle, preview fanout, preflight cost | `DO_NOT_SUBMIT_INVALID_UNVALIDATED` |

## Hashlock Hypothesis Register

| Hashlock item | Final disposition |
|---|---|
| Ratifier M-01 cancel/root front-running | `HOLD_WEAK` ordinary cancellation MEV |
| Ratifier M-02 unbounded collateral params | `DO_NOT_SUBMIT_INVALID` |
| Ratifier M-03 delegated cancel / de-ratify | `DO_NOT_SUBMIT_DUPLICATE` |
| Ratifier L-01 signature malleability | CAND-001 local PoC `SUBMIT_LOW` |
| Ratifier L-02 setter proof length gas | `HOLD_WEAK` caller-paid gas only |
| Ratifier L-03 irreversible cancel root | `HOLD_WEAK` operational design risk |
| Ratifier L-04 zero maker | `DO_NOT_SUBMIT_INVALID` |
| Bundle High-01 ERC777 reentrancy | `DO_NOT_SUBMIT_WEIRD_TOKEN` |
| Bundle High-02 accumulated-balance theft | `DO_NOT_SUBMIT_INVALID` - disproven |
| Bundle Medium-01 referral underflow | `DO_NOT_SUBMIT_INVALID` |
| Bundle Medium-02 inverse precision | `DO_NOT_SUBMIT_DUPLICATE` |
| Bundle Medium-03 referral reduces repay | `DO_NOT_SUBMIT_INTENDED` |
| Bundle Medium-04 zero caps | `HOLD_WEAK` empty-offer semantics |
| Bundle Medium-05 buyer helper revert | `DO_NOT_SUBMIT_INTENDED` |
| Bundle Medium-06 zero seller price | `DO_NOT_SUBMIT_DUPLICATE` |
| Bundle Low-02 empty takes OOB | `HOLD_WEAK` revert-only test gap |
| Bundle Low-04 reverting referral recipient | `DO_NOT_SUBMIT_USER_ERROR` |
| Bundle Low-05 settlement fee staleness | `DO_NOT_SUBMIT_DUPLICATE` |
| Bundle Low-07 Permit2 replay | `DO_NOT_SUBMIT_INVALID` |
| Core callback reentrancy queue | `DO_NOT_SUBMIT_INVALID` after local closures |
| Gate / oracle liveness | `DO_NOT_SUBMIT_CONSENTING_MARKET` absent forced victim |
| Ratifier root grief | `DO_NOT_SUBMIT_DUPLICATE` |
| Exact fill failures | `DO_NOT_SUBMIT_DUPLICATE` absent current-code divergence |

## Audited JSON Register

Every Spearbit and Blackthorn item listed in `workflow/03_DEDUP_MAP.md` is prior
audit material and classified `DO_NOT_SUBMIT_DUPLICATE`. The corpus is a filter,
not a source of new submissions.

## Source-ID Completeness Appendix

The canonical entries and grouped registers above control disposition. This
appendix lists every queue ID individually so review automation can confirm that
no planning entry was silently dropped.

### Composition IDs

| ID | Title |
|---|---|
| COMP-001 | Ratified route fallback shares consumed group after canceled root |
| COMP-002 | Exact-target route with canceled root and referral split |
| COMP-003 | Loss socialization, stale lender, withdrawable, and fee-claim ordering |
| COMP-004 | Post-maturity liquidation funded by flash loan and callback unwind |
| COMP-005 | Delegated taker uses Permit2 route with independent payer and referral |
| COMP-006 | Multi-collateral oracle liveness blocks gated post-maturity unwind |
| COMP-007 | Shared loan token across markets exposes nested bundle custody ordering |
| COMP-008 | Callback mutates ratifier root while outer offer state is transient |
| COMP-009 | Formal market alias becomes executable shared-token accounting probe |
| COMP-010 | Fee update invalidates first route leg and changes fallback economics |
| COMP-011 | Partial repay before slash changes stale lender withdrawal after socialization |
| COMP-012 | `reduceOnly` route leg crosses exposure after an earlier bundle fill |
| COMP-013 | Repeated dust drift becomes non-dust loss through socialization threshold |
| COMP-014 | Liquidation callback withdraws repaid cash before outer pull |
| COMP-015 | Exact-maturity take callback nests repay before seller health check |
| COMP-016 | Setter-ratified roots share a group across bundle and direct call |
| COMP-017 | ERC2612 permit consumed before stale-root route executes |
| COMP-018 | Cross-market same-token repay-and-withdraw consumes globally shared custody |
| COMP-019 | Gated liquidation delays recovery until social-loss ordering changes |
| COMP-020 | Active oracle revert prevents bitmap cleanup before post-maturity recovery |
| COMP-021 | Expired root leg silently skips into worse valid fallback |
| COMP-022 | Callback direct fill consumes group before outer bundle reaches fallback |
| COMP-023 | Authorized callback raises maker consumed cancellation during route |
| COMP-024 | Flash-funded nested bundle interacts with shared-token liquidation inflow |
| COMP-025 | Fee change plus signed root causes route-local quote asymmetry |
| COMP-026 | Callback switches to second market at a different maturity |
| COMP-027 | Healthiness proof gap exercised by take callback state consumer |
| COMP-028 | Bad-debt realization across shared-token markets changes fee-claim availability |
| COMP-029 | Delegated root signer revoked between route construction and fallback |
| COMP-030 | Same-token cross-market dust drift feeds later socialized loss |

### Blackbox IDs

| ID | Title |
|---|---|
| BB-POC-001 | Deferred Position Update |
| BB-POC-002 | Bad Debt Recoverability |
| BB-POC-003 | User Intent Bundle |
| BB-POC-004 | Authorization Intent Split |
| BB-POC-005 | Quote Settlement Mismatch |
| BB-POC-006 | Cross-Market Aggregate Accounting |
| BB-POC-007 | Permissionless Market Contamination |
| BB-POC-008 | Dust to Non-Dust State Flip |
| BB-POC-009 | Event Storage Mismatch |
| BB-POC-010 | Deferred Loss Factor Withdraw |
| BB-POC-011 | RCF Threshold State Flip |
| BB-POC-012 | Multi-Collateral Liquidation Order |
| BB-POC-013 | Bundle Repay Dust Lock |
| BB-POC-014 | Collateral Supply Atomicity |
| BB-POC-015 | Maturity Route Boundary |
| BB-POC-016 | Group Family Ambiguity |
| BB-POC-017 | Forced Position Touch |
| BB-POC-018 | Bitmap Zero Path |
| BB-POC-019 | Multi-Market Token-As-Collateral |
| BB-POC-020 | Full Event Replay |

### Pattern-Transplant IDs

| ID | Title |
|---|---|
| PT-POC-001 | Duplicate-token flash-array settlement |
| PT-POC-002 | Multicall state-transition composition |
| PT-POC-003 | Liquidation-order social-loss divergence |
| PT-POC-004 | Continuous-fee claim context switch |
| PT-POC-005 | Partial-success poison route |
| PT-POC-006 | Ratified family semantic collision |
| PT-POC-007 | Involuntary oracle-route contamination |
| PT-POC-008 | RCF threshold collateral-order flip |
| PT-POC-009 | Permit receiver-referral split |
| PT-POC-010 | Read-only intermediate-state route influence |
| PT-POC-011 | Standard-token approval residue sequence |
| PT-POC-012 | ERC2612 tolerate-front-run context switch |
| PT-POC-013 | Gate liveness maturity escalation |
| PT-POC-014 | Shared-token nested callback aggregate custody |
| PT-POC-015 | Maker-liquidity disappearance exact route |
| PT-POC-016 | Root replacement fallback economics |
| PT-POC-017 | Collateral index activation permutation |
| PT-POC-018 | Maximum collateral index boundary |
| PT-POC-019 | Continuous-fee threshold health flip |
| PT-POC-020 | Tick threshold liquidation branch |
| PT-POC-021 | Maturity quote route lifecycle |
| PT-POC-022 | Relayer authorization referral composition |
| PT-POC-023 | Ratifier return-data grief after valid leg |
| PT-POC-024 | Event-storage reconstruction mismatch |
| PT-POC-025 | Lazy-loss eager-touch control |

### Historical-Pattern IDs

| ID | Title |
|---|---|
| HPH-POC-001 | Tiny repay liquidation front-run escalates delay into bad debt |
| HPH-POC-002 | One-wei collateral top-up flips liquidation RCF mode |
| HPH-POC-003 | Self-liquidation callback recycles seized collateral into replacement debt |
| HPH-POC-004 | Ordinary collateral fanout makes liquidation impractical |
| HPH-POC-005 | First-touch valid maximal-collateral market poisons a route by gas |
| HPH-POC-006 | Maturity crossing changes cheapest liquidation front-run strategy |
| HPH-POC-007 | SetterRatifier proof-cost asymmetry after prior route effect |
| HPH-POC-008 | Tick-spacing refinement unlocks stale signed offer |
| HPH-POC-009 | Flash temporary balance affects core-selected oracle or gate observation |
| HPH-POC-010 | Runtime multicall reaches sequence omitted by CVL summary |
| HPH-POC-011 | Liquidation callback re-supplies collateral without reborrow |
| HPH-POC-012 | Minimal top-up invalidates exact seized-assets liquidation quote |
| HPH-POC-013 | Collateral fanout freezes withdrawal during stress |
| HPH-POC-014 | First touch SSTORE2 cost breaks route preflight |
| HPH-POC-015 | Permissionless position update realizes unfavorable threshold |
| HPH-POC-016 | Gate recovery ordering crosses maturity into social loss |
| HPH-POC-017 | Maker liquidity disappearance combines with first-touch route cost |
| HPH-POC-018 | Ratifier proof family maximizes route work |
| HPH-POC-019 | Collateral index ordering causes asymmetric liquidation gas |
| HPH-POC-020 | Liquidation callback outer pull is funded with recycled proceeds |
| HPH-POC-021 | Duplicate ordinary collateral entries amplify protective action cost |
| HPH-POC-022 | Events omit route-critical first-touch market context |
| HPH-POC-023 | Claim redemption follows callback-induced collateral recycle |
| HPH-POC-024 | Oracle fanout differs between preview and executable protective action |
| HPH-POC-025 | Route preflight omits first-touch and proof-cost composition |
