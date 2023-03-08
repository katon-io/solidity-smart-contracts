// contracts/common/MayBeFreezable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../coin/Coin.sol";
import "../asset/Collection.sol";
import "../common/ShareHolders.sol";

contract CollectionFactory {
    event CollectionIssued(address _contractAddress);

    constructor() {}

    function issueCollection(
        address owner_,
        string memory name_,
        string memory baseUri_,
        bool nftOnly_,
        Config memory config_,
        ShareHolders memory shareHolders_,
        address trustedForwarder_
    ) public {
        Collection coin = new Collection(
            owner_,
            name_,
            baseUri_,
            nftOnly_,
            config_,
            shareHolders_,
            trustedForwarder_
        );
        emit CollectionIssued(address(coin));
    }
}