# Exploit-Oriented Attack Plan

Date: 2026-05-30

## Purpose

Code-grounded **exploit planning** from `src/*` and `test/*`—function surfaces, multi-contract compositions, prioritized PoC queue (`AP-XXX`), and execution order. **Not** Cantina findings. Use after [`protocolIntent/`](../protocolIntent/) (economic *why*) and before writing new `test/asyam/poc/` tests.

## Read order

1. [00_SRC_TEST_DEEP_MAP.md](00_SRC_TEST_DEEP_MAP.md) — catalog + call graph
2. [01_FUNCTION_ATTACK_SURFACE_MAP.md](01_FUNCTION_ATTACK_SURFACE_MAP.md) — per-function hooks
3. [06_HIGH_VALUE_POC_QUEUE.md](06_HIGH_VALUE_POC_QUEUE.md) — **primary PoC handoff**
4. [09_DISPROOF_AND_FALSE_POSITIVE_FILTER.md](09_DISPROOF_AND_FALSE_POSITIVE_FILTER.md) — do not re-hunt closed classes
5. [10_EXECUTION_PLAN.md](10_EXECUTION_PLAN.md) — ordered work

Supporting: `02`–`05`, `07`, `08`, [attack_plan_graph.json](attack_plan_graph.json).

## Links

| Artifact | Path |
|---|---|
| Economic intent | [../protocolIntent/README.md](../protocolIntent/README.md) |
| Agent role | [../../.AGENTROLE.md](../../.AGENTROLE.md) |
| Validated findings | [../../findings/findings.md](../../findings/findings.md) |
| PoC outcomes | [../POC_RESULTS.md](../POC_RESULTS.md) |
| Candidates | [../../candidates/CANDIDATES.md](../../candidates/CANDIDATES.md) |
| Dedup | [../03_DEDUP_MAP.md](../03_DEDUP_MAP.md) |

## Critical rules

1. No final Cantina findings from this folder alone.
2. No Hashlock-as-finding without local PoC + dedup.
3. No re-filing Spearbit/Blackthorn without new root cause.
4. Every attack idea: files, functions, state vars, roles, setup, invariant, impact, feasibility.
5. Park user-error, admin-only, weird-ERC20-only, dust-only unless protocol-level impact.
6. H/M requires compiling PoC with demonstrated impact.
7. `src/*` and `test/*` are primary truth; protocolIntent = intent model.
8. hashlock = hypotheses only.
9. audited JSON + findings = dedup.
10. Mark **proven** only after passing PoC.

## Baseline (2026-05-30)

```bash
forge build          # OK
forge test -vvv      # 407 passed, 0 failed
forge test --match-path 'test/asyam/**/*.sol' -vvv       # 56 passed
forge test --match-path 'test/asyamFindings/*.sol' -vvv  # 14 passed
```

## PoC output

- Exploratory: `test/asyam/poc/PoC_<Name>.t.sol`
- Harness: [`test/asyam/Config.t.sol`](../../../../test/asyam/Config.t.sol)
- Promoted regressions: `test/asyamFindings/`

```bash
forge test --match-path 'test/asyam/poc/PoC_<Name>.t.sol' -vvvv
```
