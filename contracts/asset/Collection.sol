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
import "../common/ShareHolders.sol";

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
    event TokenMinted(address _contractAddress);

    string private _name;
    bool private _nftOnly;
    mapping(address => uint96) private _shares;
    address payable _katonAddress;
    address[] private _shareHolders;
    uint256 private _totalSupply;
    uint256 private _nonce;

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
                Strings.toHexString(uint160(address(this)), 20),
                "/",
                "{id}.json"
            )
        )
        MayBeUpgradeable(config_.isUpgradeable_)
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
        require(
            shareHolders_.katonFeesPercentage_ + shareHolders_
            .projectFeesPercentage_ + shareHolders_.accountFeesPercentage_ == 10000,
            "Collection: Total fees percentage should be equal to 10000"
        );
        _name = name_;
        _totalSupply = 0;
        _nonce = 0;
        _nftOnly = nftOnly_;
        _shares[shareHolders_.katonAddress_] = shareHolders_
            .katonFeesPercentage_;
        _shares[shareHolders_.projectAddress_] = shareHolders_
            .projectFeesPercentage_;
        _shareHolders.push(shareHolders_.katonAddress_);
        _shareHolders.push(shareHolders_.projectAddress_);
        if (shareHolders_.accountFeesPercentage_ > 0) {
            require(
                shareHolders_.accountAddress_ != address(0),
                "Collection: address zero is not a valid account address"
            );
            _shares[shareHolders_.accountAddress_] = shareHolders_
                .accountFeesPercentage_;
            _shareHolders.push(shareHolders_.accountAddress_);
        }
        if (_msgSender() != owner_) {
            _transferOwnership(owner_);
        }
    }

    function _msgData()
        internal
        view
        virtual
        override(ERC2771Context, Context)
        returns (bytes calldata)
    {
        if (isTrustedForwarder(super._msgSender())) {
            return super._msgData()[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }

    function _msgSender()
        internal
        view
        virtual
        override(ERC2771Context, Context)
        returns (address sender)
    {
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

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    event Received(address, uint);

    receive() external payable {
        emit Received(super._msgSender(), msg.value);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function isNftOnly() public view returns (bool) {
        return _nftOnly;
    }

    function nonce() public view returns (uint256) {
        return _nonce;
    }

    function mint(
        uint256 amount,
        uint96 feeNumerator,
        bytes memory data
    ) public payable onlyOwner whenNotPaused {
        require(amount > 0, "Insufficient amount: The amount should be > 0");
        require(
            (isNftOnly() && amount == 1) || !isNftOnly(),
            "NFT Only: The amount should be set to 1"
        );

        if (msg.value > 0) {
            _katonAddress.transfer(msg.value);
        }

        super._mint(_msgSender(), _nonce, amount, data);
        super._setTokenRoyalty(_nonce, address(this), feeNumerator);
        _totalSupply += amount;
        _nonce += 1;
    }

    function addSupply(
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner whenMintable whenNotPaused {
        require(id < _nonce, "Token does not exist: Invalid nonce.");
        super._mint(_msgSender(), id, amount, data);
        _totalSupply += amount;
    }

    function burn(
        uint256 id,
        uint256 amount
    ) public whenNotPaused whenAccountNotFrozen(_msgSender()) {
        super._burn(_msgSender(), id, amount);
        _totalSupply -= amount;
    }

    function wipe(
        address account,
        uint256 id
    ) public onlyOwner whenWipeable whenAccountFrozen(account) {
        uint256 amount = balanceOf(account, id);
        super._burn(account, id, amount);
        _totalSupply -= amount;
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

    function computeShare(
        uint256 balance,
        uint96 feesPercentage
    ) private pure returns (uint256) {
        return (balance * feesPercentage) / _feeDenominator();
    }

    modifier balanceNotEmpty(bool native, address tokenAddress) {
        _checkBalanceNotEmpty(native, tokenAddress);
        _;
    }

    function _checkBalanceNotEmpty(
        bool native,
        address tokenAddress
    ) private view {
        if (native) {
            require(address(this).balance > 0, "No fees to claim");
        } else {
            require(
                IERC777(tokenAddress).balanceOf(address(this)) > 0,
                "No fees to claim"
            );
        }
    }

    event Claimed(
        bool native,
        address _tokenAddress,
        uint256 _totalAmount,
        uint256 _companyAmount,
        address _projectHolderAddress,
        uint256 _projectHolderAmount,
        address _accountHolderAddress,
        uint256 _accountHolderAmount
    );

    function claim(
        bool native,
        address tokenAddress
    ) public isShareholder balanceNotEmpty(native, tokenAddress) {
        uint256[] memory amounts = new uint256[](_shareHolders.length);
        uint256 totalAmount;
        if (native) {
            totalAmount = address(this).balance;
            for (uint i = 0; i < _shareHolders.length; i++) {
                address shareHolderAddress = _shareHolders[i];
                uint256 share = computeShare(
                    totalAmount,
                    _shares[shareHolderAddress]
                );
                amounts[i] = share;
                payable(shareHolderAddress).transfer(share);
            }
        } else {
            totalAmount = IERC777(tokenAddress).balanceOf(address(this));
            for (uint i = 0; i < _shareHolders.length; i++) {
                address shareHolderAddress = _shareHolders[i];
                uint256 share = computeShare(
                    totalAmount,
                    _shares[shareHolderAddress]
                );
                amounts[i] = share;
                IERC777(tokenAddress).send(shareHolderAddress, share, "");
            }
        }
        if (amounts.length <= 2) {
            emit Claimed(
                native,
                tokenAddress,
                totalAmount,
                amounts[0],
                _shareHolders[1],
                amounts[1],
                address(0),
                0
            );
        } else {
            emit Claimed(
                native,
                tokenAddress,
                totalAmount,
                amounts[0],
                _shareHolders[1],
                amounts[1],
                _shareHolders[2],
                amounts[2]
            );
        }
    }
}
