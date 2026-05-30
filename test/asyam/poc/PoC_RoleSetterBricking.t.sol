// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

import {Config} from "../Config.t.sol";
import {IMidnight} from "../../../src/interfaces/IMidnight.sol";

contract PoCRoleSetterBrickingTest is Config {
    function testPoC_RoleSetterCanBeIrreversiblySetToZero() public {
        assertEq(midnight.roleSetter(), address(this), "test precondition: deployer controls roles");

        midnight.setRoleSetter(address(0));

        assertEq(midnight.roleSetter(), address(0), "roleSetter was set to zero");

        vm.expectRevert(IMidnight.OnlyRoleSetter.selector);
        midnight.setRoleSetter(address(this));

        vm.expectRevert(IMidnight.OnlyRoleSetter.selector);
        midnight.setFeeSetter(address(this));

        vm.expectRevert(IMidnight.OnlyRoleSetter.selector);
        midnight.setFeeClaimer(address(this));

        vm.expectRevert(IMidnight.OnlyRoleSetter.selector);
        midnight.setTickSpacingSetter(address(this));
    }
}
