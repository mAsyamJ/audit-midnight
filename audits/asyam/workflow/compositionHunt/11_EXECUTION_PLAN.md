# Composition Hunt Execution Plan

Date: 2026-05-30

## Current Phase

The initial composition campaign is implemented under `test/asyam/poc/composition/`. Native tests and `src/*` remain
read-only. No composition has passed the promotion gate for `test/asyamFindings/`.

## Top Five Implementation Order

| Order | PoC | Why first | Required mocks | Expected effort | Fallback if disproven |
|---|---|---|---|---|---|
| 1 | `PoC_Comp_RatifierPeripheryConsumed.sol` | highest-feasibility cross-domain cap/route state probe | callback root toggler / nested taker | medium | close PCR-01/03/06/14 and reuse harness for root routes |
| 2 | `PoC_Comp_ExactTargetCanceledRoot.sol` | tests route atomicity across ratifier failure and fee split | existing permit token | low/medium | close stale-root exact-route family |
| 3 | `PoC_Comp_LossFactorWithdrawableFee.sol` | highest economic accounting value | configurable oracle | medium | retain permutation harness for invariant fuzz |
| 4 | `PoC_Comp_MaturityLiquidationFlash.sol` | strongest temporary-balance extraction hypothesis | multi-interface callback orchestrator | high | isolate nested withdraw-before-pull slice |
| 5 | `PoC_Comp_DelegatePermit2Route.sol` | resolves authorization-context uncertainty | vendor Permit2 | medium | classify as intended broad delegation |

## Commands

```bash
mkdir -p test/asyam/poc/composition
forge test --match-path 'test/asyam/poc/composition/PoC_Comp_RatifierPeripheryConsumed.sol' -vvvv
forge test --match-path 'test/asyam/poc/composition/PoC_Comp_ExactTargetCanceledRoot.sol' -vvvv
forge test --match-path 'test/asyam/poc/composition/PoC_Comp_LossFactorWithdrawableFee.sol' -vvvv
forge test --match-path 'test/asyam/poc/composition/PoC_Comp_MaturityLiquidationFlash.sol' -vvvv
forge test --match-path 'test/asyam/poc/composition/PoC_Comp_DelegatePermit2Route.sol' -vvvv
```

## Per-PoC Workflow

1. Re-read `00_CLOSED_QUEUE_DIGEST.md`, the selected `COMP-XXX`, and `10_DISPROOF_CRITERIA.md`.
2. Add one focused exploratory file under `test/asyam/poc/composition/`; reuse `Config.t.sol`.
3. Assert balances and state, not revert-only behavior.
4. Run the single PoC with `-vvvv`, then the entire composition folder and `test/asyam/**/*.sol`.
5. Record result as proven, disproven, invalid, duplicate, or intended. Do not write a finding until the proof gate passes.

## Later Invariants

After the top five harnesses stabilize, add stateful campaigns for aggregate shared-token custody, ratifier-route consumed caps, lossFactor/withdrawable/fee permutations, and no-router-residual after nested routes.

## Executed Expansion

The top five were extended with runtime probes for:

- shared-token cross-market callback settlement;
- reduce-only bundle fallback;
- callback-time ratifier root activation;
- fee-update stale route fallback;
- multi-collateral oracle and liquidator-gate liveness;
- post-maturity bad-debt withdrawal order;
- fragmented-lender slash dust.

See `12_POC_RESULTS.md` and `composition_poc_tests.log`.

## Baseline Evidence

- `baseline_build.log`: `forge build`
- `baseline_tests.log`: `forge test -vvv` (`443/443`)
- `existing_poc_tests.log`: closed exploratory queue (`50/50`)

## Exact Next Command

Run the complete composition campaign:

```bash
forge test --match-path 'test/asyam/poc/composition/*.sol' -vvv
```
