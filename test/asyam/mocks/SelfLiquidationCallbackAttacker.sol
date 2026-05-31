// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {ILiquidateCallback} from "../../../src/interfaces/ICallbacks.sol";
import {Market, Offer} from "../../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../../src/Midnight.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";

/// @notice Probes borrower-controlled liquidation callback accounting with ordinary ERC20s.
contract SelfLiquidationCallbackAttacker is ILiquidateCallback {
    Midnight public immutable MIDNIGHT;

    Market internal market;
    Offer internal replacementOffer;
    address internal borrower;
    uint256 internal repayUnits;
    uint256 internal nestedRepayUnits;
    uint256 internal replacementUnits;
    bool internal postMaturityMode;
    bool internal recycleSeizedCollateral;

    bool public enteredCallback;
    bool public nestedRepayExecuted;
    bool public replacementTakeExecuted;
    uint256 public lastSeizedAssets;
    uint256 public lastRepaidUnits;
    uint256 public lastBadDebt;
    uint256 public observedDebt;
    uint256 public observedCollateral;
    uint256 public observedWithdrawable;
    uint256 public observedTotalUnits;
    uint256 public observedLossFactor;

    constructor(Midnight midnight) {
        MIDNIGHT = midnight;
    }

    function configure(
        Market memory market_,
        address borrower_,
        uint256 repayUnits_,
        bool postMaturityMode_,
        bool recycleSeizedCollateral_,
        uint256 nestedRepayUnits_,
        Offer memory replacementOffer_,
        uint256 replacementUnits_
    ) external {
        market = market_;
        borrower = borrower_;
        repayUnits = repayUnits_;
        postMaturityMode = postMaturityMode_;
        recycleSeizedCollateral = recycleSeizedCollateral_;
        nestedRepayUnits = nestedRepayUnits_;
        replacementOffer = replacementOffer_;
        replacementUnits = replacementUnits_;
    }

    function executeSelfLiquidation() external returns (uint256 seizedAssets, uint256 repaidUnits_) {
        (seizedAssets, repaidUnits_) = MIDNIGHT.liquidate(
            market, 0, 0, repayUnits, borrower, postMaturityMode, address(this), address(this), hex""
        );
    }

    function onLiquidate(
        address,
        bytes32 id,
        Market memory callbackMarket,
        uint256 collateralIndex,
        uint256 seizedAssets,
        uint256 repaidUnits_,
        address callbackBorrower,
        address receiver,
        bytes memory,
        uint256 badDebt
    ) external returns (bytes32) {
        require(msg.sender == address(MIDNIGHT), "only Midnight");
        require(callbackBorrower == borrower, "borrower mismatch");
        require(receiver == address(this), "receiver mismatch");

        enteredCallback = true;
        lastSeizedAssets = seizedAssets;
        lastRepaidUnits = repaidUnits_;
        lastBadDebt = badDebt;
        observedDebt = MIDNIGHT.debtOf(id, borrower);
        observedCollateral = MIDNIGHT.collateral(id, borrower, collateralIndex);
        observedWithdrawable = MIDNIGHT.withdrawable(id);
        observedTotalUnits = MIDNIGHT.totalUnits(id);
        observedLossFactor = MIDNIGHT.lossFactor(id);

        if (recycleSeizedCollateral) {
            ERC20 collateralToken = ERC20(callbackMarket.collateralParams[collateralIndex].token);
            collateralToken.approve(address(MIDNIGHT), seizedAssets);
            MIDNIGHT.supplyCollateral(callbackMarket, collateralIndex, seizedAssets, borrower);
        }

        ERC20 loanToken = ERC20(callbackMarket.loanToken);
        loanToken.approve(address(MIDNIGHT), type(uint256).max);

        if (nestedRepayUnits > 0) {
            nestedRepayExecuted = true;
            MIDNIGHT.repay(callbackMarket, nestedRepayUnits, borrower, address(0), hex"");
        }

        if (replacementUnits > 0) {
            replacementTakeExecuted = true;
            MIDNIGHT.take(replacementOffer, hex"", replacementUnits, address(this), borrower, address(0), hex"");
        }

        return CALLBACK_SUCCESS;
    }
}
