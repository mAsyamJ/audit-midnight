# Execution Plan

Date: 2026-05-30

## Phase 1 — Orient (day 0)

1. `forge build && forge test -vvv` — confirm 407/407
2. Read [09_DISPROOF_AND_FALSE_POSITIVE_FILTER.md](09_DISPROOF_AND_FALSE_POSITIVE_FILTER.md)
3. Read [06_HIGH_VALUE_POC_QUEUE.md](06_HIGH_VALUE_POC_QUEUE.md) open section
4. Read [../protocolIntent/12_SECURITY_RELEVANT_INVARIANTS.md](../protocolIntent/12_SECURITY_RELEVANT_INVARIANTS.md)

## Phase 2 — Implement open AP targets (priority order)

| Order | AP | Suggested file | Stop condition |
|---|---|---|---|
| 1 | AP-019 | `PoC_FlashLoanReentrancy.t.sol` | **closed-disproven** (2026-05-30) |
| 2 | AP-005 | `PoC_LiquidationOverSeize.t.sol` | **closed-disproven** |
| 3 | AP-011 | `PoC_CanceledRootReuse.t.sol` | **closed-disproven** |
| 4 | AP-006 | `PoC_PostMaturityLiquidation.t.sol` | **closed-disproven** |
| 5 | AP-008 | `PoC_LossFactorOverslash.t.sol` | **closed-disproven** |
| 6 | AP-004 | `PoC_LiquidationSolventBadDebt.t.sol` | **closed-disproven** |
| 7 | AP-015 | `PoC_BundleExactFillAlignment.t.sol` | **closed-disproven** |
| 8 | AP-018 | `PoC_EnterGateForcedDebt.t.sol` | **closed-disproven** |
| 9 | AP-016 | `PoC_BundleHelperRevertSemantics.t.sol` | **closed-invalid (NatSpec)** |
| 10 | AP-026 | `PoC_SellCallbackComposition.t.sol` | **closed-partial** |

For each:
- Extend `Config.t.sol` actors
- Assert balances + storage (not revert-only unless DoS claim)
- Run `forge test --match-path 'test/asyam/poc/PoC_<Name>.t.sol' -vvvv`

## Phase 3 — Classify outcome

| Result | Action |
|---|---|
| Impact proven | Cantina body in `findings/`, update `findings.md`, `POC_RESULTS.md` |
| Disproven | Mark AP closed in this file + `candidates/CANDIDATES.md` |
| Invalid / duplicate | Link dedup; do not file |
| Promoted regression | Move stable test to `test/asyamFindings/` |

## Phase 4 — Do not re-hunt

Skip closed AP-001 through AP-006, AP-008, AP-011, AP-014–AP-015, AP-017–AP-019, AP-020–AP-025, AP-018 unless **new root cause**.

## Agent routing

| Agent | Focus |
|---|---|
| Accounting | AP-008, AP-009, invariants |
| Liquidation | AP-004, AP-005, AP-006 |
| Callback | AP-026 (AP-019 closed) |
| Periphery | AP-015, AP-016 |
| Ratifier | AP-011, AP-013 |
| Dedup | `09`, `03_DEDUP_MAP` |
| PoC builder | `test/asyam/poc/` |
| Reviewer | severity + novelty |

## Commands

```bash
forge build
forge test -vvv
forge test --match-path 'test/asyam/**/*.sol' -vvv
forge test --match-path 'test/asyam/poc/PoC_<Name>.t.sol' -vvvv
forge test --match-path 'test/asyam/invariant/*.sol' -vvvv
```

## First command (baseline regression)

```bash
forge test --match-path 'test/asyam/poc/PoC_FlashLoanReentrancy.t.sol' -vvvv
```

Attack-plan queue fully closed (including **AP-010** harness regression). Further work is net-new composition outside closed classes only.
