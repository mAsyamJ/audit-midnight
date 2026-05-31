# Agentic Auditor Playbook

Date: 2026-05-30

## Audit order

1. Read [README.md](README.md) → [00_PROTOCOL_INTENTION_SUMMARY.md](00_PROTOCOL_INTENTION_SUMMARY.md)
2. Read [12_SECURITY_RELEVANT_INVARIANTS.md](12_SECURITY_RELEVANT_INVARIANTS.md) + [11_INTENDED_BEHAVIORS_NOT_BUGS.md](11_INTENDED_BEHAVIORS_NOT_BUGS.md)
3. Read [../../.AGENTROLE.md](../../.AGENTROLE.md) + [../03_DEDUP_MAP.md](../03_DEDUP_MAP.md)
4. Domain deep dive as needed (`01`–`10`)
5. Pick target from [14_PROTOCOL_INTENT_TO_POC_TARGETS.md](14_PROTOCOL_INTENT_TO_POC_TARGETS.md)
6. Implement PoC in `test/asyam/poc/`
7. Update [../POC_RESULTS.md](../POC_RESULTS.md), [../../candidates/CANDIDATES.md](../../candidates/CANDIDATES.md), [../../findings/findings.md](../../findings/findings.md) only if proven

**Code audit order** (from [strategyAndbundleAudit.md](../../strategyAndbundleAudit.md)):

```text
Midnight.sol (take → liquidate → withdraw/repay → collateral → updatePosition → fees → flashLoan)
→ ratifiers → callbacks/trust → MidnightBundles → libraries → certora gaps → tests
```

## Before writing a PoC

- [ ] Behavior contradicts [00](00_PROTOCOL_INTENTION_SUMMARY.md) or an invariant in [12](12_SECURITY_RELEVANT_INVARIANTS.md)?
- [ ] Listed as INTENDED in [11](11_INTENDED_BEHAVIORS_NOT_BUGS.md)?
- [ ] Duplicate in [../03_DEDUP_MAP.md](../03_DEDUP_MAP.md)?
- [ ] Hashlock-only without local PoC?
- [ ] Concrete impact (fund loss, permanent DoS, accounting break)?

## Intent → invariant → test

1. State protocol intention in one sentence.
2. Map to `INV-XXX` or define new invariant.
3. Write Foundry test with `Config.t.sol` / `BaseTest` setup.
4. Assert concrete balance or state inequality (not `vm.expectRevert` alone unless DoS claim).

## Severity validation (Cantina)

- Based on **impact** and **likelihood**.
- High/Medium generally need **coded PoC**.
- Weird-token, dust, admin footgun, user error → usually Low unless protocol-level impact.
- See [../../InfoCantinaPoCRules.md](../../InfoCantinaPoCRules.md).

## Cantina finding workflow

Only after PoC passes:

1. `findings/cantina-*.md` with required sections
2. Index in [../../findings/findings.md](../../findings/findings.md)
3. Never copy Hashlock text as finding body

## Dedup workflow

1. Search [../03_DEDUP_MAP.md](../03_DEDUP_MAP.md) keywords
2. Check [../../audited/*.json](../../audited/)
3. If same root cause → mark duplicate in candidates; stop

## Update candidates

On close/prove: edit [../../candidates/CANDIDATES.md](../../candidates/CANDIDATES.md) + [../POC_RESULTS.md](../POC_RESULTS.md) + snapshot in `.AGENTROLE.md`.

## Commands

```bash
forge build
forge test -vvv

forge test --match-path 'test/asyam/poc/PoC_<Name>.t.sol' -vvvv
forge test --match-path 'test/asyam/**/*.sol' -vvv
forge test --match-path 'test/asyamFindings/*.sol' -vvv
forge test --match-path 'test/asyam/invariant/*.sol' -vvvv
```

## Agent routing

| Agent | Focus | Primary files |
|---|---|---|
| Accounting | `totalUnits`, withdrawable, credit/debt | `Midnight.sol`, `Midnight.spec` |
| Liquidation | health, bad debt, LIF | `liquidate`, `Healthiness.spec` |
| Ratifier/signature | offers, Merkle, EIP-712 | `ratifiers/*`, L-01 class |
| Periphery/bundle | router, exact fill | `MidnightBundles.sol`, libs |
| Oracle/gate/callback | trust boundaries | `10_*`, callbacks |
| Dedup/severity | false positives | `03_DEDUP`, `11_INTENDED` |
| PoC builder | Foundry tests | `test/asyam/poc/` |
| Reviewer | impact + novelty | findings gate |

## Machine-readable graph

Use [protocol_intent_graph.json](protocol_intent_graph.json) for automated agent tooling (invariant IDs, PoC links).
