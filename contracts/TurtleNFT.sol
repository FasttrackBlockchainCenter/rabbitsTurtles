// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract TurtleNFT is ERC721URIStorageUpgradeable, AccessControlUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    address[] public owners;
    mapping(address => uint256) public ownerToToken;
    uint256 totalSupply;

    event NFTMinted(address to, string tokenURI);

    /**
     * @dev Initializes the contract by setting ain `_name`, `_symbol` and a `_rewardToken`.
     * @param _name Name of the NFT collection
     * @param _symbol Symbol of the NFT collection
     */
    function initialize(
        string memory _name,
        string memory _symbol
    ) public initializer {
        __ERC721_init(_name, _symbol);
        __AccessControl_init();
        __ERC721URIStorage_init();

        // Initialization of AccessControl
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());

        totalSupply = 0;
    }

    function setControlContract(address _controlContract) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setupRole(MINTER_ROLE, _controlContract);
    }

    function getAllOwners()
        external
        view
        onlyRole(DEFAULT_ADMIN_ROLE)
        returns (address[] memory)
    {
        return owners;
    }

    function mint(
        address _to,
        string memory _tokenURI
    ) external onlyRole(MINTER_ROLE) {
        totalSupply++;
        if (ownerToToken[_to] == 0) {
            ownerToToken[_to] = totalSupply;
            owners.push(_to);
        } else {
            ownerToToken[_to] = totalSupply;
        }
        super._mint(_to, totalSupply);
        super._setTokenURI(totalSupply, _tokenURI);
    }

    function burn(uint256 _tokenId) external onlyRole(MINTER_ROLE) {
        super._burn(_tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable, ERC721Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}