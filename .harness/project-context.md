# Midnight Audit Project Context

## Objective

Run structured security research and formal verification on Morpho Midnight without altering target protocol logic unless explicitly requested.

## Runtime and Tooling

- Solidity + Foundry (`forge`)
- Certora specs in `certora/`
- Audit artifacts under `audits/`

## Guardrails

- Default to read-first workflows during audit.
- Treat reproducibility as first-class: every finding should map to concrete files, traces, or rule outputs.
- Keep local harness changes scoped to orchestration, indexing, and workflow metadata.
