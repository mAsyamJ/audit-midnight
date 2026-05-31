# Auth Signature And Intent Patterns

These entries are attack-planning prompts. They are not findings and must pass the local proof and dedup gates.

### ASI-001 - Signed Grant Survives User Mental-Model Revoke Through setIsAuthorized
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `signed grant survives user mental-model revoke` as accepted unless the `setIsAuthorized` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-002 - Signature Authorizes A Wider Economic Route Through EcrecoverAuthorizer
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `signature authorizes a wider economic route` as accepted unless the `EcrecoverAuthorizer` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-003 - Delegate Combines Harmless Capabilities Through EcrecoverRatifier
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `delegate combines harmless capabilities` as accepted unless the `EcrecoverRatifier` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-004 - Root And Consumed Family Meanings Diverge Through HashLib
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `root and consumed family meanings diverge` as accepted unless the `HashLib` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-005 - Nonce Domain Excludes Economic Context Through setConsumed
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `nonce domain excludes economic context` as accepted unless the `setConsumed` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-006 - Same Signature Feeds A Distinct Operation Context Through MidnightBundles.pullToken
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `same signature feeds a distinct operation context` as accepted unless the `MidnightBundles.pullToken` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-007 - Authorized Signer And Maker Roles Become Confused Through Permit2
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `authorized signer and maker roles become confused` as accepted unless the `Permit2` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-008 - Periphery Caller And Onbehalf Meanings Diverge Through ERC2612
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `periphery caller and onBehalf meanings diverge` as accepted unless the `ERC2612` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-009 - Permit Amount Funds A Different Beneficiary Through setIsAuthorized
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `permit amount funds a different beneficiary` as accepted unless the `setIsAuthorized` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-010 - Semantic Replay Remains After Technical Replay Prevention Through EcrecoverAuthorizer
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `semantic replay remains after technical replay prevention` as accepted unless the `EcrecoverAuthorizer` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-011 - Referral Recipient Is Unbound From Pulled-Token Intent Through EcrecoverRatifier
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `referral recipient is unbound from pulled-token intent` as accepted unless the `EcrecoverRatifier` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-012 - Receiver Changes After Route Preparation Through HashLib
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `receiver changes after route preparation` as accepted unless the `HashLib` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-013 - Root Cancellation Does Not Cancel Equivalent Family Through setConsumed
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `root cancellation does not cancel equivalent family` as accepted unless the `setConsumed` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-014 - Relayer Reorders Valid Signed Operations Through MidnightBundles.pullToken
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `relayer reorders valid signed operations` as accepted unless the `MidnightBundles.pullToken` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-015 - Signed Grant Survives User Mental-Model Revoke Through Permit2
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `signed grant survives user mental-model revoke` as accepted unless the `Permit2` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-016 - Signature Authorizes A Wider Economic Route Through ERC2612
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `signature authorizes a wider economic route` as accepted unless the `ERC2612` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-017 - Delegate Combines Harmless Capabilities Through setIsAuthorized
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `delegate combines harmless capabilities` as accepted unless the `setIsAuthorized` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-018 - Root And Consumed Family Meanings Diverge Through EcrecoverAuthorizer
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `root and consumed family meanings diverge` as accepted unless the `EcrecoverAuthorizer` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-019 - Nonce Domain Excludes Economic Context Through EcrecoverRatifier
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `nonce domain excludes economic context` as accepted unless the `EcrecoverRatifier` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-020 - Same Signature Feeds A Distinct Operation Context Through HashLib
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `same signature feeds a distinct operation context` as accepted unless the `HashLib` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-021 - Authorized Signer And Maker Roles Become Confused Through setConsumed
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `authorized signer and maker roles become confused` as accepted unless the `setConsumed` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-022 - Periphery Caller And Onbehalf Meanings Diverge Through MidnightBundles.pullToken
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `periphery caller and onBehalf meanings diverge` as accepted unless the `MidnightBundles.pullToken` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-023 - Permit Amount Funds A Different Beneficiary Through Permit2
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `permit amount funds a different beneficiary` as accepted unless the `Permit2` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-024 - Semantic Replay Remains After Technical Replay Prevention Through ERC2612
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `semantic replay remains after technical replay prevention` as accepted unless the `ERC2612` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.

### ASI-025 - Referral Recipient Is Unbound From Pulled-Token Intent Through setIsAuthorized
- Status: `hypothesis_only`.
- Likely accepted semantics: Treat `referral recipient is unbound from pulled-token intent` as accepted unless the `setIsAuthorized` composition exceeds the signer's explicit capability.
- Escalation requirement: Demonstrate third-party harm or an economic beneficiary not bound by the signed intent.
- Proof required: Recover the signer locally, enumerate signed fields, execute the distinct context, and assert a non-dust unauthorized economic effect.
- Promotion gate: Require a compiling local Foundry PoC with realistic standard-token, non-consenting, non-dust impact.
- Dedup gate: Reject if the root cause reduces to a known audited issue or a previously closed direct class.
