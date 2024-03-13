// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Imports Script for mock testing and scripting.
import {Script} from "forge-std/Script.sol";

error NetworkUnknown(); // Custom error for unknown network configurations.

contract NetworkConfigurator {
    // Defines network configuration structure.
    struct NetworkConfig {
        address vrfCoordinator;
        uint64 subscriptionId;
        bytes32 gasLane;
        uint32 callbackGasLimit;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        // Sets network configuration based on chain ID.
        if (block.chainid == 1) {
            // Mainnet configuration.
            setActiveNetworkConfig(
                0x271682DEB8C4E0901D1a1550aD2e64D568E69909, // Current Mainnet Chainlink Coordinator
                0x0, // ADD MAINNET SUBSCRIPTION ID!.
                0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92, // 200 gwei gas lane.
                500000 // Callback gas limit.
            );
        } else if (block.chainid == 11155111) {
            // Sepolia testnet configuration.
            setActiveNetworkConfig(
                0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625, // Current Testnet Chainlink Coordinator
                0x0, // ADD TESTNET SUBSCRIPTION ID!.
                0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c, // 150 gwei gas lane.
                500000 // Callback gas limit.
            );
        } else {
            // Reverts if chain ID is not recognized.
            revert NetworkUnknown();
        }
    }

    function setActiveNetworkConfig(
        address vrfCoordinator,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit
    ) public {
        // Updates the active network configuration.
        activeNetworkConfig = NetworkConfig({
            vrfCoordinator: vrfCoordinator,
            subscriptionId: subscriptionId,
            gasLane: gasLane,
            callbackGasLimit: callbackGasLimit
        });
    }
}
