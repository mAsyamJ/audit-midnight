# Morpho Midnight Protocol Model

## Core Design

Morpho Midnight is a non-custodial fixed-rate lending protocol using isolated, immutable, permissionlessly created fixed-maturity markets.

## Market Unit Model

- One debt unit = obligation to repay one loan token before maturity.
- One credit unit = claim on repaid loan tokens.
- Buying units first reduces buyer debt, then increases buyer credit.
- Selling units first reduces seller credit, then increases seller debt.

## Offer Model

- Makers publish executable offers offchain or externally.
- Offers do not reserve capital.
- Capital is sourced only at settlement.
- Takers submit offers to the Midnight contract.

## Callback Model

- Maker callbacks can source funds only when an offer is filled.
- Callback failure or insufficient liquidity can affect offer executability.

## Grouped Offer Model

- Multiple offers may share one consumption group.
- Filling one offer reduces the remaining shared budget for the group.

## Liquidation Model

- Borrower max debt is based on collateral value weighted by LLTV.
- Unhealthy positions can be liquidated before or after maturity.
- Overdue debt becomes liquidatable after maturity.
- Post-maturity liquidation incentive starts at 1 and linearly increases to max LIF over 15 minutes.

## Bad Debt Model

- Bad debt reduces lender credit proportionally.
- Bad debt is realized when liquidation computes debt that cannot be repaid through collateral.

## Gates

- Enter gate restricts who may increase credit or debt.
- Liquidator gate restricts who may liquidate.
- Gates should not trap exits.

## Authorization

- Authorization is coarse-grained.
- Authorized addresses can control the authorizer’s Midnight state.
- Scoped delegation must be implemented externally.

## Fees

- Settlement fee creates spread between buyer and seller prices.
- Continuous fee accrues over time on outstanding credit.