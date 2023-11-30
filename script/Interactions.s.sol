// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant INITIAL_VALUE = 10 ether;

    function fundFundMe(address mostRecentDeplment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeplment)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;
    uint256 constant INITIAL_VALUE = 10 ether;

    function withdrawFundMe(address mostRecentDeplment) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentDeplment)).withdraw();
        console.log("Funded FundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}
