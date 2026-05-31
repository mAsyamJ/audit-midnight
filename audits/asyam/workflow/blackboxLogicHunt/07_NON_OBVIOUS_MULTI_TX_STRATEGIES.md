# Non-Obvious Multi-Transaction Strategies

Date: 2026-05-31

| ID | TX1 | TX2 | TX3 | TX4 | Target state and invariant | Why one-shot tests miss it / PoC feasibility |
|---|---|---|---|---|---|---|
| MTX-001 | Open lender credit | Realize borrower bad debt | Leave lender stale | Withdraw lender max quote | Effective claim must govern exit | Lazy storage needs delayed touch; High |
| MTX-002 | Open two borrower debts | Partial repay A | Realize bad debt B | Touch/withdraw lenders in reverse order | Aggregate backing independent of order | Cross-position; High |
| MTX-003 | Accrue settlement fee A | Open and repay market B | Claim global fee | Withdraw B lender | Custody covers fee plus withdrawable | Cross-market; High |
| MTX-004 | Accrue continuous fee A | Repay A | Claim continuous fee | Withdraw lazy lender | Fee reserved exactly once | Deferred fee; Medium |
| MTX-005 | Build bundle quote | Warp fee breakpoint | Execute route fallback | Inspect debt/refund | Explicit route bounds hold | State changes between quote and settle; High |
| MTX-006 | Ratify root A | Consume partial | Cancel A | Route A/B fallback | Invalid A no effect, B bounded | Direct class closed; adjacent intent only |
| MTX-007 | Grant authorization | Prepare signed root | Revoke signer | Submit route | Revocation and root semantics match intent | Multi-surface scope; High |
| MTX-008 | Sign authorization grant | Submit separate revocation | Submit signed grant | Use bundler | Nonce ordering prevents stale semantic replay | Medium |
| MTX-009 | Activate collateral A | Activate reverting collateral B debtless | Route debt | Attempt liquidation | Bad liveness cannot be imposed without consent | Consent boundary; Medium |
| MTX-010 | Supply 15 collateral tokens | Bundle supplies token 16 and 17 | Earlier pull occurs | Route reverts | Atomic rollback of all prior supplies | Bundle atomicity; Medium |
| MTX-011 | Open debt | Repay debt-1 with referral bundle | Oracle reverts | Withdraw collateral | Dust debt should not create unauthorized freeze | User-intent scope; Medium |
| MTX-012 | Open debt | Repay exact debt | Oracle reverts | Withdraw collateral | Debt-zero exit bypasses oracle dependency | Control case |
| MTX-013 | Open debt | Lower price to boundary | Partial liquidate | Zero-realize bad debt | Socialized debt <= unrecoverable debt | Recoverability; High |
| MTX-014 | Open multi-collateral debt | Lower asymmetric prices | Seize collateral A | Zero-realize, compare order B | Liquidation order cannot create avoidable social loss | Medium |
| MTX-015 | Create market with threshold N | Open debt | Lower price | Full liquidate at threshold N/N+1 | One wei threshold must match intended policy | Medium |
| MTX-016 | Open positions A/B same token | Repay A | Claim fee token from B | Withdraw A then B | Sum liabilities backed | High |
| MTX-017 | Route sell units target | Invalidate first offer | Execute fallback | Compare borrower debt and receive | Min receive and units target capture economics | Medium |
| MTX-018 | Route assets target | Warp maturity | Execute fallback | Compare max units and collateral | Bound holds across temporal change | Medium |
| MTX-019 | Supply collateral debtless | Withdraw zero | Supply zero | Inspect bitmap | No-op cannot poison bitmap | Low |
| MTX-020 | Create similar markets A/B | Emit actions in both | Replay events | Compare storage | Event mirror identifies markets fully | P3 |
| MTX-021 | Open credit | Repeated micro-default | Touch subset lenders | Claim/withdraw | Dust cannot become non-dust state flip | Medium |
| MTX-022 | Accrue lazy fees | Slash market | Touch lender A only | Claim fee then lender B exits | Untouched lender liability still backed | Medium |
| MTX-023 | Set same group across markets | Fill market A | Fill market B | Inspect group cap | Docs require same loan token; classify scope | Low/user error |
| MTX-024 | Set same group opposite sides | Fill buy | Fill sell | Inspect cap semantics | User-configured family mismatch only | Low/user error |
| MTX-025 | Quote route before expiry | Warp expiry+1 | Execute fallback | Inspect refund | Failed first leg has no side effect | Medium |
| MTX-026 | Open debt before maturity | Warp exact maturity | Execute reduce-only route | Liquidate +1 second | No post-maturity exposure increase | Medium |
| MTX-027 | Authorize scoped contract | Scoped contract authorizes relayer | Relayer uses ratifier | Inspect unrelated collateral | Authority transitivity must be intended | Medium |
| MTX-028 | Accrue fee in market A | Create same-token market B | Flash only backed custody | Claim/withdraw ordering | Temporary balance cannot mask deficit | Direct flash closed; aggregate only |
| MTX-029 | Open lender credit | Repay cash | Resting sell offer rolls cash | Attempt withdraw | Rollover is explicit signed liquidity risk | Duplicate filter |
| MTX-030 | Create bad market | Include as route fallback | Invalidate good leg | Execute | Non-consenting route cannot inherit bad market silently | Market ID same-route check likely defends |
