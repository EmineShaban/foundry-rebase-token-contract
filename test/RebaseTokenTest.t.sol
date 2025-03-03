// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {RebaseToken} from "../src/RebaseToken.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {Vault} from "../src/Vault.sol";

contract RebaseTokenTest is Test {
    RebaseToken rebaseToken;
    Vault vault;

    address public owner = makeAddr("owner");
    address public user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        rebaseToken = new RebaseToken();
        vault = new Vault(IRebaseToken(address(rebaseToken)));
        rebaseToken.grantBurnAndMintRole(address(vault));
        vm.stopPrank();
    }

    function addRewardsToValue(uint256 rewerdsAmount) public {
        (bool success,) = payable(address(vault)).call{value: rewerdsAmount}("");
    }

    function testDepositLinear() public {}

    function testRedeemStraightAway(uint256 amount) public {
        amount = bound(amount, 1e5, type(uint96).max);
        vm.startPrank(user);
        vm.deal(user, amount);
        vault.deposit{value: amount}();
        assertEq(rebaseToken.balanceOf(user), amount);
        vault.redeem(type(uint256).max);
        assertEq(rebaseToken.balanceOf(user), 0);
        assertEq(address(user).balance, amount);
        vm.stopPrank();
    }

    function testRedeemAfterTimePassed(uint256 depositAmount, uint256 time) public {
        time = bound(time, 1000, type(uint96).max);
        depositAmount = bound(depositAmount, 1e5, type(uint96).max);
        // vm.startPrank(user);
        vm.deal(user, depositAmount);
        vm.prank(user);
        vault.deposit{value: depositAmount}();
        
        vm.warp(block.timestamp + time);
        uint256 balanceAfter = rebaseToken.balanceOf(user);

        vm.deal(owner, balanceAfter-depositAmount);
        vm.prank(owner);
        addRewardsToValue(balanceAfter - depositAmount);

        vm.prank(user);
        vault.redeem(balanceAfter);

        uint256 ethBalance = address(user).balance;
        console.log("deposit amount:", depositAmount);
        console.log("ethBalance:", ethBalance);
        console.log("balanceAft:", balanceAfter);

    assertEq(balanceAfter, ethBalance);
        assertGt(balanceAfter, depositAmount);
    }
    function testInterestRateCanOnlyDecrease(uint256 newInterestRate) public {}
}
