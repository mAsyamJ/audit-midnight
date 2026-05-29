# 01 Test Coverage Gap Map

Date: 2026-05-30

## Baseline

`forge build` passes after cleaning up the placeholder `test/asyamFindings/config.t.sol`.

`forge test -vvv` passes:

```text
373 tests passed, 0 failed, 0 skipped
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

## Material Gaps

1. Callback reentrancy is only partially covered.

Existing tests cover some callback success/revert behavior and seller liquidation lock paths, but do not exhaustively test reentry from buy/sell/repay/liquidate/flash callbacks into all other core functions and periphery functions. This remains a live queue only if a PoC proves value extraction or permanent accounting corruption distinct from Blackthorn L-19, L-20, and L-26.

2. Periphery accumulated-balance and cross-call token leakage is not exhaustively tested.

Bundle functions hold loan/collateral tokens temporarily and then call Midnight. Tests cover target fills and referral fees, but not adversarial reentrancy through token hooks or callbacks into another bundle call that observes/transfers temporary balances. This is high duplicate-risk with Hashlock periphery hypotheses and must respect the core token non-reentrancy assumption.

3. Exact-fill inverse math has tests but needs boundary fuzzing against current core.

`TakeAmountsLib` and `ConsumableUnitsLib` are tested over common fuzz ranges. The audited corpus already includes helper/core mismatch issues. Any new PoC must show a current-code divergence not covered by Blackthorn L-6/L-7 and not just a revert/rounding dust edge.

4. Permit2/ERC2612 composition is not adversarially fuzzed.

Current tests prove happy-path Permit2 and ERC2612 bundle usage. Missing tests include reused signatures across function contexts, third-party front-run consumption, and zero/different recipient edge cases. Preliminary read suggests Permit2 nonce semantics and ERC2612 transfer-after-permit make some Hashlock claims weak, but this remains a bounded queue.

5. Event reconstructibility is not tested.

There are tests for event emission in selected paths, but no indexer-style test that replays events and reconstructs all state, including lazy `UpdatePosition`, continuous-fee credit, collateral bitmap, market fee defaults at creation, and per-collateral balances. This is mainly P3/Low unless a real off-chain safety guarantee depends on event completeness.

6. Same token as loan and collateral is not obviously isolated.

The code does not appear to forbid `market.loanToken` also being a collateral token. That may be intended, but it intersects `SOL-Defi-Lending-10` and should be tested for self-borrow/same-asset liquidation loops before treating it as a finding.

7. Dynamic oracle and gate behavior is mostly accepted/model-scoped.

Tests include reverting and zero oracle paths, plus gate allows/blocks. Missing cases include stateful gates/oracles that change behavior intra-transaction through callbacks. Likely accepted market-design risk unless a path traps unrelated exits or socializes bad debt without relying on malicious market configuration.

8. Formal verification does not cover periphery and has explicit external-call assumptions.

The CVL corpus is strong for core accounting under its models. Remaining audit value should not duplicate those properties unless the candidate violates a stated modeling assumption in a real implementation path.

## Suggested Invariant Campaigns After Harness Stabilization

- Bundle no-cross-call balance leak: temporary balance held by `MidnightBundles` cannot be stolen or misdirected during any callback/token-hook interleaving.
- Helper/core exactness: bundle inverse math either fills the target exactly or reverts without leaving value in the router.
- Callback non-amplification: any callback reentry either reverts atomically or leaves the same final accounting as non-reentrant ordering.
- Liquidation health and bad debt: zero-input bad-debt realization cannot slash lenders without the documented oracle/liquidation preconditions.
- Consumed caps: aggregate fills across direct core calls and bundle calls do not exceed maker caps except for already-known rounding/known issues.
