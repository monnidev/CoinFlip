# Disclaimer

This code is part of a small personal project and is not intended for use in production environments. It has not been thoroughly tested, nor has it undergone any form of security audit. Use this code at your own risk, and be aware that it may contain bugs, vulnerabilities, or other issues that could lead to unexpected behavior.


# Coin Flip dApp

## Overview

This repo contains the smart contracts for a decentralized Coin Flip game, leveraging [Chainlink's Verifiable Random Function (VRF)](https://vrf.chain.link/) to ensure fairness and transparency in the game's outcome. The game allows players to bet on the outcome of a coin flip, with the smart contract generating a random result to determine winners.

## Contracts

    CoinFlip.sol: The main contract for the Coin Flip game, implementing game logic and interactions with the Chainlink VRF for randomness.
    DeployCoinFlip.s.sol: A deployment script for the Coin Flip contract, facilitating deployment to various networks.
    NetworkConfigurator.s.sol: A utility contract to configure network-specific parameters, including the Chainlink VRF coordinator address and subscription ID necessary for the game's operation.

## Getting Started

### Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

### Installation

Clone the repository and compile contracts
```bash 
git clone https://github.com/monnidev/Coinflip
code Coinflip
```

### Add your active Chainlink subscription ID to the NetworkConfigurator file in the appropriate section for your target network.

### Build

```
forge build
```

### Test

```
forge test
```

## This project is licensed under the MIT License
