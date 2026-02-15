// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin-contracts/token/ERC20/ERC20.sol";

/**
 * @title Rebase Token
 * @author Odejide Oluwafemi
 * @notice A Cross Chain Rebase Token that incentivises users to deposit into a vault
 * @notice The Interest Rate in the smart contract can only decrease
 * @notice Each user has their own interest rate (the global interest rate at the time of depositing)
 */
contract RebaseToken is ERC20{
  // Errors
  error RebaseToken__InterestRateCanOnlyDecrease(uint interestRate, uint oldInterestRate);

  // State Variables
  string constant NAME = "My Rebase Token";
  string constant SYMBOL = "mRBT";
  uint256 constant PRECISION_FACTOR = 1e18;
  uint256 private sInterestRate = 5e10;
  mapping(address => uint256) public sUserInterateRate;
  mapping(address => uint256) public sUserLastUpdatedTimeStamp;

  // Events
  event InterestRateSet(uint indexed interestRate);

  constructor() ERC20(NAME, SYMBOL) {}

  /**
   * @notice This sets the interest rate of the contract
   * @param _newInterestRate The new Interest Rate
   * @dev The interest rate can only decrease
   */
  function setInterestRate(uint256 _newInterestRate) external {
    if (_newInterestRate < sInterestRate) {
      revert RebaseToken__InterestRateCanOnlyDecrease(sInterestRate, _newInterestRate);
    }

    sInterestRate = _newInterestRate;
    emit InterestRateSet(_newInterestRate);
  }

  function mint(address _to, uint256 _amount) external {
    _mintAccruedInterest(_to);
    sUserInterateRate[msg.sender] = sInterestRate;
    _mint(_to, _amount);
  }

  function _mintAccruedInterest(address _user) internal {
    // 1. Get their current balance of rebase tokens that have been minted to the user (called the Principal Balance)
    // 2. Calculate their current balance including any interest (balanceOf)
    // 3. Calculate th enumber of tokens to be minted to user (step 2 - step 1 above)
    // 4. Call _mint to mint the tokens to the user
    // 5. Set users' last updated timestamp
    sUserLastUpdatedTimeStamp[_user] = block.timestamp;
  }

  // Getters
  function balanceOf(address _user) public view override returns (uint256) {
    // 1. Get current Principle balance and multiply by interest rate
    return (super.balanceOf(_user) * _calculateUserAccumulatedInterestRate(_user)) / PRECISION_FACTOR;
  }

  function _calculateUserAccumulatedInterestRate(address _user) internal view returns (uint256 linear_interest) {
    // linear_interest = principal_amount (1 + (user_interest_rate * time_elasped))
    // E.g. If deposit = 10, and user_interest_rate = 0.5 tokens per second, and time_elasped = 2 seconds
    // 10 (1 + (0.5 * 2))
    // Therefore, linear_interest = 10(2) = 20
    uint256 timeElasped = block.timestamp - sUserLastUpdatedTimeStamp[_user];
    linear_interest = PRECISION_FACTOR + (sUserInterateRate[_user] * timeElasped);
  }

  /**
   * @notice Gets the interest rate for a user address
   * @param _user The Users' Address to check
   */
  function getInterestRateOfUser(address _user) external view returns (uint256) {
    return sUserInterateRate[_user];
  }
}