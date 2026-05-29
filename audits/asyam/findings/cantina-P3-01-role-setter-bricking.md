# Cantina Submission — P3-01

## Cantina UI Fields

| Field | Value |
|---|---|
| **Finding Title** | `roleSetter` can be irreversibly set to `address(0)` |
| **Likelihood** | Low |
| **Impact** | Low |
| **Severity** | Low (computed by Cantina from Likelihood × Impact; may be judged Informational as admin self-DoS) |
| **Checklist anchor** | SOL-Basics-AC-4 (one-step role transfer) |
| **PoC location** | `test/asyamFindings/PoC_RoleSetterBricking.t.sol` |
| **PoC type** | Local Foundry (no fork required) |

---

## Summary

`Midnight.setRoleSetter` accepts any address, including `address(0)`. Once `roleSetter` is zero, no account can pass the `OnlyRoleSetter` check, permanently bricking all role administration functions.

## Finding Description

The `Midnight` contract centralizes privileged role management under a single `roleSetter` address. The following admin functions all require `msg.sender == roleSetter`:

- `setRoleSetter`
- `setFeeSetter`
- `setFeeClaimer`
- `setTickSpacingSetter`

The `setRoleSetter` function performs no input validation on the new address:

```solidity
function setRoleSetter(address newRoleSetter) external {
    require(msg.sender == roleSetter, OnlyRoleSetter());
    roleSetter = newRoleSetter;
    emit EventsLib.SetRoleSetter(newRoleSetter);
}
```

If the current `roleSetter` calls `setRoleSetter(address(0))`, the `roleSetter` storage slot is permanently set to zero. Every subsequent call to any role-management setter reverts with `OnlyRoleSetter`, because no externally owned account or contract can satisfy `msg.sender == address(0)`.

### Security guarantee broken

The protocol assumes **recoverable admin governance**: a live `roleSetter` can rotate fee administration and tick-spacing administration as operational needs change. Setting `roleSetter` to zero is a one-way misconfiguration with no on-chain recovery path. There is no timelock fallback, multisig override, or two-step acceptance pattern to prevent accidental bricking.

### Propagation path

1. The current `roleSetter` (deployer or successor) calls `setRoleSetter(address(0))`.
2. `roleSetter` storage is updated to `address(0)`.
3. Any attempt to call `setRoleSetter`, `setFeeSetter`, `setFeeClaimer`, or `setTickSpacingSetter` reverts with `OnlyRoleSetter`.
4. Fee and tick-spacing roles remain frozen at their last assigned addresses indefinitely.

This is not an external attacker path. Only the current `roleSetter` — or an actor with control of that key — can trigger the bricking.

## Impact Explanation

**Impact: Low**

There is no direct path for an unprivileged external attacker to exploit this. User funds in markets, positions, and collateral are not directly at risk.

The operational impact is permanent loss of role rotation capability:

- `feeSetter`, `feeClaimer`, and `tickSpacingSetter` cannot be updated.
- A compromised fee admin cannot be replaced.
- A mistaken fee configuration cannot be corrected through the intended governance path.

The protocol continues to operate with the roles frozen at their current values. This is an **irreversible admin footgun**, not a permissionless exploit. Judges may classify it as Informational if admin self-DoS is treated as out of scope, but the on-chain bricking is real and permanent.

## Likelihood Explanation

**Likelihood: Low**

Triggering this requires the current `roleSetter` to explicitly pass `address(0)` to `setRoleSetter`, or for the `roleSetter` private key to be compromised and used maliciously. There is no permissionless path for arbitrary users to invoke this.

Typical deployment flows assign `roleSetter` to a deployer or multisig, making accidental zeroing unlikely under normal operation. However, the function accepts zero without revert, so a scripting error, incorrect multisig calldata, or compromised key can cause permanent bricking in a single transaction with no recovery mechanism.

## Proof of Concept

Run:

```bash
forge test --match-path test/asyamFindings/PoC_RoleSetterBricking.t.sol -vvv
```

Validated: 2026-05-30 — 1/1 tests pass.

Full PoC from `test/asyamFindings/PoC_RoleSetterBricking.t.sol`:

```solidity
function testPoC_RoleSetterCanBeIrreversiblySetToZero() public {
    assertEq(midnight.roleSetter(), address(this), "test precondition: deployer controls roles");

    midnight.setRoleSetter(address(0));

    assertEq(midnight.roleSetter(), address(0), "roleSetter was set to zero");

    vm.expectRevert(IMidnight.OnlyRoleSetter.selector);
    midnight.setRoleSetter(address(this));

    vm.expectRevert(IMidnight.OnlyRoleSetter.selector);
    midnight.setFeeSetter(address(this));

    vm.expectRevert(IMidnight.OnlyRoleSetter.selector);
    midnight.setFeeClaimer(address(this));

    vm.expectRevert(IMidnight.OnlyRoleSetter.selector);
    midnight.setTickSpacingSetter(address(this));
}
```

## Recommendation

Reject `address(0)` in `setRoleSetter`:

```solidity
function setRoleSetter(address newRoleSetter) external {
    require(msg.sender == roleSetter, OnlyRoleSetter());
    require(newRoleSetter != address(0), ZeroAddress());
    roleSetter = newRoleSetter;
    emit EventsLib.SetRoleSetter(newRoleSetter);
}
```

For stronger protection against mistaken transfers, use a two-step ownership pattern:

```solidity
address public pendingRoleSetter;

function setRoleSetter(address newRoleSetter) external {
    require(msg.sender == roleSetter, OnlyRoleSetter());
    require(newRoleSetter != address(0), ZeroAddress());
    pendingRoleSetter = newRoleSetter;
}

function acceptRoleSetter() external {
    require(msg.sender == pendingRoleSetter, Unauthorized());
    roleSetter = pendingRoleSetter;
    pendingRoleSetter = address(0);
    emit EventsLib.SetRoleSetter(roleSetter);
}
```

This ensures the new role setter must actively accept the transfer, preventing accidental bricking to an invalid or unintended address.
