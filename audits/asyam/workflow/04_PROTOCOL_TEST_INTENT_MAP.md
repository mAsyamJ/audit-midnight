# Protocol Test Intent Map

Date: 2026-05-30

## Purpose

Before classifying a candidate, read the Midnight protocol-authored tests as executable design evidence. A passing local PoC is not sufficient to close a broad candidate when the PoC covers only one example. Compare the candidate against:

1. production NatSpec and implementation ordering;
2. protocol-authored tests and their asserted invariants;
3. audited corpus dedup notes;
4. adversarial exploratory probes under `test/asyam`;
5. promoted validation regressions under `test/asyamFindings`.

Protocol-authored tests establish intended behavior, but do not prove adversarial completeness. Keep them read-only. Add exploratory probes under `test/asyam` when callbacks, nested router calls, boundary math, or unusual market composition are outside their scenarios. Promote stable validation regressions into `test/asyamFindings`.

## Candidate Intent Mapping

| Candidate | Protocol-authored evidence | Intended invariant | Additional validation needed |
|---|---|---|---|
| C-12 reduce-only rounding edge | `test/TakeTest.sol`: `testReduceOnlyBuySuccess`, `testReduceOnlyBuyRevert`, `testReduceOnlySellSuccess`, `testReduceOnlySellRevert` fuzz both sides | A reduce-only maker may exit existing debt/credit, but cannot cross through zero into new credit/debt | Retain the one-wei regression in `test/asyamFindings/Validation_LiveQueues.t.sol`; inspect callback ordering to confirm every nested fill independently re-checks the invariant |
| C-26 bundler temporary-balance theft | `test/MidnightBundlesTest.sol` asserts zero router residual after buy, sell, referral, repay, and collateral-composition routes; core `TakeTest` covers callback ordering and nested liquidation lock | Router distributions should use per-call computed amounts, not `balanceOf(router)` | Added a multi-leg outer sell where the second offer callback reenters another sell bundle while first-leg proceeds are parked in the router |
| C-29 referral exact-fill boundary | `test/MidnightBundlesTest.sol`: all four referral routes plus repay referral fuzzers; NatSpec says buy-units total spend includes `filledBuyerAssets + fee` and is capped by `maxBuyerAssets` | Insufficient total budget, including referral fee, must revert atomically; exact boundary budget must succeed without router residual | Added a buy-units boundary regression at `requiredBudget - 1` and `requiredBudget`, because the existing custom asset-target test does not address the Hashlock units-target claim |
| C-31 same loan/collateral token self-loop | No dedicated protocol-authored same-token market test. Generic repay, withdraw, liquidation, and callback tests establish ordering but use distinct assets | Fungible custody must remain sufficient for collateral accounting plus withdrawable lender claims even when loan and collateral addresses coincide | Added repay-from-collateral, same-token leverage unwind, and liquidation repayment sourced from seized same-token collateral |

## Closure Rule

- Mark `invalid` when implementation semantics intentionally revert and the boundary is validated atomically.
- Mark `disproven` only for the tested attack class and state the assumptions.
- Keep residual scenarios explicit when token hooks, malicious oracles, or multi-collateral composition are outside the test.
- Do not edit protocol-authored tests to close an audit candidate.
