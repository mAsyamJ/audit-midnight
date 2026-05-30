// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IEnterGate, ILiquidatorGate} from "../../../src/interfaces/IGate.sol";

contract RevertingEnterGate is IEnterGate {
    bool public blockCredit;
    bool public blockDebt;

    function setBlocks(bool credit, bool debt) external {
        blockCredit = credit;
        blockDebt = debt;
    }

    function canIncreaseCredit(address) external view returns (bool) {
        return !blockCredit;
    }

    function canIncreaseDebt(address) external view returns (bool) {
        return !blockDebt;
    }
}

contract RevertingLiquidatorGate is ILiquidatorGate {
    bool public blocked;

    function setBlocked(bool value) external {
        blocked = value;
    }

    function canLiquidate(address) external view returns (bool) {
        return !blocked;
    }
}
