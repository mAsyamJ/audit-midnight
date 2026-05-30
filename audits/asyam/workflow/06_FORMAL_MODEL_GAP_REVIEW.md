# 06 Formal Model Gap Review

Date: 2026-05-30

## Proven Gap

### `Solvency.spec` aliases production-distinct markets

Production `src/libraries/IdLib.sol` hashes the complete encoded `Market`. The `certora/specs/Solvency.spec` summary hashes only:

```text
(market.loanToken, market.maturity, chainId, midnight)
```

This aliases supported markets that differ in collateral configuration, `rcfThreshold`, or gates. If two aliased markets use different collateral tokens, the summary's `collateralToken[id][index]` requirements contradict each other and prune a valid production composition. If the omitted fields differ without changing collateral tokens, liabilities can still collapse into one modeled bucket.

Audit-only validation:

```text
test/asyam/poc/PoC_SolvencySpecMarketIdAliasing.t.sol
test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol
```

Finding: [../findings/cantina-P3-02-solvency-spec-market-id-aliasing.md](../findings/cantina-P3-02-solvency-spec-market-id-aliasing.md)

## Explicit Model Boundaries

These limits are not production vulnerabilities by themselves. They define where Foundry composition tests remain necessary.

| Boundary | Evidence | Audit consequence |
|---|---|---|
| Periphery excluded | `certora/**` verifies core contracts, not `MidnightBundles` | Keep bundle balance and permit composition campaigns in Foundry |
| Exact non-reentrant ERC20 assumption | `Solvency.spec` ERC20 summaries and core comments | Weird-token paths require a distinct in-scope argument |
| `onBuy` / `onSell` summarized as `NONDET` in solvency proof | `Solvency.spec` methods block | Solvency proof does not cover reentrant take-callback composition |
| Selected callbacks dispatched through known helpers | `Solvency.spec` callback summaries | Unknown callback implementations are not exhaustively modeled |
| Bounded optimistic loops | `certora/confs/Solvency.conf` uses `optimistic_loop: true`, `loop_iter: 2` | Multi-collateral and repeated-call Foundry probes remain useful |
| Health callback post-state is assumed healthy | `Healthiness.spec::genericCallback` requires health after havoc | The health proof documents preservation under that callback assumption; it does not prove arbitrary callback composition |
| `take` is excluded from the general health rule | `Healthiness.spec::stayHealthy` filters out `take` and has no replacement `take` rule | Read the README's broad health-preservation statement as incomplete; Foundry `take` regressions remain required |
| Health and bitmap specs bound collateral lengths in selected rules | `Healthiness.spec`, `CollateralBitmap.spec` | Treat broad README claims with the rule-level bounds in mind |

## Review Rule

Before relying on a CVL result to close a candidate:

1. Read the method summaries and `preserved` blocks.
2. Check whether callbacks, tokens, hashes, loops, gates, or oracles are summarized.
3. Confirm the summary preserves production identity and storage separation.
4. Add an audit-only Foundry regression when a real production path crosses a model boundary.

## Documentation Notes

- `certora/README.md` describes `Healthiness.spec` as checking that no action except oracle updates can make a healthy borrower unhealthy. The spec excludes `take`, so the sentence needs a qualifier or an additional rule.
- `certora/README.md` spells `optimistic_hashing` as `optimitic_hashing`.
