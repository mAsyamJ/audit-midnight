// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IBuyCallback} from "../../../src/interfaces/ICallbacks.sol";
import {Market, Offer} from "../../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../../src/Midnight.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";

/// @notice Rolls a backed lender withdrawal from one market into a buy in another market sharing the loan token.
contract CrossMarketBuyCallback is IBuyCallback {
    Midnight public immutable MIDNIGHT;

    Market internal withdrawMarket;
    Offer internal outerOffer;
    uint256 internal withdrawUnits;
    uint256 internal outerUnits;
    address internal withdrawOnBehalf;

    bool public entered;

    constructor(Midnight _midnight) {
        MIDNIGHT = _midnight;
    }

    function configure(
        Market memory _withdrawMarket,
        address _withdrawOnBehalf,
        uint256 _withdrawUnits,
        Offer memory _outerOffer,
        uint256 _outerUnits
    ) external {
        withdrawMarket = _withdrawMarket;
        withdrawOnBehalf = _withdrawOnBehalf;
        withdrawUnits = _withdrawUnits;
        outerOffer = _outerOffer;
        outerUnits = _outerUnits;
    }

    function execute() external {
        MIDNIGHT.take(outerOffer, hex"", outerUnits, address(this), address(0), address(this), hex"");
    }

    function onBuy(bytes32, Market memory market, uint256, uint256, uint256, address, bytes memory)
        external
        returns (bytes32)
    {
        require(msg.sender == address(MIDNIGHT), "not Midnight");
        require(!entered, "nested callback");
        entered = true;

        MIDNIGHT.withdraw(withdrawMarket, withdrawUnits, withdrawOnBehalf, address(this));
        ERC20(market.loanToken).approve(address(MIDNIGHT), type(uint256).max);
        return CALLBACK_SUCCESS;
    }
}
