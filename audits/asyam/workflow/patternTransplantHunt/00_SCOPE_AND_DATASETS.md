# Scope And Datasets

## Authorized Local-Only Scope

All research remains inside this repository, local Foundry tests, and local mocks. Do not interact with live third-party systems, scan external targets, create generalized attack tooling, or write final Cantina findings during this pass.

## Current Evidence Gate

- Historical examples are mechanism prompts, not Midnight evidence.
- A candidate becomes submission material only after source reasoning, dedup, a compiling Foundry PoC, realistic actor preconditions, and non-dust impact.
- Hashlock claims remain untrusted hypotheses.
- Prior audited JSON reports and existing findings are known-risk sources, not new submissions.

## Datasets And Sources

| Source | URL or local path | Classification | Safe use |
| --- | --- | --- | --- |
| Solodit | https://solodit.cyfrin.io/ | audit-report finding database | Search historical report mechanisms; never treat search results as proof. |
| Code4rena reports | https://code4rena.com/reports | audit-report finding database | Mine public contest report root causes and mitigations. |
| Sherlock public audits | https://docs.sherlock.xyz/audits/protocols | audit-report index | Use public report repositories when available. |
| Cantina competitions | https://cantina.xyz/competitions | public competition index | Use public competition material only. |
| Immunefi blog | https://immunefi.com/blog/ | postmortem source | Extract economic exploit mechanisms from published incident analyses. |
| DeFiHackLabs | https://github.com/SunWeb3Sec/DeFiHackLabs | exploit PoC source | Translate Foundry reproduction patterns into local-only tests. |
| SWC Registry | https://swcregistry.io/ | legacy vulnerability taxonomy | Use as terminology only; the registry notes that it is no longer actively maintained. |
| SmartBugs | https://github.com/smartbugs/smartbugs | analysis benchmark framework | Use weakness classes as static-analysis prompts. |
| SmartBugs Curated | https://github.com/smartbugs/smartbugs-curated | labelled benchmark dataset | Use annotated examples as pattern prompts. |
| DAppSCAN | https://github.com/InPlusLab/DAppSCAN | academic labelled dataset | Use project-level weakness labels as hypothesis seeds. |
| AutoMESC | https://arxiv.org/abs/2308.10227 | academic vulnerability-fix dataset | Use paper metadata and accessible samples; do not assume dataset availability. |
| ScrawlD | https://github.com/sujeetc/ScrawlD | academic labelled dataset | Use labels as prompts for contract-specific reasoning. |
| ReEVMBench | https://arxiv.org/abs/2505.18753 | audit-agent benchmark | Use benchmark categories as coverage prompts. |
| Trail of Bits Building Secure Contracts | https://github.com/crytic/building-secure-contracts | checklist and methodology | Use audit methodology and invariant design guidance. |
| Local Cyfrin-derived skills | ../../../.agents/skills/ | local checklist and methodology | Apply the lending, oracle, signature, precision, and access-control checklists. |
| Local Slither output | ../../slither.log | static-analysis hypothesis source | Use warnings as cues only; require source reasoning and a local PoC. |

## Closed, Invalid, And Duplicate Categories

| Class | Status | Rule |
| --- | --- | --- |
| zero oracle prices | `duplicate` | Prior audited issue; only revisit if a non-consenting route crosses the trust boundary. |
| default fee initialization and touchMarket fee race | `duplicate` | Previously audited fee-initialization class. |
| fee rounding and continuous-fee dust | `duplicate` | Dust alone is not a submission; require a later non-dust branch flip. |
| maturity-edge forced debt | `duplicate` | Previously audited maturity-edge class. |
| grouped offer cap overfill | `duplicate` | Previously audited consumed-cap class. |
| terminal lossFactor fresh-lender slash | `duplicate` | Previously audited lossFactor terminal-slash class. |
| obligation or market ID hardfork replay | `duplicate` | Previously audited ID replay class. |
| ratifier delegated authority scope | `duplicate` | Previously audited delegated scope semantics. |
| callback actor binding and zero-unit callback replay | `duplicate` | Previously audited callback binding class. |
| liquidation bad-debt socialization | `duplicate` | Previously audited direct bad-debt realization class. |
| helper and core TakeAmountsLib mismatch | `duplicate` | Previously audited helper/core mismatch class. |
| direct callback reentrancy | `closed-disproven` | Prior local PoCs preserved custody and health invariants. |
| direct flash-loan repayment bypass | `closed-disproven` | Prior local PoCs preserved repayment. |
| direct reduceOnly bypass | `closed-disproven` | Prior local validation disproved the concrete edge. |
| direct liquidation over-seize | `closed-disproven` | Prior local validation preserved seizure bounds. |
| direct post-maturity liquidation | `closed-disproven` | Prior local validation preserved lifecycle behavior. |
| direct collateral bitmap desync | `closed-disproven` | Prior local validation preserved bitmap coupling. |
| direct withdrawable overstatement | `closed-disproven` | Prior local validation preserved backing. |
| direct pendingFee and lossFactor desync | `closed-disproven` | Prior local validation preserved accounting. |
| direct canceled-root reuse | `closed-disproven` | Prior local validation preserved root cancellation. |
| direct delegate grief | `closed-or-accepted` | Require third-party harm beyond delegated authority. |
| direct bundle temporary-balance leakage | `closed-disproven` | Prior local validation preserved balance ownership. |
| direct exact-fill and helper-revert semantics | `closed-disproven` | Prior local validation covered concrete skip and revert paths. |
| direct Permit2 victim drain | `closed-disproven` | Require a new semantic capability path, not user-signed transfer authority. |
| chosen-market malicious oracle or gate | `scope-invalid-alone` | Require an involuntary cross-market or route consent boundary. |
| same-token loan and collateral self-loop | `closed-disproven` | Prior concrete repay-from-collateral path was disproved. |
| roleSetter zero brick | `known` | Existing P3-01. |
| signature malleability | `known` | Existing L-01. |
| formal CVL market-ID aliasing | `known-formal-only` | Existing P3-02; runtime refiling requires an executable economic path. |
| unused user-signed authorization restoration | `duplicate-risk-accepted` | Permit-style restoration depends on a user-created signature. |
