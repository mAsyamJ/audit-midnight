# Composition PoC Results

Date: 2026-05-30

## Scope

These are exploratory composition probes under `test/asyam/poc/composition/`. They are not Cantina findings. A probe
is promoted to `test/asyamFindings/` only after it demonstrates concrete, non-duplicate impact. No probe below passed
that gate.

## Validation

```bash
forge test --match-path 'test/asyam/poc/composition/*.sol' -vvv
```

Log: `composition_poc_tests.log`

## Final Repository Verification

| Command | Result | Log |
|---|---|---|
| `forge build` | passed | `final_build.log` |
| `forge test --match-path 'test/asyam/**/*.sol' -vvv` | 77 passed | `final_exploratory_tests.log` |
| `forge test --match-path 'test/asyamFindings/*.sol' -vvv` | 14 passed | `final_validation_tests.log` |
| `forge test -vvv` | 464 passed | `final_full_tests.log` |

## Results

| Probe | Tests | Status | Evidence |
|---|---:|---|---|
| `PoC_Comp_RatifierPeripheryConsumed.sol` | 2 | disproven | canceled root fallback and direct-fill fallback preserve the shared consumed cap |
| `PoC_Comp_ExactTargetCanceledRoot.sol` | 1 | disproven | canceled root is skipped, valid fallback fills exactly, referral accounting is exact, router residue is zero |
| `PoC_Comp_LossFactorWithdrawableFee.sol` | 2 | disproven / dust only | claim-before-withdraw and withdraw-before-claim remain backed; at most one wei remains |
| `PoC_Comp_MaturityLiquidationFlash.sol` | 3 | disproven | callback precredit cannot externalize unpaid claims; flash liquidation profit is only the disclosed incentive |
| `PoC_Comp_DelegatePermit2Route.sol` | 2 | disproven | delegated route charges caller context; a victim permit fails under a different caller |
| `PoC_Comp_CrossMarketSharedToken.sol` | 2 | disproven | a nested backed claim can roll across markets, but production IDs isolate claims and no float remains |
| `PoC_Comp_ReduceOnlyBundleRoute.sol` | 1 | disproven | a route skips the reduce-only leg that would cross maker credit into debt |
| `PoC_Comp_CallbackRatifierRoot.sol` | 1 | disproven | callback-time root activation observes outer consumed state; nested fills cannot exceed the shared cap |
| `PoC_Comp_FeeChangeRouteQuote.sol` | 2 | intended / duplicate-risk | a fee increase atomically skips low-price stale legs; bounded fallback settlement uses the current fee |
| `PoC_Comp_MultiCollateralOracleGate.sol` | 1 | intended liveness | active oracle revert and liquidator gate block atomically; recovery permits liquidation |
| `PoC_Comp_PostMaturityBadDebtWithdraw.sol` | 2 | disproven / dust only | repay/slash order and lender withdrawal order remain custody-backed with only per-lender rounding dust |
| `PoC_Comp_DustDriftToNonDustLoss.sol` | 2 | disproven / dust only | splitting one claim across 32 lenders strands at most one wei per lender and cannot externalize residue |

## Backlog Coverage

The dedicated runtime probes cover POC-COMP-01 through POC-COMP-09, POC-COMP-11, POC-COMP-13, and POC-COMP-15.
`PoC_Comp_CrossMarketSharedToken.sol` also establishes production runtime isolation for POC-COMP-10.
`PoC_Comp_PostMaturityBadDebtWithdraw.sol` covers the accounting permutation requested by POC-COMP-12.
`PoC_Comp_MultiCollateralOracleGate.sol` plus the post-maturity withdrawal-order probe cover the selected-market
liveness and social-loss boundary from POC-COMP-14.

## Classification

- No new High or Medium vulnerability was proven.
- No new file was promoted into `test/asyamFindings/`.
- Fee staleness, oracle/gate liveness, social-loss rounding, and fragmentation dust remain documented or prior-audit
  risk classes unless a materially different attacker extraction path is demonstrated.
