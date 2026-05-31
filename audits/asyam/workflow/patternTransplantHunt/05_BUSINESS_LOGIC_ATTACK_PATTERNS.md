# Business Logic Attack Patterns

These entries are attack-planning prompts. They are not findings and must pass the local proof and dedup gates.

### BLP-001 - Aggregate User Spend Bound Differs From Local Leg Bounds Through MidnightBundles
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `aggregate user spend bound differs from local leg bounds` may be weaker on `MidnightBundles` than users reasonably rely on.
- Exploit idea: Compose `MidnightBundles` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-002 - Maker Offer Family Means More Than Its Locally Checked Leaf Through take
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `maker offer family means more than its locally checked leaf` may be weaker on `take` than users reasonably rely on.
- Exploit idea: Compose `take` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-003 - Lender Claim Changes Economic Context Before Peers Settle Through withdraw
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `lender claim changes economic context before peers settle` may be weaker on `withdraw` than users reasonably rely on.
- Exploit idea: Compose `withdraw` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-004 - Borrower Exit Expectation Diverges From Lazy Health Update Through withdrawCollateral
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `borrower exit expectation diverges from lazy health update` may be weaker on `withdrawCollateral` than users reasonably rely on.
- Exploit idea: Compose `withdrawCollateral` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-005 - Liquidator Choice Changes Social Loss Rather Than Only Incentive Through liquidate
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `liquidator choice changes social loss rather than only incentive` may be weaker on `liquidate` than users reasonably rely on.
- Exploit idea: Compose `liquidate` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-006 - Fee Schedule Context Changes Between Route Construction And Settlement Through claimContinuousFee
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `fee schedule context changes between route construction and settlement` may be weaker on `claimContinuousFee` than users reasonably rely on.
- Exploit idea: Compose `claimContinuousFee` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-007 - Authorization Capability Is Valid Locally But Broader Economically Through EcrecoverAuthorizer
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `authorization capability is valid locally but broader economically` may be weaker on `EcrecoverAuthorizer` than users reasonably rely on.
- Exploit idea: Compose `EcrecoverAuthorizer` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-008 - Permissionless Market Quality Leaks Into Another Actor Route Through createMarket
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `permissionless market quality leaks into another actor route` may be weaker on `createMarket` than users reasonably rely on.
- Exploit idea: Compose `createMarket` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-009 - Off-Chain Route Assumes Escrow That Core Does Not Provide Through flashLoan
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `off-chain route assumes escrow that core does not provide` may be weaker on `flashLoan` than users reasonably rely on.
- Exploit idea: Compose `flashLoan` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-010 - Maturity Settlement Expectation Differs Across Entrypoints Through multicall
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `maturity settlement expectation differs across entrypoints` may be weaker on `multicall` than users reasonably rely on.
- Exploit idea: Compose `multicall` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-011 - Aggregate User Spend Bound Differs From Local Leg Bounds Through MidnightBundles
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `aggregate user spend bound differs from local leg bounds` may be weaker on `MidnightBundles` than users reasonably rely on.
- Exploit idea: Compose `MidnightBundles` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-012 - Maker Offer Family Means More Than Its Locally Checked Leaf Through take
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `maker offer family means more than its locally checked leaf` may be weaker on `take` than users reasonably rely on.
- Exploit idea: Compose `take` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-013 - Lender Claim Changes Economic Context Before Peers Settle Through withdraw
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `lender claim changes economic context before peers settle` may be weaker on `withdraw` than users reasonably rely on.
- Exploit idea: Compose `withdraw` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-014 - Borrower Exit Expectation Diverges From Lazy Health Update Through withdrawCollateral
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `borrower exit expectation diverges from lazy health update` may be weaker on `withdrawCollateral` than users reasonably rely on.
- Exploit idea: Compose `withdrawCollateral` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-015 - Liquidator Choice Changes Social Loss Rather Than Only Incentive Through liquidate
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `liquidator choice changes social loss rather than only incentive` may be weaker on `liquidate` than users reasonably rely on.
- Exploit idea: Compose `liquidate` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-016 - Fee Schedule Context Changes Between Route Construction And Settlement Through claimContinuousFee
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `fee schedule context changes between route construction and settlement` may be weaker on `claimContinuousFee` than users reasonably rely on.
- Exploit idea: Compose `claimContinuousFee` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-017 - Authorization Capability Is Valid Locally But Broader Economically Through EcrecoverAuthorizer
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `authorization capability is valid locally but broader economically` may be weaker on `EcrecoverAuthorizer` than users reasonably rely on.
- Exploit idea: Compose `EcrecoverAuthorizer` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-018 - Permissionless Market Quality Leaks Into Another Actor Route Through createMarket
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `permissionless market quality leaks into another actor route` may be weaker on `createMarket` than users reasonably rely on.
- Exploit idea: Compose `createMarket` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-019 - Off-Chain Route Assumes Escrow That Core Does Not Provide Through flashLoan
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `off-chain route assumes escrow that core does not provide` may be weaker on `flashLoan` than users reasonably rely on.
- Exploit idea: Compose `flashLoan` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-020 - Maturity Settlement Expectation Differs Across Entrypoints Through multicall
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `maturity settlement expectation differs across entrypoints` may be weaker on `multicall` than users reasonably rely on.
- Exploit idea: Compose `multicall` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-021 - Aggregate User Spend Bound Differs From Local Leg Bounds Through MidnightBundles
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `aggregate user spend bound differs from local leg bounds` may be weaker on `MidnightBundles` than users reasonably rely on.
- Exploit idea: Compose `MidnightBundles` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-022 - Maker Offer Family Means More Than Its Locally Checked Leaf Through take
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `maker offer family means more than its locally checked leaf` may be weaker on `take` than users reasonably rely on.
- Exploit idea: Compose `take` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-023 - Lender Claim Changes Economic Context Before Peers Settle Through withdraw
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `lender claim changes economic context before peers settle` may be weaker on `withdraw` than users reasonably rely on.
- Exploit idea: Compose `withdraw` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-024 - Borrower Exit Expectation Diverges From Lazy Health Update Through withdrawCollateral
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `borrower exit expectation diverges from lazy health update` may be weaker on `withdrawCollateral` than users reasonably rely on.
- Exploit idea: Compose `withdrawCollateral` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-025 - Liquidator Choice Changes Social Loss Rather Than Only Incentive Through liquidate
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `liquidator choice changes social loss rather than only incentive` may be weaker on `liquidate` than users reasonably rely on.
- Exploit idea: Compose `liquidate` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-026 - Fee Schedule Context Changes Between Route Construction And Settlement Through claimContinuousFee
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `fee schedule context changes between route construction and settlement` may be weaker on `claimContinuousFee` than users reasonably rely on.
- Exploit idea: Compose `claimContinuousFee` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-027 - Authorization Capability Is Valid Locally But Broader Economically Through EcrecoverAuthorizer
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `authorization capability is valid locally but broader economically` may be weaker on `EcrecoverAuthorizer` than users reasonably rely on.
- Exploit idea: Compose `EcrecoverAuthorizer` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-028 - Permissionless Market Quality Leaks Into Another Actor Route Through createMarket
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `permissionless market quality leaks into another actor route` may be weaker on `createMarket` than users reasonably rely on.
- Exploit idea: Compose `createMarket` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-029 - Off-Chain Route Assumes Escrow That Core Does Not Provide Through flashLoan
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `off-chain route assumes escrow that core does not provide` may be weaker on `flashLoan` than users reasonably rely on.
- Exploit idea: Compose `flashLoan` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### BLP-030 - Maturity Settlement Expectation Differs Across Entrypoints Through multicall
- Status: `hypothesis_only`.
- Contradiction: Protocol intent around `maturity settlement expectation differs across entrypoints` may be weaker on `multicall` than users reasonably rely on.
- Exploit idea: Compose `multicall` with an adjacent state transition and compare the user's aggregate balance delta to the explicit local bounds.
- Expected proof: A local sequence shows non-dust harm without relying on admin compromise, weird tokens, or a knowingly malicious market.
- Likely disproof: The final state rolls back, aggregate bounds hold, or the user explicitly selected the risky context.
- Severity if true: Medium or High only when a realistic actor can impose meaningful third-party loss.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.
