// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {IRatifier} from "../../../src/interfaces/IRatifier.sol";
import {Offer} from "../../../src/interfaces/IMidnight.sol";
import {CALLBACK_SUCCESS} from "../../../src/libraries/ConstantsLib.sol";

/// @notice Always-ratify ratifier for adversarial test setups.
contract MaliciousRatifier is IRatifier {
    function isRatified(Offer memory, bytes memory) external pure returns (bytes32) {
        return CALLBACK_SUCCESS;
    }
}
