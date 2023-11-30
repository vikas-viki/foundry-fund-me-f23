// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract IntegrationTest is Test {
    FundMe fundMe;
    DeployFundMe deployer;
    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant INITIAL_VALUE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() public {
        deployer = new DeployFundMe();
        fundMe = deployer.run();
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));
        
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        assert(address(fundMe).balance == 0);
    }
    /*
    function testOwnerCanWithdrawInteractions() public {
        vm.deal(USER, INITIAL_VALUE);
        vm.prank(USER);

        FundFundMe fundFundMe = new FundFundMe();
        vm.deal(address(fundFundMe), INITIAL_VALUE);
        fundFundMe.fundFundMe(address(fundMe));

        uint256 startingOwnerBalance = address(this).balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        vm.deal(address(withdrawFundMe), INITIAL_VALUE);
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 EndingOwnerBalance = address(this).balance;
        assertEq(EndingOwnerBalance, (startingOwnerBalance + startingFundMeBalance));
    }
    */
}
