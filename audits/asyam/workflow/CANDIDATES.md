# Candidates

Date: 2026-05-30

**Canonical registry moved to:** [../candidates/CANDIDATES.md](../candidates/CANDIDATES.md)

**PoC outcomes:** [POC_RESULTS.md](POC_RESULTS.md)

## Quick status (priority queue)

| Legacy ID | Title | Status |
|---|---|---|
| C-26 | Periphery temporary-balance leakage | disproven — `PoC_BundleTemporaryBalanceReentrancy.t.sol` |
| C-14 | Callback reentrancy accounting break | disproven — `PoC_TakeCallbackReentrancy.t.sol` |
| C-05 | Grouped offer cap overfill | duplicate — `PoC_OfferConsumedCapRounding.t.sol` |
| C-12 | Reduce-only rounding edge | disproven — `PoC_DeepValidationQueues.t.sol` + promoted regression |
| C-29 | Referral exact-fill boundary | invalid — intentional total-budget guard |
| C-31 | Same loan/collateral token | scoped disproval — exploratory probe + promoted regressions |
| C-41 | Signature malleability | proven — Cantina L-01 |
| C-40 | roleSetter zero brick | proven — Cantina P3-01 |
| C-36 | CVL market-ID summary aliasing | proven — P3 formal-assurance gap |

See full candidate table (36 entries) in `audits/asyam/candidates/CANDIDATES.md`.
