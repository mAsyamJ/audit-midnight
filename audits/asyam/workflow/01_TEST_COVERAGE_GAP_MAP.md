# 01 Test Coverage Gap Map

Date: 2026-05-30

## Baseline

`forge build` passes after cleaning up the placeholder `test/asyamFindings/config.t.sol`.

`forge test -vvv` passes:

```text
405 tests passed, 0 failed, 0 skipped
```

## Strong Existing Foundry Coverage

- Core take flows: buy/sell sides, post-maturity behavior, grouped offers, max units/assets, reduce-only, callbacks, self-take, ratification.
- Liquidation: normal and post-maturity modes, bad debt, recovery close factor, full/partial liquidation, collateral bitmap clearing, gates, callbacks.
- Fees: default and market settlement fees, continuous fee accrual, fee claiming, slash interaction.
- Authorization: user/operator controls for withdraw, collateral, repay, take, consumed, and authorization mutation.
- Ratifiers: Ecrecover and setter ratification, cancellation, authorized signer/root flows, leaf index usage.
- Bundles: target units/assets, permits, Permit2, referral fees, collateral supply/withdraw, inconsistent market checks, partially consumed offers.
- Tokens: safe transfer helper behavior for no-return, false-return, no-code, and reverting tokens.
- Market creation: collateral bounds, sorted collateral params, LLTV/LIF constraints, maturity bound, market state getter.
- Gates: enter and liquidator gates, exit paths, no-gate behavior.

## Protocol-Authored Test Intent Review

Before extending PoCs, map each hypothesis to the Midnight protocol-authored tests and read their assertions as executable design evidence. Keep native tests read-only. Add exploratory attack probes under `test/asyam`, then promote stable regressions into `test/asyamFindings`. This prevents duplicate PoCs from being mistaken for new coverage and prevents a single happy-path regression from closing a broader adversarial class.

See [04_PROTOCOL_TEST_INTENT_MAP.md](04_PROTOCOL_TEST_INTENT_MAP.md) for the candidate-by-candidate intent map and closure rule.

## Material Gaps

1. Callback reentrancy is only partially covered.

Existing tests cover some callback success/revert behavior and seller liquidation lock paths, but do not exhaustively test reentry from buy/sell/repay/liquidate/flash callbacks into all other core functions and periphery functions. This remains a live queue only if a PoC proves value extraction or permanent accounting corruption distinct from Blackthorn L-19, L-20, and L-26.

2. Periphery accumulated-balance and cross-call token leakage is partially closed under standard-token assumptions.

Bundle functions hold loan/collateral tokens temporarily and then call Midnight. Audit probes now cover a visible refund float and a multi-leg outer sell where a nested sell bundle runs while first-leg proceeds are parked in the router. Computed per-call transfers preserve the outer proceeds. Token-hook reentry remains outside the protocol's stated token non-reentrancy assumption.

3. Exact-fill inverse math has tests but needs boundary fuzzing against current core.

`TakeAmountsLib` and `ConsumableUnitsLib` are tested over common fuzz ranges. The audited corpus already includes helper/core mismatch issues. Any new PoC must show a current-code divergence not covered by Blackthorn L-6/L-7 and not just a revert/rounding dust edge.

4. Permit2/ERC2612 composition is not adversarially fuzzed.

Current tests prove happy-path Permit2 and ERC2612 bundle usage. Missing tests include reused signatures across function contexts, third-party front-run consumption, and zero/different recipient edge cases. Preliminary read suggests Permit2 nonce semantics and ERC2612 transfer-after-permit make some Hashlock claims weak, but this remains a bounded queue.

5. Event reconstructibility is not tested.

There are tests for event emission in selected paths, but no indexer-style test that replays events and reconstructs all state, including lazy `UpdatePosition`, continuous-fee credit, collateral bitmap, market fee defaults at creation, and per-collateral balances. This is mainly P3/Low unless a real off-chain safety guarantee depends on event completeness.

6. Same token as loan and collateral has scoped standard-token coverage.

The code does not appear to forbid `market.loanToken` also being a collateral token. Repay-from-collateral, two-step leverage unwind, and liquidation repayment sourced from seized same-token collateral now pass while custody backs lender claims and remaining collateral. Multi-collateral compositions and malicious token/oracle behavior remain separate queues.

7. Dynamic oracle and gate behavior is mostly accepted/model-scoped.

Tests include reverting and zero oracle paths, plus gate allows/blocks. Missing cases include stateful gates/oracles that change behavior intra-transaction through callbacks. Likely accepted market-design risk unless a path traps unrelated exits or socializes bad debt without relying on malicious market configuration.

8. Formal verification does not cover periphery and has explicit external-call assumptions.

The Solvency CVL review found a concrete summary mismatch: `CVL_toId` hashes only loan token, maturity, chain ID, and Midnight address, while production IDs include the entire market configuration. Audit regressions demonstrate two supported production markets that remain distinct on-chain but alias under the CVL key. See [06_FORMAL_MODEL_GAP_REVIEW.md](06_FORMAL_MODEL_GAP_REVIEW.md).

The Healthiness CVL review also found an assurance boundary: `stayHealthy` filters `take` out and there is no replacement `take` rule. Treat the README's broad health-preservation sentence as incomplete and retain Foundry `take` regressions.

## Asyam harness coverage (2026-05-30)

| PoC / invariant | Maps to | Existing test overlap |
|---|---|---|
| `PoC_BundleTemporaryBalanceReentrancy.t.sol` | C-26, Hashlock High-02 | Extends `MidnightBundlesTest` sell paths |
| `PoC_TakeCallbackReentrancy.t.sol` | C-14 | Extends `TakeTest` callback/reentrancy tests |
| `PoC_OfferConsumedCapRounding.t.sol` | C-05, Blackthorn L-5 | Extends grouped cap tests in `TakeTest` |
| `PoC_DeepValidationQueues.t.sol` | C-12, C-29, C-31 | Exploratory reduce-only, referral-budget, and same-token callback probes |
| `PoC_SolvencySpecMarketIdAliasing.t.sol` | C-36 | Proves the solvency model aliases production-distinct supported markets |
| `test/asyamFindings/Validation_LiveQueues.t.sol` | C-12, C-26, C-29, C-31 | Promoted regressions: reduce-only overfill, temporary bundler balances, referral boundary fuzzing, same-token repay/leverage/liquidation |
| `test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol` | C-36 | Stable model-mismatch validation regression |
| `Invariant_BundleNoCrossCallBalanceLeak.t.sol` | bundler balance | New adversarial check |
| `Invariant_LiquidationHealth.t.sol` | Certora Healthiness | Mirrors `LiquidationTest` |

All harness tests: `forge test --match-path 'test/asyam/**/*.sol'`

The CVL corpus is strong for core accounting under its models. Remaining audit value should not duplicate those properties unless the candidate violates a stated modeling assumption in a real implementation path.

## Suggested Invariant Campaigns After Harness Stabilization

- Bundle no-cross-call balance leak: temporary balance held by `MidnightBundles` cannot be stolen or misdirected during any callback/token-hook interleaving.
- Helper/core exactness: bundle inverse math either fills the target exactly or reverts without leaving value in the router.
- Callback non-amplification: any callback reentry either reverts atomically or leaves the same final accounting as non-reentrant ordering.
- Liquidation health and bad debt: zero-input bad-debt realization cannot slash lenders without the documented oracle/liquidation preconditions.
- Consumed caps: aggregate fills across direct core calls and bundle calls do not exceed maker caps except for already-known rounding/known issues.
