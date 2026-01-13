// SPDX-License-Identifier: GPL-2.0-or-later
// Copyright (c) 2025 Morpho Association
pragma solidity ^0.8.0;

import {BaseTest} from "./BaseTest.sol";
import {FEE_PRECISION} from "../src/libraries/ConstantsLib.sol";

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
        zeroDaysTradingFee = bound(zeroDaysTradingFee, 0, FEE_PRECISION);
        oneDaysTradingFee = bound(oneDaysTradingFee, 0, FEE_PRECISION);
        sevenDaysTradingFee = bound(sevenDaysTradingFee, 0, FEE_PRECISION);
        thirtyDaysTradingFee = bound(thirtyDaysTradingFee, 0, FEE_PRECISION);
        ninetyDaysTradingFee = bound(ninetyDaysTradingFee, 0, FEE_PRECISION);
        morphoV2.setTradingFee(
            id, zeroDaysTradingFee, oneDaysTradingFee, sevenDaysTradingFee, thirtyDaysTradingFee, ninetyDaysTradingFee
        );
        uint256 _zeroDaysTradingFee = morphoV2.tradingFee(id, 0);
        assertEq(_zeroDaysTradingFee, zeroDaysTradingFee, "zero days trading fee");
        uint256 _oneDaysTradingFee = morphoV2.tradingFee(id, 1 days);
        assertEq(_oneDaysTradingFee, oneDaysTradingFee, "one days trading fee");
        uint256 _sevenDaysTradingFee = morphoV2.tradingFee(id, 7 days);
        assertEq(_sevenDaysTradingFee, sevenDaysTradingFee, "seven days trading fee");
        uint256 _thirtyDaysTradingFee = morphoV2.tradingFee(id, 30 days);
        assertEq(_thirtyDaysTradingFee, thirtyDaysTradingFee, "thirty days trading fee");
        uint256 _ninetyDaysTradingFee = morphoV2.tradingFee(id, 90 days);
        assertEq(_ninetyDaysTradingFee, ninetyDaysTradingFee, "ninety days trading fee");
    }

    function testSetTradingFeeOnlyFeeSetter(address rdm, bytes32 id) public {
        vm.assume(rdm != address(this));
        vm.prank(rdm);
        vm.expectRevert("Only feeSetter");
        morphoV2.setTradingFee(id, 0, 0, 0, 0, 0);
    }

    function testSetTradingFeeZeroDaysTooHigh(bytes32 id, uint256 tradingFeeTooHigh) public {
        tradingFeeTooHigh = bound(tradingFeeTooHigh, FEE_PRECISION + 1, 2 * FEE_PRECISION);
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
