# Submission-Ready Packets

Date: 2026-05-31

Only the following packets are recommended for manual Cantina submission.

## L-01 - ECDSA high-s signature malleability

- Final severity: Low.
- File: `audits/asyam/findings/cantina-L01-signature-malleability.md`
- PoC: `test/asyamFindings/PoC_SignatureMalleability.t.sol`
- Command:
  `forge test --match-path test/asyamFindings/PoC_SignatureMalleability.t.sol -vvv`
- Summary: Raw `ecrecover` accepts byte-distinct high-s variants in both the
  authorizer and ratifier.
- Strongest impact: Breaks canonical signature assumptions used by integrations
  and monitoring.
- Limitation: Nonces and roots still block replay-based fund loss.
- Duplicate risk: Hashlock described the hypothesis, but no matching accepted
  Spearbit or Blackthorn issue exists in the local corpus.
- Recommendation: Enforce low-s and valid `v`, preferably through a maintained
  ECDSA library.
- Why useful: Aligns the protocol with canonical ECDSA handling and removes an
  avoidable cross-system inconsistency.

## P3-02 - CVL market-ID summaries alias production-distinct markets

- Final severity: Informational / P3.
- File: `audits/asyam/findings/cantina-P3-02-solvency-spec-market-id-aliasing.md`
- PoC: `test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol`
- Command:
  `forge test --match-path test/asyamFindings/PoC_SolvencySpecMarketIdAliasing.t.sol -vvvv`
- Summary: CVL summaries collapse production-distinct market configurations,
  permitting valid traces to be pruned or combined.
- Strongest impact: Existing formal proofs do not establish their advertised
  breadth across supported markets.
- Limitation: Runtime `IdLib.toId` remains distinct; no production fund-loss
  exploit is claimed.
- Duplicate risk: None found in the local audited corpus.
- Recommendation: Key summaries by the complete market configuration and rerun
  proofs with sanity checks.
- Why useful: Removes a blind spot from the protocol assurance layer.

