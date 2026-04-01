// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {ERC20} from "./ERC20.sol";

contract ERC20RevertToZero is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function transfer(address receiver, uint256 amount) public override returns (bool) {
        require(receiver != address(0), "ERC20: transfer to the zero address");
        return super.transfer(receiver, amount);
    }

    function transferFrom(address sender, address receiver, uint256 amount) public override returns (bool) {
        require(receiver != address(0), "ERC20: transfer to the zero address");
        return super.transferFrom(sender, receiver, amount);
    }
}
