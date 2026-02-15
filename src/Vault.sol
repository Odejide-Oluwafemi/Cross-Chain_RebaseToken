// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IRebaseToken} from "src/interfaces/IRebaseToken.sol";

contract Vault {
  // Errors
  error Vault__RedeemFailed();

  // Events
  event Deposit(address indexed user, uint256 amount);
  event Redeem(address indexed user, uint256 _amount);

  IRebaseToken private immutable iRebaseToken;
  constructor(IRebaseToken _rebaseToken) {
    iRebaseToken = _rebaseToken;
  }

  function deposit() external payable {
    iRebaseToken.mint(msg.sender, msg.value);
    emit Deposit(msg.sender, msg.value);
  }

  function redeem(uint256 _amount) external {
    iRebaseToken.burn(msg.sender, _amount);
    (bool success, ) = payable(msg.sender).call{value: _amount}("");
    if (!success) revert Vault__RedeemFailed();
    emit Redeem(msg.sender, _amount);
  }

  function getRebaseTokeAddress() external view returns (address) {
    return address(iRebaseToken);
  }
  
  receive() external payable {
  }
}