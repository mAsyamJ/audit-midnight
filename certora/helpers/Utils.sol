// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {Obligation} from "../../src/interfaces/IMorphoV2.sol";
import {IdLib} from "../../src/libraries/IdLib.sol";

contract Utils {
    function toId(Obligation memory obligation, uint256 chainId, address morphoV2) external pure returns (bytes20) {
        return bytes20(uint160(uint256(keccak256(abi.encode(obligation, chainId, morphoV2)))));
    }
}
