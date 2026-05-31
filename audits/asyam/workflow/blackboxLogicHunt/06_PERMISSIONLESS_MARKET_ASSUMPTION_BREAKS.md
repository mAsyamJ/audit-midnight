# Permissionless Market Assumption Breaks

Date: 2026-05-31

Permissionless market creation is intended. Each row asks whether risk can cross into a user who did not select the bad
market.

| ID | Bad market parameter | Creator | Indirectly affected user | Potential crossing surface | Consent boundary / validity hurdle | PoC design |
|---|---|---|---|---|---|---|
| PM-001 | Malicious oracle reverts | Attacker | Delegated borrower | Bundler route selected by relayer | Broad route authority may be consent | Route into market then test freeze |
| PM-002 | Malicious oracle returns zero | Attacker | Lender | Ratified offer embedded in route | Maker and taker still see full market hash | Signed-intent audit |
| PM-003 | Liquidator gate blocks all | Attacker | Route-funded lender | Bad market sell route | Lender chose offer market unless route abstraction hides it | Periphery consent PoC |
| PM-004 | Enter gate selectively allows actor | Attacker | Borrower | Fallback offer | Route args do not separately bind market, but all offers checked same ID | Route market test |
| PM-005 | Same loan and collateral token | Attacker | Delegated user | `repayAndWithdrawCollateral` | Concrete self-loop closed | Aggregate liability variant |
| PM-006 | Maturity already passed | Attacker | Borrower | Route fallback | Core blocks debt increase post maturity | Route skip matrix |
| PM-007 | Maturity one second away | Attacker | Borrower | Off-chain quote | Maturity-edge prior finding duplicate-risk | Adjacent route bound only |
| PM-008 | Extreme `rcfThreshold` | Attacker | Lender | Liquidation incentives | Participants can inspect market ID | Need indirect routing proof |
| PM-009 | LLTV = WAD | Attacker | Lender | Route-selected market | Documented special market type | Consent-only unless hidden |
| PM-010 | High max LIF tier | Attacker | Borrower | Multi-collateral liquidation | Param encoded in market | Require route-hidden exposure |
| PM-011 | Two collateral tokens with asymmetric liveness | Attacker | Borrower | Delegated collateral supply route | Borrower may not select supplied token | Supply authorization scope PoC |
| PM-012 | Sixteen active collateral tokens | Attacker | Borrower | Authorized supplier | Broad authorization may permit poisoning | Distinguish documented collateral-poisoning check |
| PM-013 | Seventeenth collateral supply | Attacker | Route caller | Bundle prior pulls | Atomic revert likely | Bundle atomicity test |
| PM-014 | Unusual tick spacing snapshot | Attacker | Taker | Helper route quote | Tick setter only decreases after creation | Quote-settlement matrix |
| PM-015 | Default fees snapshot before later fee defaults | Attacker | Lender | New market creation | Spearbit duplicate | Exclude |
| PM-016 | Similar market differing only in gate | Attacker | Indexer user | Event/UI identity | Full event includes market | Replay full tuple |
| PM-017 | Similar market differing only in threshold | Attacker | Formal verification | CVL summary | P3-02 formal-only | Runtime isolate, document only |
| PM-018 | Cross-market same loan token | Attacker | Lenders elsewhere | Global settlement-fee bucket | Shared custody is protocol-global | Aggregate backing PoC |
| PM-019 | Collateral token equals token-global fee token | Attacker | Other-market lender | Shared core ERC20 custody | Solvency invariant should include collateral sum | Aggregate token invariant |
| PM-020 | Malformed external gate behavior | Attacker | Route user | Gate external call | Chosen-market liveness unless indirect | Non-consent route PoC |

## Valid-Issue Gate

A valid permissionless-market issue must show an actor who did not select, sign, authorize, or knowingly route through
the bad market losing funds or becoming materially frozen because another component relied on market quality.
