// SPDX-License-Identifier: GPL-2.0-or-later

methods {
    function multicall(bytes[]) external => HAVOC_ALL DELETE;

    function withdrawable(bytes32 id) external returns uint256 envfree;
    function totalUnits(bytes32 id) external returns (uint256) envfree;
    function totalShares(bytes32 id) external returns (uint256) envfree;
    function consumed(address user, bytes32 group) external returns (uint256) envfree;
    function sharesOf(bytes32 id, address owner) external returns (uint256) envfree;
    function debtOf(bytes32 id, address owner) external returns (uint256) envfree;

    function IdLib.toId(MorphoV2.Obligation memory obligation, uint256 chainId, address morphoV2) internal returns (bytes32) => CVL_toId(obligation, chainId, morphoV2);

    function _.price() external => NONDET;

    // Check that this doesn't summarize any MorphoV2 functions...
    function _.decimals() external => CVL_decimals(calledContract) expect uint8;
    function _.balanceOf(address a) external => CVL_balanceOf(calledContract, a) expect uint256;
    function _.transfer(address a, uint256 v) external with(env e) => CVL_transferFrom(e, calledContract, e.msg.sender, a, v) expect bool;
    function _.transferFrom(address src, address a, uint256 v) external with(env e) => CVL_transferFrom(e, calledContract, src, a, v) expect bool;
}

// mappings from obligation id to loan token and collateral tokens
ghost mapping(bytes32 => address) loantoken;

// token balances:  token => user => balance
ghost mapping(address => mapping(address => uint256)) tokenBalances;

// IdLib summary
ghost hash(address, uint256, uint256, address) returns bytes32;
function CVL_toId(MorphoV2.Obligation obligation, uint256 chainId, address morphoV2) returns bytes32 {
    bytes32 id = hash(obligation.loanToken, obligation.maturity, chainId, morphoV2); // deterministically set id
    // we assume that the obligation was already used.  We could also check if it's zero and then set the loantoken.
    // but then we need to ensure that token 0 never has a balance.
    require (loantoken[id] == obligation.loanToken), "obligation id has unique loan token";
    return id;
}

// ERC20 summaries
ghost CVL_decimals(address) returns uint8;

function CVL_balanceOf(address token, address a) returns uint256 {
    return tokenBalances[token][a];
}

function CVL_transferFrom(env e, address token, address src, address dest, uint256 value) returns bool {
//    lastTransferredToken = token;
    // TODO Do we need to check authorization here?
    if (tokenBalances[token][src] < value || tokenBalances[token][dest] + value >= 2^256) {
        revert();
    }
    bool success; // non-deterministicaly set success.
    if (success) {
        tokenBalances[token][src] = assert_uint256(tokenBalances[token][src] - value);
        tokenBalances[token][dest] = assert_uint256(tokenBalances[token][dest] + value);
    }
    return success;
}

//ghost mapping(bytes32 => mapping(mathint => address)) collateraltoken;

ghost mapping(bytes32 => mapping(address => mapping(address => mathint))) debtOfMirror {
    init_state axiom (forall bytes32 id. forall address owner. forall address token. debtOfMirror[id][owner][token] == 0);
    init_state axiom (forall address token. debtOfSum(token) == 0);
}
ghost mapping(bytes32 => mapping(address => mapping(address => mathint))) collateralOfMirror {
    init_state axiom (forall bytes32 id. forall address owner. forall address token. collateralOfMirror[id][owner][token] == 0);
    init_state axiom (forall address token. collateralSum(token) == 0);
}
ghost mapping(bytes32 => mapping(address => mathint)) withdrawableMirror {
    init_state axiom (forall bytes32 id. forall address token. withdrawableMirror[id][token] == 0);
    init_state axiom (forall address token. withdrawableSum(token) == 0);
}

definition collateralSum(address token) returns mathint =
    usum bytes32 id, address owner. collateralOfMirror[id][owner][token];
definition withdrawableSum(address token) returns mathint =
    usum bytes32 id. withdrawableMirror[id][token];
definition debtOfSum(address token) returns mathint =
    usum bytes32 id, address owner. debtOfMirror[id][owner][token];

hook Sload uint256 value debtOf[KEY bytes32 id][KEY address owner] {
    require value == debtOfMirror[id][owner][loantoken[id]], "ghost mirror";
}

hook Sstore debtOf[KEY bytes32 id][KEY address owner] uint256 newDebt (uint256 oldDebt) {
    debtOfMirror[id][owner][loantoken[id]] = newDebt;
}

hook Sload uint256 value collateralOf[KEY bytes32 id][KEY address owner][KEY address token] {
    require value == collateralOfMirror[id][owner][token], "ghost mirror";
}

hook Sstore collateralOf[KEY bytes32 id][KEY address owner][KEY address token] uint256 newCollateral (uint256 oldCollateral) {
    collateralOfMirror[id][owner][token] = newCollateral;
}

hook Sload uint256 value obligationState[KEY bytes32 id].withdrawable {
    require value == withdrawableMirror[id][loantoken[id]], "ghost mirror";
}

hook Sstore obligationState[KEY bytes32 id].withdrawable uint256 newWithdrawable (uint256 oldWithdrawable) {
    withdrawableMirror[id][loantoken[id]] = newWithdrawable;
}

/// INVARIANTS ///

strong invariant tokenBalanceCorrect(address token)
    tokenBalances[token][currentContract] >= collateralSum(token) + withdrawableSum(token)
{
    preserved with (env e) {
        require e.msg.sender != currentContract, "only external calls";
    }

    preserved take(uint256 buyerAssets,
            uint256 sellerAssets,
            uint256 obligationUnits,
            uint256 obligationShares,
            address taker,
            MorphoV2.Offer offer,
            MorphoV2.Signature signature,
            bytes32 root,
            bytes32[] proof,
            address takerCallback,
            bytes takerCallbackData) with (env e) {
        require taker != currentContract, "no trading with contract";
        require offer.maker != currentContract, "no trading with contract";
    }
}

