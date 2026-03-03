// SPDX-License-Identifier: GPL-2.0-or-later

using Utils as Utils;
using Midnight as Midnight;

methods {
    function multicall(bytes[]) external => HAVOC_ALL DELETE;
    function _.price() external => NONDET;

    function Midnight.totalUnits(bytes20) external returns (uint256) envfree;
    function Midnight.totalShares(bytes20) external returns (uint256) envfree;
    function Midnight.withdrawable(bytes20) external returns (uint256) envfree;
    function Midnight.fees(bytes20) external returns (uint16[7]) envfree;
    function Midnight.obligationCreated(bytes20) external returns (bool) envfree;
    function Midnight.sharesOf(bytes20, address) external returns (uint256) envfree;
    function Utils.hashObligation(Midnight.Obligation) external returns (bytes32) envfree;

    function UtilsLib.mulDivDown(uint256, uint256, uint256) internal returns (uint256) => NONDET;
    function UtilsLib.mulDivUp(uint256, uint256, uint256) internal returns (uint256) => NONDET;
    function UtilsLib.msb(uint256) internal returns (uint256) => NONDET;
    function UtilsLib.countBits(uint128) internal returns (uint256) => NONDET;

    // Summary is required because abi.encodePacked doesn't ensure injectivity of the hash function in CVL, for an unknown reason.
    function IdLib.toId(Midnight.Obligation memory obligation, uint256, address) internal returns (bytes20) => summaryToId(obligation);
}

// Since the toId function returns a truncated hash, we need to rehash the obligation to ensure injectivity.
persistent ghost mapping(bytes32 => bytes20) rehash {
    axiom forall bytes32 h1. forall bytes32 h2. h1 != h2 => rehash[h1] != rehash[h2];
}

persistent ghost mapping(bytes20 => bytes32) rehashInverse;

function summaryToId(Midnight.Obligation obligation) returns (bytes20) {
    bytes32 hash = Utils.hashObligation(obligation);
    require rehashInverse[rehash[hash]] == hash, "assume that rehash is injective, but only on the hash of the obligations passed to toId";
    return rehash[hash];
}

function obligationIsCreated(Midnight.Obligation obligation) returns (bool) {
    return Midnight.obligationCreated(summaryToId(obligation));
}

// Show that a created obligation has at least one collateral.
invariant createdObligationsHaveNonEmptyCollaterals(Midnight.Obligation obligation)
    obligationIsCreated(obligation) => obligation.collaterals.length > 0;

// Show that a created obligation has sorted collaterals.
invariant createdObligationsHaveSortedCollaterals(Midnight.Obligation obligation, uint256 i, uint256 j)
    obligationIsCreated(obligation) => i < j => j < obligation.collaterals.length => obligation.collaterals[i].token < obligation.collaterals[j].token;

// Show that a created obligation do not have address(0) collaterals.
invariant createdObligationsHaveNonZeroCollaterals(Midnight.Obligation obligation, uint256 i)
    obligationIsCreated(obligation) => i < obligation.collaterals.length => obligation.collaterals[i].token != 0;

// Show that a created obligation cannot be deleted.
rule obligationCannotBeDeleted(env e, method f, calldataarg args, bytes20 id) {
    require Midnight.obligationCreated(id), "Assume that the obligation is created";
    f(e, args);
    assert Midnight.obligationCreated(id);
}

// Show that an obligation is created after an interaction.

rule obligationIsCreatedAfterTouchObligation(env e, Midnight.Obligation obligation) {
    Midnight.touchObligation(e, obligation);
    assert obligationIsCreated(obligation);
}

rule obligationIsCreatedAfterTake(env e, uint256 obligationShares, address taker, address takerCallback, bytes takerCallbackData, address receiverIfTakerIsSeller, Midnight.Offer offer, Midnight.Signature signature, bytes32 root, bytes32[] proof) {
    Midnight.take(e, obligationShares, taker, takerCallback, takerCallbackData, receiverIfTakerIsSeller, offer, signature, root, proof);
    assert obligationIsCreated(offer.obligation);
}

rule obligationIsCreatedAfterWithdraw(env e, Midnight.Obligation obligation, uint256 obligationUnits, uint256 shares, address onBehalf, address receiver) {
    Midnight.withdraw(e, obligation, obligationUnits, shares, onBehalf, receiver);
    assert obligationIsCreated(obligation);
}

rule obligationIsCreatedAfterRepay(env e, Midnight.Obligation obligation, uint256 obligationUnits, address onBehalf) {
    Midnight.repay(e, obligation, obligationUnits, onBehalf);
    assert obligationIsCreated(obligation);
}

rule obligationIsCreatedAfterSupplyCollateral(env e, Midnight.Obligation obligation, uint256 collateralIndex, uint256 assets, address onBehalf) {
    Midnight.supplyCollateral(e, obligation, collateralIndex, assets, onBehalf);
    assert obligationIsCreated(obligation);
}

rule obligationIsCreatedAfterWithdrawCollateral(env e, Midnight.Obligation obligation, uint256 collateralIndex, uint256 assets, address onBehalf, address receiver) {
    Midnight.withdrawCollateral(e, obligation, collateralIndex, assets, onBehalf, receiver);
    assert obligationIsCreated(obligation);
}

rule obligationIsCreatedAfterLiquidate(env e, Midnight.Obligation obligation, uint256 collateralIndex, uint256 seizedAssets, uint256 repaidUnits, address borrower, bytes data) {
    Midnight.liquidate(e, obligation, collateralIndex, seizedAssets, repaidUnits, borrower, data);
    assert obligationIsCreated(obligation);
}

// Show that an obligation state is empty if it is not created.
invariant obligationStateIsEmptyIfNotCreated(bytes20 id, address user)
    !Midnight.obligationCreated(id) => obligationStateIsEmpty(id, user);

definition obligationStateIsEmpty(bytes20 id, address user) returns bool = Midnight.totalUnits(id) == 0 && Midnight.totalShares(id) == 0 && Midnight.withdrawable(id) == 0 && noFeesAreSet(id) && Midnight.sharesOf(id, user) == 0 && userHasNoDebt(id, user) && userHasNoActivatedCollaterals(id, user);

function noFeesAreSet(bytes20 id) returns (bool) {
    uint16[7] fees = Midnight.fees(id);
    return fees[0] == 0 && fees[1] == 0 && fees[2] == 0 && fees[3] == 0 && fees[4] == 0 && fees[5] == 0 && fees[6] == 0;
}

definition userHasNoDebt(bytes20 id, address user) returns bool = currentContract.borrowerState[id][user].debt == 0;

definition userHasNoActivatedCollaterals(bytes20 id, address user) returns bool = currentContract.borrowerState[id][user].activatedCollaterals == 0;

//definition userCollateralIsNotActivated(bytes20 id, address user, uint256 collateralIndex) returns bool = collateralIndex < 128 => currentContract.collateralOf[id][user][collateralIndex] == 0;
