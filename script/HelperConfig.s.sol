// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import {MockCCIPRouter} from "test/mock/MockRouter.sol";
import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address router;
        address linkToken;
        uint64 destinationChainId;
    }

    event HelperConfig__CreatedMockRouter(address router);

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    function getSepoliaConfig()
        public
        pure
        returns (NetworkConfig memory sepoliaNetworkConfig)
    {
        sepoliaNetworkConfig = NetworkConfig({
            router: 0x0BF3dE8c5D3e8A2B34D2BEeB17ABfCeBaf363A59,
            linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
            destinationChainId: 12532609583862916517 // Polygon Mumbai
        });
    }

    function getAnvilConfig()
        public
        returns (NetworkConfig memory anvilNetworkConfig)
    {
        vm.startBroadcast();
        MockCCIPRouter router = new MockCCIPRouter();
        vm.stopBroadcast();

        emit HelperConfig__CreatedMockRouter(address(router));

        anvilNetworkConfig.router = address(router);
    }
}
