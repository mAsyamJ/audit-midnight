# Protocol Intent Knowledge Base

Date: 2026-05-30

## Purpose

This folder documents **what Morpho Midnight is economically trying to preserve**—protocol intentions, value flows, economic invariants, and intended-vs-bug boundaries. It is **not** a finding backlog and **not** a substitute for coded PoCs.

Use it **before** deeper PoC hunting so agents validate impact against protocol design instead of filing false positives.

## How to use (read order)

1. [00_PROTOCOL_INTENTION_SUMMARY.md](00_PROTOCOL_INTENTION_SUMMARY.md) — one-page mental model + intent table
2. [01_ECONOMIC_MODEL.md](01_ECONOMIC_MODEL.md) — credit/debt units, fees, loss, withdrawable
3. [12_SECURITY_RELEVANT_INVARIANTS.md](12_SECURITY_RELEVANT_INVARIANTS.md) — main PoC handoff
4. [14_PROTOCOL_INTENT_TO_POC_TARGETS.md](14_PROTOCOL_INTENT_TO_POC_TARGETS.md) — concrete test tasks
5. [15_AGENTIC_AUDITOR_PLAYBOOK.md](15_AGENTIC_AUDITOR_PLAYBOOK.md) — workflow, commands, agent routing
6. [11_INTENDED_BEHAVIORS_NOT_BUGS.md](11_INTENDED_BEHAVIORS_NOT_BUGS.md) — false-positive guard (read early if triaging)

Deep dives by domain: `02`–`10`. Machine-readable graph: [protocol_intent_graph.json](protocol_intent_graph.json).

## Connection to audit workflow

| Artifact | Role |
|---|---|
| [../.AGENTROLE.md](../../.AGENTROLE.md) | Agent persona + bootstrap |
| [../../findings/findings.md](../../findings/findings.md) | **Validated** findings only |
| [../POC_RESULTS.md](../POC_RESULTS.md) | Latest PoC outcomes |
| [../../candidates/CANDIDATES.md](../../candidates/CANDIDATES.md) | Candidate status |
| [../03_DEDUP_MAP.md](../03_DEDUP_MAP.md) | Spearbit/Blackthorn dedup |
| [../../MIDNIGHT_AGENTIC_SECURITY_MAP.md](../../MIDNIGHT_AGENTIC_SECURITY_MAP.md) | Security attack-surface map (complementary) |

**Flow:** `protocolIntent` → pick invariant → write `test/asyam/poc/PoC_*.t.sol` → update `POC_RESULTS` + `findings` only if proven.

## Warnings

- **Do not** submit Hashlock AI claims as findings without a local PoC and dedup check.
- **Do not** re-file Spearbit/Blackthorn items without a materially new root cause.
- **Do not** write Cantina submission bodies in this folder.
- Classify every hypothesis: `INTENDED / NOT A BUG` | `SECURITY-RELEVANT INVARIANT BREAK` | `REQUIRES POC / SPEC CONFIRMATION`.

## File index

| File | Topic |
|---|---|
| 00 | Protocol intention summary |
| 01 | Economic model |
| 02 | Actors and incentives |
| 03 | Asset and value flows |
| 04 | Market lifecycle |
| 05 | Offers and ratification |
| 06 | Credit/debt units |
| 07 | Collateral, health, liquidation |
| 08 | Fees and loss socialization |
| 09 | Periphery bundles |
| 10 | Callback, gate, oracle boundaries |
| 11 | Intended behaviors (not bugs) |
| 12 | Security-relevant invariants |
| 13 | Economic attack surfaces (40+) |
| 14 | Protocol intent → PoC targets (20+) |
| 15 | Agentic auditor playbook |
| protocol_intent_graph.json | Structured graph for agents |

## Validation commands (after PoCs)

```bash
forge test --match-path 'test/asyam/**/*.sol' -vvv
forge test --match-path 'test/asyamFindings/*.sol' -vvv
forge test --match-path 'test/asyam/invariant/*.sol' -vvvv
```
