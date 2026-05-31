// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IFlashLoanCallback, ILiquidateCallback} from "../../../src/interfaces/ICallbacks.sol";
import {Market} from "../../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../../src/Midnight.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";

/// @notice Orchestrates post-maturity liquidation compositions without token hooks.
contract MaturityLiquidationFlashAttacker is IFlashLoanCallback, ILiquidateCallback {
    Midnight public immutable MIDNIGHT;
    address public immutable PROFIT_RECEIVER;

    Market internal market;
    address internal borrower;
    uint256 internal repayUnits;

    address internal withdrawLender;
    uint256 internal withdrawUnits;
    bool internal withdrawDuringLiquidation;

    bool public enteredFlash;
    bool public enteredLiquidation;
    uint256 public lastSeized;
    uint256 public lastRepaid;

    constructor(Midnight midnight, address profitReceiver) {
        MIDNIGHT = midnight;
        PROFIT_RECEIVER = profitReceiver;
    }

    function configure(Market memory market_, address borrower_, uint256 repayUnits_) external {
        market = market_;
        borrower = borrower_;
        repayUnits = repayUnits_;
    }

    function configureWithdrawDuringLiquidation(address lender, uint256 units, bool enabled) external {
        withdrawLender = lender;
        withdrawUnits = units;
        withdrawDuringLiquidation = enabled;
    }

    function executeFlashLiquidation(uint256 flashAssets) external {
        address[] memory tokens = new address[](1);
        tokens[0] = market.loanToken;
        uint256[] memory assets = new uint256[](1);
        assets[0] = flashAssets;
        MIDNIGHT.flashLoan(tokens, assets, address(this), hex"");
    }

    function executeCallbackFundedLiquidation(address receiver) external {
        (lastSeized, lastRepaid) =
            MIDNIGHT.liquidate(market, 0, 0, repayUnits, borrower, true, receiver, address(this), hex"");
    }

    function onFlashLoan(address, address[] memory tokens, uint256[] memory assets, bytes memory)
        external
        returns (bytes32)
    {
        require(msg.sender == address(MIDNIGHT), "only Midnight");
        enteredFlash = true;
        ERC20(tokens[0]).approve(address(MIDNIGHT), type(uint256).max);

        (lastSeized, lastRepaid) =
            MIDNIGHT.liquidate(market, 0, 0, repayUnits, borrower, true, address(this), address(this), hex"");

        uint256 balance = ERC20(tokens[0]).balanceOf(address(this));
        require(balance >= assets[0], "flash repayment not retained");
        uint256 profit = balance - assets[0];
        if (profit > 0) require(ERC20(tokens[0]).transfer(PROFIT_RECEIVER, profit), "profit transfer");
        return CALLBACK_SUCCESS;
    }

    function onLiquidate(
        address,
        bytes32,
        Market memory callbackMarket,
        uint256,
        uint256,
        uint256,
        address,
        address,
        bytes memory,
        uint256
    ) external returns (bytes32) {
        require(msg.sender == address(MIDNIGHT), "only Midnight");
        enteredLiquidation = true;
        if (withdrawDuringLiquidation) {
            MIDNIGHT.withdraw(callbackMarket, withdrawUnits, withdrawLender, address(this));
        }
        ERC20(callbackMarket.loanToken).approve(address(MIDNIGHT), type(uint256).max);
        return CALLBACK_SUCCESS;
    }
}
