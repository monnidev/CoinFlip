// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

// Custom errors for specific contract failures
error CoinFlip__NotOwner();
error CoinFlip__NoFunctionCalled();
error CoinFlip__IsSuspended();
error CoinFlip__IsCalculating();
error CoinFlip__WrongPrice();
error CoinFlip__TransferFailed();
error CoinFlip__RequestPending();
error CoinFlip__NotEnoughFunds();

contract CoinFlip is VRFConsumerBaseV2 {
    // Enum for tracking game calculation status
    enum Calculating {
        YES,
        NO
    }

    // Chainlink VRF related variables for random number generation
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;

    // Contract state variables
    address public s_owner;
    bool private s_isSuspended;
    Calculating private s_calculating;
    uint256 public s_cost; // Cost to play
    uint256 public s_fee; // Fee per game
    uint256 public s_currentPrice; // Total cost to play (cost + fee)
    uint256 public s_balance; // Contract balance for payouts
    uint256 public s_balanceWinners; // Contract balance reserved for winners
    uint256 private s_balanceLocked; // Amount of balance that is locked for ongoing games
    mapping(address => Calculating) public s_isCalculating; // Player calculating status
    mapping(uint256 => address) public s_games; // Mapping of game request IDs to players
    mapping(address => uint256) public s_winnings; // Player winnings
    uint256 private constant MIDPOINT = type(uint256).max / 2; // Midpoint for win/lose calculation

    // Events for contract actions
    event IsPlaying(address indexed player);
    event RandomnessRequested(uint256 indexed requestId, address indexed player, uint32 tries);
    event GameEnded(uint256 indexed requestId, address indexed player, uint256 totalWinnings);
    event LiquidityAdded(address indexed sender, uint256 amount);
    event OwnershipTransferredTo(address indexed newOwner);
    event SuspensionChanged(bool isSuspended);
    event WinningsWithdrawn(address indexed player, uint256 amount);
    event OwnerWithdrawn(address indexed owner, uint256 indexed amount);
    event PriceChanged(uint256 indexed newCost, uint256 indexed newFee);

    // Modifiers for access control and state checks
    modifier OnlyOwner() {
        if (msg.sender != s_owner) revert CoinFlip__NotOwner();
        _;
    }

    modifier RevertIfSuspended() {
        if (s_isSuspended) revert CoinFlip__IsSuspended();
        _;
    }

    modifier RevertIfCalculating() {
        if (s_isCalculating[msg.sender] != Calculating.NO) revert CoinFlip__IsCalculating();
        _;
    }

    // Constructor to initialize contract with necessary parameters
    constructor(
        address _owner,
        uint256 _initialCost,
        uint256 _initialFee,
        address _vrfCoordinator,
        uint64 _subscriptionId,
        bytes32 _gasLane,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        s_owner = _owner;
        s_cost = _initialCost;
        s_fee = _initialFee;
        s_currentPrice = _initialCost + _initialFee;
        i_vrfCoordinator = VRFCoordinatorV2Interface(_vrfCoordinator);
        i_subscriptionId = _subscriptionId;
        i_gasLane = _gasLane;
        i_callbackGasLimit = _callbackGasLimit;
        s_isSuspended = false;
        s_balance = 0;
        s_balanceLocked = 0;
    }

    // Fallback function to prevent accidental ETH sends
    fallback() external {
        revert CoinFlip__NoFunctionCalled();
    }

    // Main function for players to play the game
    function play(uint32 _tries) external payable RevertIfSuspended RevertIfCalculating {
        uint256 _gameValue = s_currentPrice * _tries;
        uint256 _possibleWin = s_cost * _tries;
        s_balance = s_balance + _gameValue - _possibleWin;
        s_balanceLocked += _possibleWin;
        if (msg.value != _gameValue) {
            revert CoinFlip__WrongPrice();
        }
        s_isCalculating[msg.sender] = Calculating.YES;
        emit IsPlaying(msg.sender);
        uint256 _requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane, i_subscriptionId, REQUEST_CONFIRMATIONS, i_callbackGasLimit, _tries
        );
        s_games[_requestId] = msg.sender;
        emit RandomnessRequested(_requestId, msg.sender, _tries);
    }

    // Allows owner to suspend or resume the contract
    function changeSuspension(bool _newSuspension) external OnlyOwner {
        s_isSuspended = _newSuspension;
        emit SuspensionChanged(_newSuspension);
    }

    // Allows owner to transfer contract ownership
    function changeOwner(address _newOwner) external OnlyOwner {
        s_owner = _newOwner;
        emit OwnershipTransferredTo(_newOwner);
    }

    // Allows owner to change the cost and fee of playing if there are no pending requests
    function changePrice(uint256 _newCost, uint256 _newFee) external OnlyOwner {
        if (!i_vrfCoordinator.pendingRequestExists(i_subscriptionId)) {
            s_cost = _newCost;
            s_fee = _newFee;
            s_currentPrice = _newCost + _newFee;
            emit PriceChanged(_newCost, _newFee);
        } else {
            revert CoinFlip__RequestPending();
        }
    }

    // Function to add liquidity to the contract
    function addLiquidity() external payable {
        s_balance += msg.value;
        emit LiquidityAdded(msg.sender, msg.value);
    }

    // Allows players to withdraw their winnings
    function withdrawWinnings() external {
        uint256 _toWithdraw = s_winnings[msg.sender];
        s_balanceWinners -= _toWithdraw;
        s_winnings[msg.sender] = 0;
        (bool success,) = payable(address(msg.sender)).call{value: _toWithdraw}("");
        if (!success) {
            revert CoinFlip__TransferFailed();
        }
        emit WinningsWithdrawn(msg.sender, _toWithdraw);
    }

    // Allows the owner to withdraw funds which are not reserved
    function ownerWithdrawal(uint256 _amount) external OnlyOwner {
        if (_amount < s_balance - s_balanceWinners) {
            s_balance -= _amount;
            (bool success,) = payable(msg.sender).call{value: _amount}("");
            if (!success) {
                revert CoinFlip__TransferFailed();
            }
            emit OwnerWithdrawn(msg.sender, _amount);
        } else {
            revert CoinFlip__NotEnoughFunds();
        }
    }

    // Chainlink VRF callback function to handle the randomness response
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        address _player = s_games[requestId];
        uint256 _tries = randomWords.length;
        uint256 _realizedWin = 0;
        uint256 _toUnlock = 0;
        uint256 _singleWin = s_cost * 2; // Winning amount for a single try

        // Calculate total winnings and the amount to unlock from the locked balance
        for (uint32 i = 0; i < _tries; i++) {
            if (randomWords[i] > MIDPOINT) {
                // If the random number is above the midpoint, the player wins
                _realizedWin += _singleWin;
            } else {
                // If not, the amount is unlocked but remains in the contract's balance
                _toUnlock += _singleWin;
            }
        }

        // Update the player's winnings and adjust the contract's locked balance
        s_winnings[_player] += _realizedWin;
        s_balanceWinners += _realizedWin; // Increments the winners balance
        s_balance += _toUnlock; // Re-add to balance for future games
        s_balanceLocked -= _toUnlock; // Unlock the balance that was reserved for this game

        // Reset the player's calculating status and emit the game ended event
        s_isCalculating[_player] = Calculating.NO;
        emit GameEnded(requestId, _player, _realizedWin);
    }
}
