# Role Collusion and Authorization Compositions

Date: 2026-05-30

These role combinations are threat-model probes. Voluntary delegation and consenting market configuration are not findings unless a third-party or protocol-level invariant breaks.

| # | Role combination | Why it matters / available power | Target invariant | Closed coverage | Untested composition | PoC idea |
|---|---|---|---|---|---|---|
| R-01 | maker + taker across accounts | controls both sides without self-take revert | no credit/debt from nothing | self-take native tests | route legs with alternating identities | COMP-012 |
| R-02 | maker + callback | maker controls transient state consumer | callback no monetization | AP-001 | toggle roots and nested take | COMP-008 |
| R-03 | maker + authorized delegate | delegate changes roots and consumed | cap and authority scope | AP-011/012 | direct/bundle interleave | COMP-016 |
| R-04 | authorized delegate + relayer | separates Midnight actor from transaction payer | payer/receiver intent | native auth | Permit2 route with referral | COMP-005 |
| R-05 | borrower + liquidator | self-liquidation can optimize timing | only intended incentive | AP-005/006 | flash-funded post-maturity unwind | COMP-004 |
| R-06 | borrower + market creator | chooses oracle/gate then borrows | consenting risk only | AP-018 | cross-market shared-token spillover | COMP-019 |
| R-07 | liquidator + callback | consumes precredited withdrawable before pull | custody backing | AP-026 slice | nested withdraw, not nested liquidate | COMP-014 |
| R-08 | fee setter + maker | can stale quotes after signing offers | route max/min guarantees | known fee staleness | signed root fallback | COMP-025 |
| R-09 | role setter + fee setter | can change fee authority | admin-only classification | P3-01 | no external escalation expected | park |
| R-10 | oracle deployer + market creator | controls liveness and pricing | victim consent boundary | AP-004/018 | bitmap cleanup deadlock | COMP-020 |
| R-11 | gate deployer + borrower | delays liquidation | disclosed market risk | gate tests | social-loss timing | COMP-019 |
| R-12 | referral recipient + route builder | chooses fee split and offer ordering | router no residue | AP-023 | canceled-root exact route | COMP-002 |
| R-13 | periphery caller + Permit2 holder | caller funds delegated execution | third-party funds not drained | AP-017 | independent taker/receiver roles | COMP-005 |
| R-14 | same actor across markets | reuses shared token and callback balances | aggregate custody | AP-024 one market | A/B maturity mismatch | COMP-026 |
| R-15 | lender + fee claimer | chooses claim and withdraw order | custody >= liabilities | fee claim native tests | bad debt A plus cash B | COMP-028 |
| R-16 | maker callback + root signer | can enable a nested signed offer mid-take | root and cap validity | AP-001/013 | callback-ratifier root composition | COMP-008 |
| R-17 | liquidator + routed taker | routes seized/funded assets during callback | no double-use float | AP-014/026 | flash + bundle + liquidate | COMP-024 |
| R-18 | borrower + authorized delegate | delegate can repay and withdraw collateral | explicit broad authority | authorization tests | referral receiver split | COMP-005 |
| R-19 | maker + fee claimer | maker fill creates settlement fee then claims | fee backed before claim | settlement fee tests | nested shared-token market claim | COMP-028 |
| R-20 | revoked signer + route relayer | stale route includes invalid first offer | revocation honored, bounds hold | Ecrecover ratifier tests | mixed signer fallback | COMP-029 |
