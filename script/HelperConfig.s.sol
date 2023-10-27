// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "test/Mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address pricefeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getEthMainetConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        return sepoliaConfig;
    }

    function getOrCreateAnvilConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.pricefeed != address(0)) {
            return activeNetworkConfig;
        } else {
            vm.startBroadcast();
            MockV3Aggregator mockPriceFeed = new MockV3Aggregator(8, 2000e8);
            vm.stopBroadcast();

            NetworkConfig memory anvilConfig = NetworkConfig(
                address(mockPriceFeed)
            );

            return anvilConfig;
        }
    }

    function getEthMainetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethMainConfig = NetworkConfig(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        return ethMainConfig;
    }
}
