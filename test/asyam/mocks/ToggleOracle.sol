// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IOracle} from "../../../src/interfaces/IOracle.sol";

contract ToggleOracle is IOracle {
    uint256 internal oraclePrice = 1e36;
    bool public shouldRevert;

    function setPrice(uint256 newPrice) external {
        oraclePrice = newPrice;
    }

    function setShouldRevert(bool value) external {
        shouldRevert = value;
    }

    function price() external view returns (uint256) {
        require(!shouldRevert, "oracle unavailable");
        return oraclePrice;
    }
}
