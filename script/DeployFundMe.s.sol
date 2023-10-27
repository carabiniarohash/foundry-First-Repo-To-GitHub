// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "src/FundMe.sol";
import {HelperConfig} from "script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        HelperConfig hc = new HelperConfig();

        address ethusdpriceFeed = hc.activeNetworkConfig();

        vm.startBroadcast();

        FundMe ff = new FundMe(ethusdpriceFeed);

        vm.stopBroadcast();

        return ff;
    }
}
    