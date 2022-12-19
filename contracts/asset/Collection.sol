// contracts/Collection.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "../common/MayBeWipeable.sol";
import "../common/MayBePausable.sol";
import "../common/MayBeFreezable.sol";
import "../common/MayBeMintable.sol";
import "../common/MayBeBurnable.sol";
import "../common/MayBeUpgradeable.sol";
import "../common/Config.sol";

contract Collection is
    ERC2771Context,
    ERC1155,
    ERC2981,
    Ownable,
    MayBePausable,
    MayBeFreezable,
    MayBeWipeable,
    MayBeMintable,
    MayBeBurnable
{

    struct ShareHolders {
        address katonAddress_;
        uint96 katonFeesPercentage_;
        address projectAddress_;
        uint96 projectFeesPercentage_;
        address accountAddress_;
        uint96 accountFeesPercentage_;
    }

    string private _name;
    bool private _nftOnly;
    mapping(uint256 => bool) private _existingToken;
    mapping(address => uint96) private _shares;
    address[] private _shareHolders;

    constructor(
        address owner_,
        string memory name_,
        string memory baseUri_,
        bool nftOnly_,
        Config memory config_,
        ShareHolders memory shareHolders_,
        address trustedForwarder_
    )
    ERC2771Context(trustedForwarder_)
        ERC1155(
            string.concat(
                baseUri_,
                "/api/assets/collections/",
                Strings.toHexString(uint160(address(this)), 20) ,
                "/",
                Strings.toHexString(uint160(address(this)), 20),
                "_",
                "{id}.json"
            )
        )
        MayBeUpgradeable(config_.isUpgradeable)
        MayBeFreezable(config_.isFreezable_)
        MayBeWipeable(config_.isWipeable_)
        MayBePausable(config_.isPausable_)
        MayBeMintable(config_.isMintable_)
        MayBeBurnable(config_.isBurnable_)
    {
        require(
            shareHolders_.katonAddress_ != address(0),
            "Collection: address zero is not a valid Katon address"
        );
        require(
            shareHolders_.projectAddress_ != address(0),
            "Collection: address zero is not a valid project address"
        );
        _name = name_;
        _nftOnly = nftOnly_;
        _shares[shareHolders_.katonAddress_] = shareHolders_.katonFeesPercentage_;
        _shares[shareHolders_.projectAddress_] = shareHolders_.projectFeesPercentage_;
        _shareHolders.push(shareHolders_.katonAddress_);
        _shareHolders.push(shareHolders_.projectAddress_);
        if(shareHolders_.accountFeesPercentage_ > 0) {
            require(
                shareHolders_.accountAddress_ != address(0),
                "Collection: address zero is not a valid account address"
            );
            _shares[shareHolders_.accountAddress_] = shareHolders_.accountFeesPercentage_;
            _shareHolders.push(shareHolders_.accountAddress_);
        }
        if(_msgSender() != owner_) {
            _transferOwnership(owner_);
        } 
    }
    
    function _msgData() internal view virtual override(ERC2771Context, Context) returns (bytes calldata) {
        if (isTrustedForwarder(super._msgSender())) {
            return super._msgData()[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }

    function _msgSender() internal view virtual override(ERC2771Context, Context) returns (address sender) {
        if (isTrustedForwarder(super._msgSender())) {
            // The assembly code is more direct than the Solidity version using `abi.decode`.
            /// @solidity memory-safe-assembly
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    event Received(address, uint);
    receive() external payable {
        emit Received(super._msgSender(), msg.value);
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
        super._setTokenRoyalty(id, address(this), feeNumerator);
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
            _shares[_msgSender()] > 0,
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

    modifier balanceNotEmpty(bool native, address tokenAddress) {
        _checkBalanceNotEmpty(native, tokenAddress);
        _;
    }

    function _checkBalanceNotEmpty(bool native, address tokenAddress) private view {
        if(native) {
            require(address(this).balance > 0, "No fees to claim");
        } else {
            require(IERC777(tokenAddress).balanceOf(address(this)) > 0, "No fees to claim");
        }
    }

    function claim(bool native, address tokenAddress) public isShareholder balanceNotEmpty(native, tokenAddress) {
        if(native) {
            uint256 balance = address(this).balance;
            for (uint i=0; i<_shareHolders.length; i++) {
                address shareHolderAddress = _shareHolders[i];
                uint256 share = computeShare(balance, _shares[shareHolderAddress]);
                payable(shareHolderAddress).transfer(share);
            }
        } else {
            uint256 balance = IERC777(tokenAddress).balanceOf(address(this));
            for (uint i=0; i<_shareHolders.length; i++) {
                address shareHolderAddress = _shareHolders[i];
                uint256 share = computeShare(balance, _shares[shareHolderAddress]);
                IERC777(tokenAddress).send(shareHolderAddress, share, "");
            }
        }
    }
}
