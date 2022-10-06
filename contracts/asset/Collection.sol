// contracts/GLDToken.sol
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
    string private _name;
    bool private _nftOnly;
    mapping(uint256 => bool) private _existingToken;

    constructor(
        string memory name_,
        string memory baseUri_,
        bool nftOnly_,
        bool isPausable_,
        bool isFreezable_,
        bool isWipeable_,
        bool isMintable_,
        bool isBurnable_
    )
        ERC1155(
            string.concat(
                baseUri_,
                "/",
                Strings.toHexString(uint160(address(this)), 20)
            )
        )
        MayBeFreezable(isFreezable_)
        MayBeWipeable(isWipeable_)
        MayBePausable(isPausable_)
        MayBeMintable(isMintable_)
        MayBeBurnable(isBurnable_)
    {
        _name = name_;
        _nftOnly = nftOnly_;
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
}
