// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./StarToken.sol";

// Learn more about the ERC20 implementation 
// on OpenZeppelin docs: https://docs.openzeppelin.com/contracts/4.x/api/access#Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

contract Vendor is Ownable {

  // Our Token Contract
  StarToken starToken;

  // token price for BNB
  uint256 public tokensPerBnb = 100;

  // Event that log buy operation
  event BuyTokens(address buyer, uint256 amountOfBNB, uint256 amountOfTokens);

  constructor(address tokenAddress) {
    starToken = StarToken(tokenAddress);
  }

  /**
  * @notice Allow users to buy token for BNB
  */
  function buyTokens() public payable returns (uint256 tokenAmount) {
    require(msg.value > 0, "Send BNB to buy some tokens");

    uint256 amountToBuy = msg.value * tokensPerBnb;

    // check if the Vendor Contract has enough amount of tokens for the transaction
    uint256 vendorBalance = starToken.balanceOf(address(this));
    require(vendorBalance >= amountToBuy, "Vendor contract has not enough tokens in its balance");

    // Transfer token to the msg.sender
    (bool sent) = starToken.transfer(msg.sender, amountToBuy);
    require(sent, "Failed to transfer token to user");

    // emit the event
    emit BuyTokens(msg.sender, msg.value, amountToBuy);

    return amountToBuy;
  }

  /**
  * @notice Allow the owner of the contract to withdraw BNB
  */
  function withdraw() public onlyOwner {
    uint256 ownerBalance = address(this).balance;
    require(ownerBalance > 0, "Owner has not balance to withdraw");

    (bool sent,) = msg.sender.call{value: address(this).balance}("");
    require(sent, "Failed to send user balance back to the owner");
  }
}