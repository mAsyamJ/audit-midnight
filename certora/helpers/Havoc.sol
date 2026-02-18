// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

interface IHavoc {
    function havoc() external;
}

contract Havoc {

    function callHavoc(address account) external {
        (IHavoc(account)).havoc();
    }
}
