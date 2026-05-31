// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IFlashLoanCallback, IRepayCallback} from "../../../src/interfaces/ICallbacks.sol";
import {Market, Offer} from "../../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../../src/Midnight.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";

/// @notice Flash-loan callback probing reentrancy into take/repay/withdraw during onFlashLoan/onRepay.
contract FlashLoanReentrantAttacker is IFlashLoanCallback, IRepayCallback {
    Midnight public midnight;
    address public attacker;
    address public lenderAccount;

    bool public reenteredTake;
    bool public reenteredRepayWithdraw;
    uint256 public stolen;

    Offer internal nestedOffer;
    bytes internal nestedRatifierData;
    uint256 internal nestedUnits;
    address internal nestedTaker;

    Market internal repayMarket;
    bytes32 internal repayMarketId;
    uint256 internal repayUnits;
    address internal repayOnBehalf;
    uint256 internal lenderWithdrawUnits;

    function configure(Midnight _midnight, address _attacker, address _lender) external {
        midnight = _midnight;
        attacker = _attacker;
        lenderAccount = _lender;
    }

    function setNestedTake(Offer memory offer, bytes memory ratifierData, uint256 units, address taker) external {
        nestedOffer = offer;
        nestedRatifierData = ratifierData;
        nestedUnits = units;
        nestedTaker = taker;
    }

    function setNestedRepay(
        bytes32 id,
        Market memory market,
        uint256 units,
        address onBehalf,
        uint256 lenderWithdraw
    ) external {
        repayMarketId = id;
        repayMarket = market;
        repayUnits = units;
        repayOnBehalf = onBehalf;
        lenderWithdrawUnits = lenderWithdraw;
    }

    function onFlashLoan(address, address[] memory tokens, uint256[] memory amounts, bytes memory data)
        external
        returns (bytes32)
    {
        if (data.length > 0 && data[0] == 0x01 && nestedUnits > 0) {
            reenteredTake = true;
            uint256 before = ERC20(tokens[0]).balanceOf(attacker);
            try midnight.take(nestedOffer, nestedRatifierData, nestedUnits, nestedTaker, nestedTaker, address(0), hex"") {
            } catch {}
            stolen = ERC20(tokens[0]).balanceOf(attacker) - before;
        }

        if (data.length > 0 && data[0] == 0x02 && repayUnits > 0) {
            reenteredRepayWithdraw = true;
            uint256 beforeAttacker = ERC20(tokens[0]).balanceOf(attacker);
            ERC20(tokens[0]).approve(address(midnight), repayUnits);
            midnight.repay(repayMarket, repayUnits, repayOnBehalf, address(this), hex"");
            stolen = ERC20(tokens[0]).balanceOf(attacker) - beforeAttacker;
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            ERC20(tokens[i]).approve(address(midnight), type(uint256).max);
        }
        return CALLBACK_SUCCESS;
    }

    function onRepay(bytes32, Market memory, uint256, address, bytes memory) external returns (bytes32) {
        if (lenderWithdrawUnits > 0) {
            uint256 before = ERC20(repayMarket.loanToken).balanceOf(address(this));
            try midnight.withdraw(repayMarket, lenderWithdrawUnits, lenderAccount, address(this)) {} catch {}
            uint256 afterBal = ERC20(repayMarket.loanToken).balanceOf(address(this));
            if (afterBal > before) {
                stolen += afterBal - before;
            }
        }
        return CALLBACK_SUCCESS;
    }
}
