# Protocol Intention Summary

Date: 2026-05-30

## One-paragraph summary

Morpho Midnight is a **non-custodial fixed-rate lending protocol** on the EVM. Each **isolated, immutable, permissionlessly created market** has a loan token, fixed **maturity**, collateral set (up to 128 params), optional **gates**, and optional **oracles**. Lenders and borrowers trade **credit** and **debt units** (zero-coupon-like claims) via **off-chain offers** ratified on-chain at `take()`; offers **do not escrow capital**—loan tokens move only at settlement. A **periphery router** (`MidnightBundles`) composes multi-step UX (buy/sell targets, collateral, repay, permits, referrals). **Ratifiers** authenticate offers; **callbacks** source liquidity and enable atomic checks. The protocol must preserve **market-level accounting** (`totalUnits`, `withdrawable`, `lossFactor`) and **position solvency** rules across take, repay, withdraw, and liquidation.

Competition: [Cantina Midnight overview](https://cantina.xyz/code/4679e0fa-85f7-4ea5-8827-ee6c70bdee6b/overview)

## Why the design exists

| Design choice | Intention |
|---|---|
| **Fixed maturity** | Positions in the same market are fungible; rate is implied by unit price discount to par at maturity. |
| **Credit/debt units** | Separate lender claims (`credit`) from borrower obligations (`debt`) without bilateral escrow. |
| **Offers without locked capital** | Makers quote across many markets; liquidity is sourced at execution (callbacks / payer). |
| **Isolated immutable markets** | Risk and parameters are market-local; no global pool rehypothecation. |
| **Gates** | Market creators enforce access policy on increasing credit/debt or who may liquidate. |
| **Ratifiers** | Off-chain order books + Merkle/signature proofs bind offer economics on-chain. |
| **Callbacks** | Atomic settlement: pull loan tokens, supply collateral, nested routes, price checks. |
| **Periphery bundles** | UX for exact target fills, referrals, Permit2/ERC2612—core accounting stays in `Midnight`. |

## What “non-custodial fixed-rate lending” means here

- **Non-custodial:** Midnight holds ERC20 balances for collateral and loan-token custody backing `withdrawable`; makers do not pre-deposit offer liquidity.
- **Fixed-rate:** Implied from unit trade price \(P\) and time to maturity: simple rate \(r = 1/P - 1\) (whitepaper §2.1).
- **Lending/borrowing:** Buying units increases **credit**; selling increases **debt**; early exit is trading the opposite side.

## What the protocol must never allow

- Create **credit or debt from nothing** (units/assets inconsistent with `totalUnits` / transfers).
- **Over-withdraw** loan tokens beyond `withdrawable` or user `credit` after slash/accrual.
- **Bypass** `consumed[maker][group]` caps (`maxUnits` / `maxAssets`).
- **Increase maker risk** on `reduceOnly` offers.
- **Liquidate healthy** borrowers (except accepted post-maturity / oracle-market design).
- **Over-realize bad debt** beyond economically unrecoverable debt (slash lenders incorrectly).
- **Leave insolvent borrowers unliquidatable** when collateral/oracle assumptions hold (modulo accepted gate/oracle liveness).
- **Steal** temporary router balances or third-party callback funds (distinct from user-chosen bad receivers).
- **Replay** canceled ratifier roots or unauthorized signatures for economic effect.

## Protocol Intent Table

| Component | Intended purpose | Economic guarantee | Security-critical assumption | Bug if broken? |
|---|---|---|---|---|
| Market | Isolated lending venue | Positions fungible within market ID | Full `Market` encoded in `IdLib.toId` | Yes — ID/custody collision |
| Offer | Executable quote | Price, caps, side, ratifier bound | Ratifier + consumed caps | Yes |
| Credit units | Lender claim on repaid loan tokens | Redeemable via `withdraw` after slash/accrual | `updatePosition` before credit use | Yes |
| Debt units | Borrower obligation | Repay reduces debt, increases `withdrawable` | Maturity debt freeze | Yes |
| Maturity | Calendar settlement date | Post-maturity: no new debt | Timestamp trust | Yes — boundary bugs |
| Collateral | Borrower backing | Health from oracle × LLTV | Oracle returns `price()` | Market-risk vs bug |
| Oracle | Collateral pricing | Used on withdraw/liquidate | Creator-chosen contract | Usually accepted risk |
| Gate | Access policy | Optional credit/debt/liquidator rules | Creator-chosen contract | Usually accepted risk |
| Ratifier | Offer authentication | Only authorized roots/signatures | `isAuthorized[maker][ratifier]` | Yes |
| Callback | Settlement liquidity | Magic return value; payer routing | Untrusted code; token non-reentrant | Yes — reentrancy/value leak |
| Settlement fee | Protocol fee on take spread | `buyerAssets - sellerAssets` to claimable | Fee buckets by time-to-maturity | Yes — fee theft |
| Continuous fee | Time-accrual on credit | Accrues to `continuousFeeCredit` | `updatePosition` ordering | Yes — desync |
| Loss factor | Lender slash on bad debt | Monotonic; sync on `updatePosition` | Only `liquidate` realizes bad debt | Yes |
| Bad debt | Unrecoverable borrower debt | Socialized via `lossFactor` + `totalUnits` | Optimistic bad-debt model | Design vs over-slash bug |
| Withdrawable | Loan tokens available to lenders | Increases on repay/liquidate; decreases on withdraw | `totalUnits = debt + withdrawable` (Certora) | Yes |
| Periphery bundle | Multi-step UX | Uses computed amounts, not balance sweep | Standard ERC20; `MIDNIGHT` immutable | Yes — balance leak |
| Permit / Permit2 | Gasless pull into router | `from = msg.sender` on pulls | Permit2 nonces | Escalate only with victim PoC |

## Unresolved questions

- Competition scope for **weird ERC20** (fee-on-transfer, hooks): repo README + Certora assume exact tokens; Cantina README should be checked per submission.
- **`rcfThreshold`**: recovery close-factor slack in `liquidate`—economic meaning is implementation-documented; see `07_COLLATERAL_HEALTH_AND_LIQUIDATION_MODEL.md`.
- **CVL market-ID summaries** vs production `IdLib.toId`: formal assurance gap (P3-02), not production fund loss unless composition exploit found.

## Classification legend

- **INTENDED / NOT A BUG** — matches NatSpec, tests, or accepted market-design risk.
- **SECURITY-RELEVANT INVARIANT BREAK** — contradicts model + provable in Foundry.
- **REQUIRES POC / SPEC CONFIRMATION** — plausible; not closed.
