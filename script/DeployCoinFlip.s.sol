// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {NetworkConfigurator} from "./NetworkConfigurator.s.sol";
import {CoinFlip} from "../src/CoinFlip.sol";

contract DeployCoinFlip is Script {
    // Deploy CoinFlip contract with initial settings
    function run(address _owner, uint256 _initialCost, uint256 _initialFee)
        external
        returns (CoinFlip, NetworkConfigurator)
    {
        // Instantiate NetworkConfigurator for network settings
        NetworkConfigurator networkConfigurator = new NetworkConfigurator();

        // Retrieve network configuration
        (address vrfCoordinator, uint64 subscriptionId, bytes32 gasLane, uint32 callbackGasLimit) =
            networkConfigurator.activeNetworkConfig();

        vm.startBroadcast(); // Start transaction batch
        // Deploy CoinFlip with parameters and network config
        CoinFlip coinFlip =
            new CoinFlip(_owner, _initialCost, _initialFee, vrfCoordinator, subscriptionId, gasLane, callbackGasLimit);
        vm.stopBroadcast(); // Execute transaction batch

        return (coinFlip, networkConfigurator); // Return deployed contracts
    }
}
