// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/libraries/SafeTransferLib.sol";

/// @dev Token not returning any boolean.
contract ERC20WithoutBoolean {
    function transfer(address to, uint256 value) external {}
    function transferFrom(address from, address to, uint256 value) external {}
    function approve(address spender, uint256 value) external {}
}

/// @dev Token returning false.
contract ERC20WithBooleanAlwaysFalse {
    function transfer(address to, uint256 value) external returns (bool res) {}
    function transferFrom(address from, address to, uint256 value) external returns (bool res) {}
    function approve(address, uint256) external pure returns (bool res) {}
}

/// @dev Normal token.
contract ERC20Normal {
    fallback() external {
        // return true.
        assembly {
            mstore(0, 1)
            return(0, 32)
        }
    }
}

contract SafeERC20LibTest is Test {
    ERC20Normal public tokenNormal;
    ERC20WithoutBoolean public tokenWithoutBoolean;
    ERC20WithBooleanAlwaysFalse public tokenWithBooleanAlwaysFalse;

    function setUp() public {
        tokenNormal = new ERC20Normal();
        tokenWithoutBoolean = new ERC20WithoutBoolean();
        tokenWithBooleanAlwaysFalse = new ERC20WithBooleanAlwaysFalse();
    }

    function testSafeTransferNoCode() public {
        vm.expectRevert("no code");
        this.safeTransfer(address(1), address(1), 1);
    }

    function testSafeTransferReverted() public {
        vm.expectRevert("transfer reverted");
        this.safeTransfer(address(this), address(1), 1);
    }

    function testSafeTransferReturnedFalse() public {
        vm.expectRevert("transfer returned false");
        this.safeTransfer(address(tokenWithBooleanAlwaysFalse), address(1), 1);
    }

    function testSafeTransferNormal(address to, uint256 value) public {
        vm.expectCall(address(tokenNormal), abi.encodeCall(IERC20.transfer, (to, value)));
        this.safeTransfer(address(tokenNormal), to, value);
    }

    function testSafeTransferNoBoolean(address to, uint256 value) public {
        vm.expectCall(address(tokenWithoutBoolean), abi.encodeCall(IERC20.transfer, (to, value)));
        this.safeTransfer(address(tokenWithoutBoolean), to, value);
    }

    function testSafeTransferFromNoCode() public {
        vm.expectRevert("no code");
        this.safeTransferFrom(address(1), address(1), address(1), 1);
    }

    function testSafeTransferFromReverted() public {
        vm.expectRevert("transferFrom reverted");
        this.safeTransferFrom(address(this), address(1), address(1), 1);
    }

    function testSafeTransferFromReturnedFalse() public {
        vm.expectRevert("transferFrom returned false");
        this.safeTransferFrom(address(tokenWithBooleanAlwaysFalse), address(1), address(1), 1);
    }

    function testSafeTransferFrom(address from, address to, uint256 value) public {
        vm.expectCall(address(tokenNormal), abi.encodeCall(IERC20.transferFrom, (from, to, value)));
        this.safeTransferFrom(address(tokenNormal), from, to, value);
    }

    function testSafeTransferFromNoBoolean(address from, address to, uint256 value) public {
        vm.expectCall(address(tokenWithoutBoolean), abi.encodeCall(IERC20.transferFrom, (from, to, value)));
        this.safeTransferFrom(address(tokenWithoutBoolean), from, to, value);
    }

    /* HELPERS */

    function safeTransfer(address token, address to, uint256 value) external {
        SafeTransferLib.safeTransfer(token, to, value);
    }

    function safeTransferFrom(address token, address from, address to, uint256 value) external {
        SafeTransferLib.safeTransferFrom(token, from, to, value);
    }
}
