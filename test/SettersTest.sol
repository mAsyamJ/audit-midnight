// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {BaseTest} from "./BaseTest.sol";
import {WAD} from "../src/libraries/ConstantsLib.sol";

contract SettersTest is BaseTest {
    function testInitialOwner() public view {
        assertEq(morphoV2.owner(), address(this), "deployer should be initial owner");
    }

    function testSetOwnerSuccess(address rdm) public {
        morphoV2.setOwner(rdm);
        assertEq(morphoV2.owner(), rdm, "owner should be transferred");
    }

    function testSetOwnerOnlyOwner(address rdm) public {
        vm.assume(rdm != address(this));
        vm.prank(rdm);
        vm.expectRevert("Only owner");
        morphoV2.setOwner(makeAddr("newOwner"));
    }

    function testSetFeeSetterSuccess(address feeSetter) public {
        morphoV2.setFeeSetter(feeSetter);
        assertEq(morphoV2.feeSetter(), feeSetter);
    }

    function testSetFeeSetterOnlyOwner(address rdm) public {
        vm.assume(rdm != address(this));
        vm.prank(rdm);
        vm.expectRevert("Only owner");
        morphoV2.setFeeSetter(makeAddr("newFeeSetter"));
    }

    function testSetTradingFeeSuccess(
        bytes32 id,
        uint256 zeroDaysTradingFee,
        uint256 oneDaysTradingFee,
        uint256 sevenDaysTradingFee,
        uint256 thirtyDaysTradingFee,
        uint256 ninetyDaysTradingFee
    ) public {
        vm.assume(zeroDaysTradingFee <= WAD);
        vm.assume(oneDaysTradingFee <= WAD);
        vm.assume(sevenDaysTradingFee <= WAD);
        vm.assume(thirtyDaysTradingFee <= WAD);
        vm.assume(ninetyDaysTradingFee <= WAD);
        morphoV2.setTradingFee(
            id, zeroDaysTradingFee, oneDaysTradingFee, sevenDaysTradingFee, thirtyDaysTradingFee, ninetyDaysTradingFee
        );
        uint256 _zeroDaysTradingFee = morphoV2.tradingFees(id, 0);
        assertEq(_zeroDaysTradingFee, zeroDaysTradingFee);
        uint256 _oneDaysTradingFee = morphoV2.tradingFees(id, 1);
        assertEq(_oneDaysTradingFee, oneDaysTradingFee);
        uint256 _sevenDaysTradingFee = morphoV2.tradingFees(id, 2);
        assertEq(_sevenDaysTradingFee, sevenDaysTradingFee);
        uint256 _thirtyDaysTradingFee = morphoV2.tradingFees(id, 3);
        assertEq(_thirtyDaysTradingFee, thirtyDaysTradingFee);
        uint256 _ninetyDaysTradingFee = morphoV2.tradingFees(id, 4);
        assertEq(_ninetyDaysTradingFee, ninetyDaysTradingFee);
    }

    function testSetTradingFeeOnlyFeeSetter(address rdm, bytes32 id) public {
        vm.assume(rdm != address(this));
        vm.prank(rdm);
        vm.expectRevert("Only feeSetter");
        morphoV2.setTradingFee(id, 0, 0, 0, 0, 0);
    }

    function testSetTradingFeeZeroDaysTooHigh(bytes32 id, uint256 tradingFeeTooHigh) public {
        vm.assume(tradingFeeTooHigh > WAD);
        vm.expectRevert("0days trading fee too high");
        morphoV2.setTradingFee(id, tradingFeeTooHigh, 0, 0, 0, 0);
        vm.expectRevert("1days trading fee too high");
        morphoV2.setTradingFee(id, 0, tradingFeeTooHigh, 0, 0, 0);
        vm.expectRevert("7days trading fee too high");
        morphoV2.setTradingFee(id, 0, 0, tradingFeeTooHigh, 0, 0);
        vm.expectRevert("30days trading fee too high");
        morphoV2.setTradingFee(id, 0, 0, 0, tradingFeeTooHigh, 0);
        vm.expectRevert("90days trading fee too high");
        morphoV2.setTradingFee(id, 0, 0, 0, 0, tradingFeeTooHigh);
    }

    function testSetTradingFeeRecipientSuccess(address recipient) public {
        morphoV2.setTradingFeeRecipient(recipient);
        assertEq(morphoV2.tradingFeeRecipient(), recipient, "recipient set");
    }

    function testSetTradingFeeRecipientOnlyOwner(address rdm) public {
        vm.assume(rdm != address(this));
        vm.prank(rdm);
        vm.expectRevert("Only owner");
        morphoV2.setTradingFeeRecipient(makeAddr("newRecipient"));
    }
}
