# Low / Gas / Informational Decision Matrix

Date: 2026-05-31

| ID | Title | Severity ceiling | Submit? | Why not H/M | PoC status | Duplicate risk | Final action |
|---|---|---|---|---|---|---|---|
| L-01 | ECDSA high-s signature malleability | Low | Yes | Nonces and roots still prevent replay-based fund loss | Proven | Low | `SUBMIT_LOW` |
| P3-02 | CVL market-ID summary aliasing | Informational | Yes | Formal assurance gap only; runtime IDs remain distinct | Proven model mismatch | Low | `SUBMIT_INFORMATIONAL` |
| P3-01 | `roleSetter` zero-address bricking | Low at most | Hold | Admin self-DoS only | Proven | Scope risk | `HOLD_WEAK` |
| L-02 | Tiny repayment invalidates stale exact liquidation | Gas / Informational, Low at most | Hold | Adaptive liquidation succeeds with equivalent recovery | Proven gas grief | Medium / high | `MAYBE_DUPLICATE_DO_NOT_SUBMIT_UNLESS_REVIEWED` |
| L-03 | RCF top-up invalidates stale full-close liquidation | Informational | No | Adaptive RCF-sized liquidation restores health | Proven policy branch | High | `DO_NOT_SUBMIT_INTENDED` |
| AUTH-RESTORE | Unused signed grant restores revoked operator | Informational at most | No | User created the still-valid signed capability | Proven trace | High | `DO_NOT_SUBMIT_INTENDED` |
| HPH-POC-003 | Self-liquidation callback capture | None | No | Callback transitions remain fully charged | Disproven | Medium | `DO_NOT_SUBMIT_INTENDED` |
| AP-CLOSED | Attack-plan runtime queue | None | No | No novel economic break survived | Disproven / duplicate / invalid | High | `DO_NOT_SUBMIT_INVALID` |
| COMP-CLOSED | Composition queue | None | No | No non-dust composition impact survived | Disproven / intended / dust-only | High | `DO_NOT_SUBMIT_INVALID` |
| BB-CLOSED | Blackbox queue | None | No | No executable economic break survived | Disproven / duplicate / hypothesis-only | High | `DO_NOT_SUBMIT_INVALID` |
| PT-BACKLOG | Pattern-transplant backlog | None | No | Planning hypothesis without promoted proof | Unvalidated hypothesis | Unknown | `DO_NOT_SUBMIT_INVALID` |
| HPH-BACKLOG | Historical backlog excluding 001-003 | None | No | Planning hypothesis without promoted proof | Unvalidated hypothesis | Unknown | `DO_NOT_SUBMIT_INVALID` |
| HASHLOCK | Hashlock queues excluding L-01 evidence | None | No | AI hypotheses do not satisfy the finding gate | Mixed | High | `DO_NOT_SUBMIT_INVALID` |
| AUDITED | Spearbit / Blackthorn findings | None | No | Prior audited corpus | Known | Certain | `DO_NOT_SUBMIT_DUPLICATE` |

## Classification Rule

The matrix intentionally distinguishes a packet that is formatted from a packet
that is recommended for manual submission. Formatting does not override scope,
deduplication, or intended-behavior review.

