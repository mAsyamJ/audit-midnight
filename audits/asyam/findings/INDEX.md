# Audit Finding Index

Date: 2026-05-31

## Submit-Ready Low/Gas/Informational

| ID | Finding | Status |
|---|---|---|
| L-01 | [ECDSA signature malleability](cantina-L01-signature-malleability.md) | Submit-ready Low |
| P3-02 | [CVL market-ID aliasing](cantina-P3-02-solvency-spec-market-id-aliasing.md) | Submit-ready Informational / P3 |

## Hold / Do Not Submit

These packets remain available as audit evidence but are not recommended for
submission without the stated manual review.

| ID | Finding | Status | Severity ceiling |
|---|---|---|---|
| P3-01 | [`roleSetter` zero-address bricking](cantina-P3-01-role-setter-bricking.md) | Hold: admin-only scope judgment | Low at most |
| L-02 | [Tiny repayment liquidation gas grief](cantina-L02-tiny-repay-liquidation-gas-grief.md) | Hold: manual duplicate review | Gas / Informational, Low at most |
| L-03 | [RCF top-up liquidation gas grief](cantina-L03-rcf-topup-liquidation-gas-grief.md) | Do not submit: intended RCF policy | Informational |

## Disproven H/M Candidates

The attack-plan, composition, blackbox, and historical escalation queues did
not demonstrate a new deduplicated High or Medium impact. See
[submissionReview/05_DO_NOT_SUBMIT_ARCHIVE.md](../submissionReview/05_DO_NOT_SUBMIT_ARCHIVE.md).

## Commands to Reproduce

See
[submissionReview/07_PROOF_COMMANDS_AND_TEST_STATUS.md](../submissionReview/07_PROOF_COMMANDS_AND_TEST_STATUS.md).
