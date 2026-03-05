// SPDX-License-Identifier: GPL-2.0-or-later

methods {
    function multicall(bytes[]) external => HAVOC_ALL DELETE;

    function consumed(address user, bytes32 group) external returns (uint256) envfree;

    // assume price does not revert and does not modify storage.
    function _.price() external => NONDET;
    function UtilsLib.mulDivDown(uint256 x, uint256 y, uint256 d) internal returns (uint256) => summaryMulDiv(x, y, d);
    function UtilsLib.mulDivUp(uint256 x, uint256 y, uint256 d) internal returns (uint256) => summaryMulDiv(x, y, d);
}

function summaryMulDiv(uint256 x, uint256 y, uint256 d) returns uint256 {
    if (x == 0 || y == 0) return 0;
    uint256 res;
    return res;
}

// Only `consume` and `take` can modify the consumed mapping.
rule onlyConsumeAndTakeChangeConsumed(env e, method f, calldataarg args, address user, bytes32 group) filtered { f -> f.selector != sig:consume(bytes32, uint256).selector && f.selector != sig:take(uint256, address, address, bytes, address, Midnight.Offer, Midnight.Signature, bytes32, bytes32[]).selector } {
    uint256 consumedBefore = consumed(user, group);

    f(e, args);

    assert consumed(user, group) == consumedBefore;
}

// Calling `consume` only affects msg.sender's consumed value for the given group.
// No other (user, group) pair is modified.
rule consumeOnlyAffectsSender(env e, bytes32 group, uint256 amount, address otherUser, bytes32 otherGroup) {
    uint256 otherConsumedBefore = consumed(otherUser, otherGroup);

    consume(e, group, amount);

    // Any pair that is not exactly (msg.sender, group) must be unchanged.
    assert (otherUser != e.msg.sender || otherGroup != group) => consumed(otherUser, otherGroup) == otherConsumedBefore;
}

/// @title Calling `take` only affects the maker's consumed value for the offer's group.
/// No other (user, group) pair is modified.
rule takeOnlyAffectsMakerConsumed(env e, uint256 obligationShares, address taker, address takerCallback, bytes takerCallbackData, address receiver, Midnight.Offer offer, Midnight.Signature signature, bytes32 root, bytes32[] proof, address user, bytes32 group) {
    uint256 consumedBefore = consumed(user, group);

    take(e, obligationShares, taker, takerCallback, takerCallbackData, receiver, offer, signature, root, proof);

    // Any pair that is not exactly (offer.maker, offer.group) must be unchanged.
    assert (user != offer.maker || group != offer.group) => consumed(user, group) == consumedBefore;
}

/// @title The consumed mapping is non-decreasing: no function can decrease consumed[user][group].
rule consumeNonDecreasing(env e, method f, calldataarg args, address user, bytes32 group) {
    uint256 consumedBefore = consumed(user, group);

    f(e, args);

    uint256 consumedAfter = consumed(user, group);

    assert consumedAfter >= consumedBefore;
}
