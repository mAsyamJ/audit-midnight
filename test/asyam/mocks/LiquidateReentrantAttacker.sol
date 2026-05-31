// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {ILiquidateCallback} from "../../../src/interfaces/ICallbacks.sol";
import {Market} from "../../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../../src/Midnight.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";

/// @notice Probes nested Midnight calls during `onLiquidate`.
contract LiquidateReentrantAttacker is ILiquidateCallback {
    Midnight public midnight;
    address public attacker;

    bool public reenteredLiquidate;
    bool public reenteredTake;
    uint256 public stolen;

    Market internal nestedMarket;
    uint256 internal nestedRepay;
    address internal nestedBorrower;

    function configure(Midnight _midnight, address _attacker) external {
        midnight = _midnight;
        attacker = _attacker;
    }

    function setNestedLiquidate(Market memory market, uint256 repaid, address borrower) external {
        nestedMarket = market;
        nestedRepay = repaid;
        nestedBorrower = borrower;
    }

    function onLiquidate(
        address,
        bytes32,
        Market memory market,
        uint256 collateralIndex,
        uint256,
        uint256 repaidUnits,
        address borrower,
        address,
        bytes memory,
        uint256
    ) external returns (bytes32) {
        uint256 before = ERC20(market.loanToken).balanceOf(attacker);

        if (nestedRepay > 0) {
            reenteredLiquidate = true;
            try midnight.liquidate(
                nestedMarket, collateralIndex, 0, nestedRepay, nestedBorrower, false, address(this), address(0), hex""
            ) {} catch {}
        }

        stolen = ERC20(market.loanToken).balanceOf(attacker) - before;
        ERC20(market.loanToken).approve(msg.sender, repaidUnits);
        return CALLBACK_SUCCESS;
    }
}
