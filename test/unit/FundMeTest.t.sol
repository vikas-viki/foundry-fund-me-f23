// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {Script} from "forge-std/Script.sol";

contract FundMeTest is Test, Script {
    FundMe fundMe;
    address USER = makeAddr("USER");
    uint256 constant SEND_VALUE = 10e18;
    uint256 constant INITIAL_VALUE = 100e18;
    uint256 constant GAS_PRICE = 1;
    address SEPOLIA_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    address MAINNET_PRICE_FEED = 0x773616E4d11A78F511299002da57A0a94577F1f4;
    DeployFundMe deployer;

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: INITIAL_VALUE}();
        _;
    }

    function setUp() external {
        deployer = new DeployFundMe();
        fundMe = deployer.run();
        vm.deal(USER, INITIAL_VALUE);
    }

    function testMinimumDollarIsFive() external {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsDeloyer() external {
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeed() external {
        assertEq(address(fundMe.getPriceFeed()), deployer.price_feed());
    }

    function testPriceFeedVersion() public {
        uint256 version = fundMe.getVersion();
        console.log("version:", version);
        assertEq(version, 4);
    }

    function testLessFundFails() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testCorrectFunderStorage() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddressFilledToFundersArray() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testOwnerCanWithdraw() public funded {
        uint256 startingOwnerBalance = address(msg.sender).balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        uint256 EndingOwnerBalance = address(msg.sender).balance;
        assertEq(EndingOwnerBalance, (startingOwnerBalance + startingFundMeBalance));
    }

    function testWithdrawFromMultipleSenders() public funded {
        uint160 numberOfFunder = 10;
        uint160 startigFunderIndex = 1;
        address fundMeOwner = fundMe.getOwner();
        for (uint160 i = startigFunderIndex; i < numberOfFunder; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMeOwner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMeOwner);
        fundMe.cheaperWithdraw();

        vm.stopPrank();
        uint256 EndingOwnerBalance = fundMeOwner.balance;
        assertEq(EndingOwnerBalance, (startingOwnerBalance + startingFundMeBalance));
    }
}
