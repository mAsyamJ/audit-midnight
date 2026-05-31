// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IBuyCallback} from "../../../src/interfaces/ICallbacks.sol";
import {Market, Offer} from "../../../src/interfaces/IMidnight.sol";
import {Midnight} from "../../../src/Midnight.sol";
import {SetterRatifier} from "../../../src/ratifiers/SetterRatifier.sol";
import {ERC20} from "../../erc20s/ERC20.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";

/// @notice Ratifies and fills a nested offer while an outer take has already updated shared consumption.
contract RatifierRootBuyCallback is IBuyCallback {
    Midnight public immutable MIDNIGHT;
    SetterRatifier public immutable SETTER_RATIFIER;

    Offer internal nestedOffer;
    bytes internal nestedRatifierData;
    bytes32 internal nestedRoot;
    uint256 internal nestedUnits;

    bool public entered;

    constructor(Midnight _midnight, SetterRatifier _setterRatifier) {
        MIDNIGHT = _midnight;
        SETTER_RATIFIER = _setterRatifier;
    }

    function configure(
        Offer memory _nestedOffer,
        bytes memory _nestedRatifierData,
        bytes32 _nestedRoot,
        uint256 _nestedUnits
    ) external {
        nestedOffer = _nestedOffer;
        nestedRatifierData = _nestedRatifierData;
        nestedRoot = _nestedRoot;
        nestedUnits = _nestedUnits;
    }

    function execute(Offer memory outerOffer, bytes memory outerRatifierData, uint256 outerUnits) external {
        ERC20(outerOffer.market.loanToken).approve(address(MIDNIGHT), type(uint256).max);
        MIDNIGHT.take(outerOffer, outerRatifierData, outerUnits, address(this), address(0), address(this), hex"");
    }

    function onBuy(bytes32, Market memory, uint256, uint256, uint256, address, bytes memory)
        external
        returns (bytes32)
    {
        require(msg.sender == address(MIDNIGHT), "not Midnight");
        require(!entered, "nested callback");
        entered = true;

        SETTER_RATIFIER.setIsRootRatified(nestedOffer.maker, nestedRoot, true);
        MIDNIGHT.take(nestedOffer, nestedRatifierData, nestedUnits, address(this), address(0), address(0), hex"");
        return CALLBACK_SUCCESS;
    }
}
