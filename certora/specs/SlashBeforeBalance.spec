// SPDX-License-Identifier: GPL-2.0-or-later

methods {
    function multicall(bytes[]) external => HAVOC_ALL DELETE;

    function _.price() external => NONDET;
    function IdLib.toId(Midnight.Obligation memory, uint256, address) internal returns (bytes32) => NONDET;

    function slash(bytes32 id, address user) internal => slashSummary(id, user);
}

/// GHOSTS ///

// Track the obligation's current lossIndex.
persistent ghost mapping(bytes32 => uint128) currentLossIndex {
    init_state axiom (forall bytes32 id. currentLossIndex[id] == 0);
}

// Track the lossIndex at which each user was last slashed.
persistent ghost mapping(bytes32 => mapping(address => uint128)) slashedAtLossIndex {
    init_state axiom (forall bytes32 id. forall address user. slashedAtLossIndex[id][user] == 0);
}

function slashSummary(bytes32 id, address user) {
    slashedAtLossIndex[id][user] = currentLossIndex[id];
}

/// HOOKS ///

// Keep the ghost in sync with obligationState.lossIndex.
hook Sload uint128 value obligationState[KEY bytes32 id].lossIndex {
    require currentLossIndex[id] == value;
}

hook Sstore obligationState[KEY bytes32 id].lossIndex uint128 newValue (uint128 oldValue) {
    currentLossIndex[id] = newValue;
}

// Positive balances must only be read after slash at the current lossIndex.
hook Sload int256 value position[KEY bytes32 id][KEY address user].balance {
    require slashedAtLossIndex[id][user] == currentLossIndex[id] || value <= 0;
}

// Positive balances must only be written after slash at the current lossIndex.
// This also covers zero-to-positive transitions: when newValue > 0, slash is required
// even if oldValue <= 0, ensuring the user's lossIndex is refreshed first.
hook Sstore position[KEY bytes32 id][KEY address user].balance int256 newValue (int256 oldValue) {
    require slashedAtLossIndex[id][user] == currentLossIndex[id] || (oldValue <= 0 && newValue <= 0);
}

/// RULES ///

// View functions that read balanceOf don't call slash (they can't mutate state).
rule balanceReadAfterSlash(method f, env e, calldataarg args)
filtered {
    f -> f.selector != sig:balanceOf(bytes32, address).selector
        && f.selector != sig:debtOf(bytes32, address).selector
        && f.selector != sig:balanceOfAfterSlashing(bytes32, address).selector
        && f.selector != sig:isHealthy(Midnight.Obligation, bytes32, address).selector
} {
    f(e, args);
    assert true;
}

rule balanceWrittenAfterSlash(method f, env e, calldataarg args) {
    f(e, args);
    assert true;
}
