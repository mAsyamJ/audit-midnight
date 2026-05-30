# Workflow Index — Morpho Midnight Audit

**Agent authority:** [../.AGENTROLE.md](../.AGENTROLE.md)

Start every session with the bootstrap order in `.AGENTROLE.md`, then use this directory for audit state and evidence.

---

## Quick links

| Resource | Path |
|---|---|
| Validated findings | [../findings/findings.md](../findings/findings.md) |
| Candidate backlog | [../candidates/CANDIDATES.md](../candidates/CANDIDATES.md) |
| Cantina rules | [../InfoCantinaPoCRules.md](../InfoCantinaPoCRules.md) |
| Architecture map | [../MIDNIGHT_AGENTIC_SECURITY_MAP.md](../MIDNIGHT_AGENTIC_SECURITY_MAP.md) |

---

## Numbered workflow files (read order after bootstrap)

| File | Purpose |
|---|---|
| [BASELINE_LOG.md](BASELINE_LOG.md) | Build/test gate and baseline log pointers |
| [00_CONTEXT_MAP.md](00_CONTEXT_MAP.md) | Protocol scope, trust boundaries, entry points |
| [01_TEST_COVERAGE_GAP_MAP.md](01_TEST_COVERAGE_GAP_MAP.md) | Untested or weakly tested surfaces |
| [02_HASHLOCK_VALIDATION.md](02_HASHLOCK_VALIDATION.md) | Hashlock AI hypothesis triage |
| [03_DEDUP_MAP.md](03_DEDUP_MAP.md) | Spearbit/Blackthorn dedup — check before filing |
| [04_PROTOCOL_TEST_INTENT_MAP.md](04_PROTOCOL_TEST_INTENT_MAP.md) | What protocol tests already prove |
| [05_DEEP_VALIDATION_C12_C26_C29_C31.md](05_DEEP_VALIDATION_C12_C26_C29_C31.md) | Priority live-queue validation details |
| [06_FORMAL_MODEL_GAP_REVIEW.md](06_FORMAL_MODEL_GAP_REVIEW.md) | CVL model boundaries and proven summary mismatch |
| [POC_RESULTS.md](POC_RESULTS.md) | Proven/disproven PoC outcomes |
| [CANDIDATES.md](CANDIDATES.md) | Short pointer to full candidate queue |

Baseline artifacts: `baseline_build.log`, `baseline_tests.log`.

---

## Validation commands

```bash
forge test --match-path 'test/asyam/**/*.sol' -vvv      # primary harness
forge test --match-path 'test/asyamFindings/*.sol' -vvv # legacy + live-queue
forge test --match-path 'test/asyam/invariant/*.sol' -vvvv
```

See [../.AGENTROLE.md](../.AGENTROLE.md) for PoC layout and finding output rules.
