// contracts/Collection.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "../common/MayBeWipeable.sol";
import "../common/MayBePausable.sol";
import "../common/MayBeFreezable.sol";
import "../common/MayBeMintable.sol";
import "../common/MayBeBurnable.sol";

contract Collection is
    ERC1155,
    ERC2981,
    Ownable,
    MayBePausable,
    MayBeFreezable,
    MayBeWipeable,
    MayBeMintable,
    MayBeBurnable
{
    struct Config {
        bool isPausable_;
        bool isFreezable_;
        bool isWipeable_;
        bool isMintable_;
        bool isBurnable_;
    }

    string private _name;
    bool private _nftOnly;
    mapping(uint256 => bool) private _existingToken;
    address payable private _katonAddress;
    uint96 private _katonFeesPercentage;
    address payable private _projectAddress;
    uint96 private _projectFeesPercentage;

    constructor(
        string memory name_,
        string memory baseUri_,
        bool nftOnly_,
        Config memory config,
        address katonAddress_,
        uint96 katonFeesPercentage_,
        address projectAddress_,
        uint96 projectFeesPercentage_
    )
        ERC1155(
            string.concat(
                baseUri_,
                "/",
                Strings.toHexString(uint160(address(this)), 20),
                "/{id}.json"
            )
        )
        MayBeFreezable(config.isFreezable_)
        MayBeWipeable(config.isWipeable_)
        MayBePausable(config.isPausable_)
        MayBeMintable(config.isMintable_)
        MayBeBurnable(config.isBurnable_)
    {
        require(
            katonAddress_ != address(0),
            "Collection: address zero is not a valid Katon address"
        );
        require(
            projectAddress_ != address(0),
            "Collection: address zero is not a valid project address"
        );
        _name = name_;
        _nftOnly = nftOnly_;
        _katonAddress = payable(katonAddress_);
        _katonFeesPercentage = katonFeesPercentage_;
        _projectAddress = payable(projectAddress_);
        _projectFeesPercentage = projectFeesPercentage_;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC1155, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function isNftOnly() public view returns (bool) {
        return _nftOnly;
    }

    function mint(
        uint256 id,
        uint256 amount,
        uint96 feeNumerator,
        bytes memory data
    ) public onlyOwner whenNotPaused {
        require(amount > 0, "Insufficient amount: The amount should be > 0");
        require(
            (isNftOnly() && amount == 1) || !isNftOnly(),
            "NFT Only: The amount should be set to 1"
        );
        require(
            _existingToken[id] == false,
            "Token already minted: You can't mint on an existing token, use addSupply instead"
        );
        super._mint(_msgSender(), id, amount, data);
        super._setTokenRoyalty(id, _msgSender(), feeNumerator);
        _existingToken[id] = true;
    }

    function addSupply(
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner whenMintable whenNotPaused {
        require(
            _existingToken[id],
            "Token does not exist: You can't add supply to an inexistant token"
        );
        super._mint(_msgSender(), id, amount, data);
    }

    function burn(uint256 id, uint256 amount)
        public
        whenNotPaused
        whenAccountNotFrozen(_msgSender())
    {
        super._burn(_msgSender(), id, amount);
    }

    function wipe(address account, uint256 id)
        public
        onlyOwner
        whenWipeable
        whenAccountFrozen(account)
    {
        super._burn(account, id, balanceOf(account, id));
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override whenNotPaused {
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override whenNotPaused {
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    modifier isShareholder() {
        _checkShareholder();
        _;
    }

    function _checkShareholder() private view {
        require(
            _msgSender() == this.owner() ||
                _msgSender() == _projectAddress ||
                _msgSender() == _katonAddress,
            "You must be a shareholder to claim fees"
        );
    }

    function computeShare(uint256 balance, uint96 feesPercentage)
        private
        pure
        returns (uint256)
    {
        return (balance * feesPercentage) / _feeDenominator();
    }

    modifier balanceNotEmpty() {
        _checkBalanceNotEmpty();
        _;
    }

    function _checkBalanceNotEmpty() private view {
        require(address(this).balance > 0, "No fees to claim");
    }

    function claim() public isShareholder balanceNotEmpty {
        uint256 balance = address(this).balance;
        uint256 katonShare = computeShare(balance, _katonFeesPercentage);
        uint256 projectShare = computeShare(balance, _projectFeesPercentage);
        uint256 ownerShare = balance - katonShare - projectShare;

        if (owner() == _projectAddress) {
            _katonAddress.transfer(katonShare);
            _projectAddress.transfer(projectShare + ownerShare);
        } else {
            _katonAddress.transfer(katonShare);
            _projectAddress.transfer(projectShare);
            payable(owner()).transfer(balance);
        }
    }
}
