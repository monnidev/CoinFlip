## Coin Flip dApp

# Overview

This repo contains the smart contracts for a decentralized Coin Flip game, leveraging [Chainlink's Verifiable Random Function (VRF)](https://vrf.chain.link/) to ensure fairness and transparency in the game's outcome. The game allows players to bet on the outcome of a coin flip, with the smart contract generating a random result to determine winners.

# Contracts

    CoinFlip.sol: The main contract for the Coin Flip game, implementing game logic and interactions with the Chainlink VRF for randomness.
    DeployCoinFlip.s.sol: A deployment script for the Coin Flip contract, facilitating deployment to various networks.
    NetworkConfigurator.s.sol: A utility contract to configure network-specific parameters, including the Chainlink VRF coordinator address and subscription ID necessary for the game's operation.

# Features

    Fair and transparent outcomes powered by Chainlink VRF.
    Network configurability for easy deployment across different Ethereum networks.

## Add your active Chainlink subscription ID to the NetworkConfigurator file in the appropriate section for your target network.

# Testing

    THIS CODE HAS NOT BEEN TESTED!
    It's crucial to thoroughly test the contracts before deploying them to a live network or using them in production.

## This project is licensed under the MIT License