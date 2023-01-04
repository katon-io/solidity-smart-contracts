// contracts/FeeHandler.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

contract FeeHandler is ERC2771Context, Ownable {

    constructor(address trustedForwarder_) 
        ERC2771Context(trustedForwarder_) {}

    function _msgData() internal view virtual override(ERC2771Context, Context) returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return super._msgData()[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }

    function _msgSender() internal view virtual override(ERC2771Context, Context) returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /// @solidity memory-safe-assembly
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

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

        uint256 holderAmount = amount - amount / (1.0 + holderFee / 100);

        uint256 ownerAmount = (amount - holderAmount) * ownerFee / 100;

        uint256 recipientAmount = amount - ownerAmount - holderAmount;

        payable(owner()).transfer(ownerAmount);
        feeHolder.transfer(holderAmount);
        recipient.transfer(recipientAmount);
    }
}