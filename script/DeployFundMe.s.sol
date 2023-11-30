// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    address public price_feed;

    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        (price_feed) = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        FundMe fundMe = new FundMe(price_feed);
        vm.stopBroadcast();
        return fundMe;
    }
}
