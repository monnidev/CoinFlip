## Coin Flip dApp

# Overview

This repo contains the smart contracts for a decentralized Coin Flip game, leveraging [Chainlink's Verifiable Random Function (VRF)](https://vrf.chain.link/) to ensure fairness and transparency in the game's outcome. The game allows players to bet on the outcome of a coin flip, with the smart contract generating a random result to determine winners.
This project was developed using [Foundry](https://book.getfoundry.sh/), a modular toolkit for Ethereum application development.

# Contracts

**CoinFlip.sol** : The main contract for the Coin Flip game, implementing game logic and interactions with the Chainlink VRF for randomness.

**DeployCoinFlip.s.sol** : A deployment script for the Coin Flip contract, facilitating deployment to various networks.

**NetworkConfigurator.s.sol** : A utility contract to configure network-specific parameters, including the Chainlink VRF coordinator address and subscription ID necessary for the game's operation.

# Features

Fair and transparent outcomes powered by Chainlink VRF.
Network configurability for easy deployment across different Ethereum networks.

# Prerequisites

An Ethereum wallet with sufficient Ether for contract deployment and transactions.
An active subscription ID with Chainlink. This ID must be added to the NetworkConfigurator contract before deployment to ensure the Coin Flip game can access Chainlink VRF services.

## Add your active Chainlink subscription ID to the NetworkConfigurator file in the appropriate section for your target network.

# Testing

It's crucial to thoroughly test the contracts before deploying them to a live network or using them in production.

## This project is licensed under the MIT License - see the LICENSE file for details.
