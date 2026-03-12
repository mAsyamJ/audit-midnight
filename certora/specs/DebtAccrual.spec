// SPDX-License-Identifier: GPL-2.0-or-later

methods {
    function multicall(bytes[]) external => HAVOC_ALL DELETE;

    function _.price() external => NONDET;

    function tradingFee(bytes32, uint256) internal returns (uint256) => NONDET;
    function SafeTransferLib.safeTransferFrom(address, address, address, uint256) internal => NONDET;
    function SafeTransferLib.safeTransfer(address, address, uint256) internal => NONDET;

    function TickLib.tickToPrice(uint256) internal returns (uint256) => NONDET;
    function TickLib.wExp(int256) internal returns (uint256) => NONDET;
    function UtilsLib.isLeaf(bytes32, bytes32, bytes32[] memory) internal returns (bool) => NONDET;
    function UtilsLib.msb(uint256) internal returns (uint256) => NONDET;
    function UtilsLib.countBits(uint128) internal returns (uint256) => NONDET;

    function IdLib.toId(Midnight.Obligation memory, uint256, address) internal returns (bytes32) => NONDET;

    function isHealthy(Midnight.Obligation memory, bytes32, address) internal returns (bool) => NONDET;

    // Summary: replace accrueContinuousFee with a ghost flag update.
    // The original function body is replaced, so its internal debt reads/writes do not fire hooks.
    function accrueContinuousFee(bytes32 id, address borrower, uint256 maturity) internal => summaryAccrueContinuousFee(id, borrower);
}

/// GHOSTS ///

/// Whether accrueContinuousFee was called for (id, user) in this transaction.
persistent ghost mapping(bytes32 => mapping(address => bool)) accrued {
    init_state axiom (forall bytes32 id. forall address user. accrued[id][user] == false);
}

/// Whether debt was stored before accrueContinuousFee was called for (id, user).
persistent ghost mapping(bytes32 => mapping(address => bool)) debtStoredBeforeAccrual {
    init_state axiom (forall bytes32 id. forall address user. debtStoredBeforeAccrual[id][user] == false);
}

/// Whether debt was loaded before accrueContinuousFee was called for (id, user).
persistent ghost mapping(bytes32 => mapping(address => bool)) debtLoadedBeforeAccrual {
    init_state axiom (forall bytes32 id. forall address user. debtLoadedBeforeAccrual[id][user] == false);
}

/// SUMMARY ///

/// Summary for accrueContinuousFee: just sets the accrued ghost flag.
/// The original function body is replaced, so its internal debt reads/writes do not fire hooks.
function summaryAccrueContinuousFee(bytes32 id, address borrower) {
    accrued[id][borrower] = true;
}

/// HOOKS ///

hook Sstore borrowerState[KEY bytes32 id][KEY address user].debt uint128 newVal (uint128 oldVal) {
    if (!accrued[id][user]) {
        debtStoredBeforeAccrual[id][user] = true;
    }
}

hook Sload uint128 val borrowerState[KEY bytes32 id][KEY address user].debt {
    if (!accrued[id][user]) {
        debtLoadedBeforeAccrual[id][user] = true;
    }
}

/// RULES ///

/// @title Debt is never stored before accrueContinuousFee is called.
/// Since accrueContinuousFee is summarized (its body does not execute), any SSTORE to debt
/// comes from the calling function. If the flag is not set at that point, accrue was not called first.
rule debtNotStoredBeforeAccrual(env e, method f, calldataarg args, bytes32 id, address user)
filtered { f -> !f.isView } {
    require !accrued[id][user];
    require !debtStoredBeforeAccrual[id][user];

    f(e, args);

    assert !debtStoredBeforeAccrual[id][user],
        "debt was stored before accrueContinuousFee was called";
}

/// @title Debt is never loaded before accrueContinuousFee is called.
/// Since accrueContinuousFee is summarized (its body does not execute), any SLOAD of debt
/// comes from the calling function. If the flag is not set at that point, accrue was not called first.
rule debtNotLoadedBeforeAccrual(env e, method f, calldataarg args, bytes32 id, address user)
filtered { f -> !f.isView } {
    require !accrued[id][user];
    require !debtLoadedBeforeAccrual[id][user];

    f(e, args);

    assert !debtLoadedBeforeAccrual[id][user],
        "debt was loaded before accrueContinuousFee was called";
}
