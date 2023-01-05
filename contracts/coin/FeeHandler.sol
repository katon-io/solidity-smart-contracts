// contracts/FeeHandler.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract FeeHandler is Ownable {

    constructor()  {}

    function sendWithFee(
        address payable recipient,
        address payable feeHolder, 
        uint32 holderFee,
        uint32 ownerFee
    ) 
        public payable {
        require(holderFee <= 100, "Holder Fee must be between 0 and 100");
        require(ownerFee <= 100, "Owner Fee must be between 0 and 100");

        uint256 amount = msg.value;

        uint256 ownerAmount = amount - (amount * 100) / (100 + ownerFee);

        uint256 holderAmount = (amount - ownerAmount) * holderFee / 100;

        uint256 recipientAmount = amount - ownerAmount - holderAmount;

        payable(owner()).transfer(ownerAmount);
        feeHolder.transfer(holderAmount);
        recipient.transfer(recipientAmount);
    }
}