# Offer and Ratification Model

Date: 2026-05-30

## Offer struct economics (`IMidnight.Offer`)

| Field | Role |
|---|---|
| `market` | Binds loan token, maturity, collateral, gates |
| `buy` | Maker is buyer (credit↑) vs seller (debt↑) |
| `maker` | Quote owner; pays consumed cap |
| `start` / `expiry` | Validity window |
| `tick` | Price via `TickLib.tickToPrice`; must align with `tickSpacing` |
| `group` | Shared cap key `consumed[maker][group]` |
| `callback` / `callbackData` | Maker-side liquidity hook |
| `receiverIfMakerIsSeller` | Loan token receiver when maker sells |
| `ratifier` | `isRatified(offer, data)` |
| `reduceOnly` | Cannot increase maker credit (buy) or debt (sell) |
| `maxUnits` / `maxAssets` | Cap (exactly one non-zero) |

## Consumed caps

- `maxAssets > 0`: accumulate `buyerAssets` or `sellerAssets` per side.
- Else: accumulate `units`.
- `setConsumed` can cancel group (`type(uint256).max`).

## Ratifiers

| Ratifier | Mechanism |
|---|---|
| `EcrecoverRatifier` | EIP-712 + Merkle proof (`HashLib`) |
| `SetterRatifier` | On-chain root flag + Merkle proof |

Requires `isAuthorized[maker][ratifier]`.

## Delegated authorization

- `setIsAuthorized` on Midnight and ratifier contracts.
- Broad powers: take, repay, consumed, root cancel — **INTENDED** (duplicate-risk L-16).

## Intended vs bug

| Behavior | Classification |
|---|---|
| Maker cancels own root | INTENDED |
| Authorized delegate cancels if permitted | INTENDED |
| Unauthorized root / ratifier | SECURITY-RELEVANT INVARIANT BREAK |
| Signature replay across economic fields | BREAK (nonce helps authorizer; malleability L-01 Low) |
| Consumed cap bypass | BREAK — **closed disproven** C-05 |
| Fill beyond maxUnits/maxAssets | BREAK |
| Stale canceled root usable | BREAK |
| `reduceOnly` increases maker risk | BREAK — **closed disproven** C-12 |

## PoC target section

| Target | Status |
|---|---|
| Ratifier root grief | Duplicate / operational |
| Group cap rounding | **Closed** `PoC_OfferConsumedCapRounding.t.sol` |
| Signature domain / malleability | **Proven Low** L-01 |
| Maker authorization confusion | REQUIRES POC if novel |
| Callback + offer execution | **Closed** C-14 disproven |

## Cross-links

- [06_CREDIT_DEBT_UNIT_MODEL.md](06_CREDIT_DEBT_UNIT_MODEL.md)
- [12_SECURITY_RELEVANT_INVARIANTS.md](12_SECURITY_RELEVANT_INVARIANTS.md)
