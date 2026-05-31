# Hold and Do-Not-Submit Archive

Date: 2026-05-31

## Hold for Manual Judgment

### P3-01 - `roleSetter` zero-address bricking

- Why held: Real and locally proven, but only the privileged role setter can
  trigger it. This is an administrative operational footgun.
- Proof: `test/asyamFindings/PoC_RoleSetterBricking.t.sol`.
- Revive for submission only if: Cantina explicitly accepts admin
  misconfiguration lows.

### L-02 - Tiny repayment liquidation gas grief

- Why held: Real repairable gas grief, but it overlaps Spearbit's acknowledged
  front-run transaction-invalidation class.
- Proof: `test/asyam/poc/historical/PoC_Hist_TinyRepayLiquidationGrief.t.sol`.
- Revive for submission only if: Human dedup review accepts the
  liquidation-specific entrypoint and mitigation as materially distinct.

## Do Not Submit

### L-03 - RCF top-up liquidation gas grief

- Why rejected: The 2 wei top-up exercises documented RCF policy. Adaptive
  liquidation succeeds, restores health, and leaves `lossFactor == 0`.
- Proof: `test/asyam/poc/historical/PoC_Hist_RcfTopUpLiquidationGrief.t.sol`.
- Revive only if: A follow-up PoC demonstrates non-dust lender loss or frozen
  recoverability after adaptive liquidation.

### HPH-POC-003 - Self-liquidation callback capture

- Why rejected: Callback actions remain fully charged. The attacker retains only
  the intended bounded liquidation incentive.
- Proof:
  `test/asyam/poc/historical/PoC_Hist_SelfLiquidationCallbackCapture.t.sol`.
- Revive only if: A distinct callback composition demonstrates private gain and
  externalized non-dust loss.

### AUTH-RESTORE - Unused user-signed grant restores a revoked operator

- Why rejected: The user created a still-valid signed authorization. This is
  accepted permit-style semantics and adjacent to prior revocation-delay
  coverage.
- Proof: Blackbox authorization-intent probe.
- Revive only if: An unrelated actor can restore authority without a valid
  user-created capability.

### Closed Runtime Queues

- Attack-plan AP-001..AP-026: disproven, duplicate, intended, covered, or formal
  only.
- Composition COMP-001..COMP-030: no non-dust novel economic break survived.
- Blackbox BB-POC-001..BB-POC-020: implemented slices closed; remaining backlog
  is hypothesis-only.
- Pattern PT-POC-001..PT-POC-025: planning hypotheses only.
- Historical HPH-POC-004..HPH-POC-025: planning hypotheses only.
- Hashlock reports: hypothesis input only unless independently proven and
  deduplicated.
- Spearbit / Blackthorn issues: prior audited corpus; do not resubmit.

