# Proof Commands and Test Status

Date: 2026-05-31

## Baseline Commands

```bash
forge build
forge test -vvv
forge test --match-path 'test/asyam/poc/**/*.sol' -vvvv
git diff --check -- audits/asyam
```

Fresh result:

| Command | Result |
|---|---|
| `forge build` | Passed |
| `forge test -vvv` | `485 passed, 0 failed, 0 skipped` |
| PoC glob | `91 passed, 0 failed, 0 skipped` |
| `git diff --check -- audits/asyam` | Passed |

Saved logs:

- `baseline_build.log`
- `baseline_tests.log`
- `poc_tests.log`
- `diff_check.log`
- `status_grep.log`

## Packet Proof Commands

```bash
forge test --match-path test/asyamFindings/PoC_SignatureMalleability.t.sol -vvv
forge test --match-path test/asyamFindings/PoC_RoleSetterBricking.t.sol -vvv
forge test --match-path test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol -vvvv
forge test --match-path test/asyam/poc/historical/PoC_Hist_TinyRepayLiquidationGrief.t.sol -vvvv
forge test --match-path test/asyam/poc/historical/PoC_Hist_RcfTopUpLiquidationGrief.t.sol -vvvv
```

Verified results:

| PoC | Result |
|---|---|
| Signature malleability | `2 passed, 0 failed` |
| Role setter bricking | `1 passed, 0 failed` |
| CVL market-ID aliasing | `2 passed, 0 failed` |
| Tiny repay liquidation grief | `3 passed, 0 failed` |
| RCF top-up liquidation grief | `3 passed, 0 failed` |

Saved packet logs:

- `proof_L01.log`
- `proof_P3_01.log`
- `proof_P3_02.log`
- `proof_L02.log`
- `proof_L03.log`

## Final Checks

```bash
jq empty audits/asyam/submissionReview/submission_review_graph.json
rg -n 'DRAFT''_REVIEW_REQUIRED' audits/asyam || true
git diff --check -- audits/asyam
git diff --name-only -- src
```

`git diff --name-only -- src` must remain empty.
