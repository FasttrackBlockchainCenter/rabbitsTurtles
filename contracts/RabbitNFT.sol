// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract RabbitNFT is ERC721URIStorageUpgradeable, OwnableUpgradeable {
    uint256 public totalSupply;
    uint256 public currentSupply;

    using StringsUpgradeable for uint256;
    address[] public owners;
    mapping(address => uint256[]) public ownerToToken;
    bool public revealed;
    string public notRevealedUri;
    string internal baseURI;
    bytes32 rootWhitelisted;
    bytes32 rootExclusive;

    event NFTMinted(address to, uint256 tokenId);

    /**
     * @dev Checks for overflow of the total supply.
     */
    modifier totalSupplyCheck(uint256 _amount) {
        require(
            currentSupply + _amount <= totalSupply,
            "The maximum number of tokens has already been minted"
        );
        _;
    }

    /**
     * @dev Initializes the contract by setting a `_name`, `_symbol` and a `_rewardToken`.
     * @param _name Name of the NFT collection
     * @param _symbol Symbol of the NFT collection
     */
    function initialize(
        string memory _name,
        string memory _symbol,
        string memory _notRevealedURI,
        string memory _basetokenURI,
        bytes32 _rootWhitelisted,
        bytes32 _rootExclusive
    ) public initializer {
        __ERC721_init(_name, _symbol);
        __ERC721URIStorage_init();
        __Ownable_init();

        revealed = false;
        notRevealedUri = _notRevealedURI;
        baseURI = _basetokenURI;
        totalSupply = 8894;
        currentSupply = 0;
        rootWhitelisted = _rootWhitelisted;
        rootExclusive = _rootExclusive;
    }

    
    function getTotalSupply() external view returns(uint256) {
        return totalSupply;
    }

    
    /**
     * @dev Withdraws `_amount` of ethers from contract to `_to`
     * @param _to The destination address
     * @param _amount The amount of ethers
     */
    function withdrawEthers(address _to, uint256 _amount)
        external
        onlyOwner
    {
        require(address(this).balance >= _amount, "Insufficient funds");

        (bool success, ) = payable(address(_to)).call{value: _amount}('');
        require(success);
    }

    /**
     * @dev Withdraws `_amount` of reward tokens from contract to `_to`
     * @param _to The destination address
     * @param _amount Te amount of tokens
     */
    function withdrawTokens(
        address _token,
        address _to,
        uint256 _amount
    ) external onlyOwner {
        require(
            IERC20Upgradeable(_token).balanceOf(address(this)) >= _amount,
            "Insufficient funds"
        );

        IERC20Upgradeable(_token).transfer(_to, _amount);
    }


    /**
     * @dev Sale without Minter Role requirement
     * @param _to The address at which the NFT will be minted
     * @param _amount Amount of tokens to generate
     */
    function publicSale(address _to, uint256 _amount)
        external
        payable
        totalSupplyCheck(_amount)
    {
        require(
            super.balanceOf(_to) < 10,
            "You have maximum amount of NFTs"
        );
        require(msg.value == (_amount * 0.06 ether), "Send the correct amount of ether");

        for (uint256 i = 0; i <= _amount; i++) {
            // Mints Elf to `to`
            currentSupply += 1;
            this.mint(_to, currentSupply);
            emit NFTMinted(_to, currentSupply);
        }
    }

    /**
     * @dev Pre-sale with `WHITELISTED_ROLE` requirement
     * @param _to The address at which the NFT will be minted
     * @param _amount Amount of NFTs to generate
     */
    function preSale(address _to, uint256 _amount, bytes32[] memory _proof)
        public
        payable
        totalSupplyCheck(_amount)
    {
        require(msg.value == (_amount * 0.055 ether) , "Send the correct amount of ether");
        require(_verify(_leaf(_to), rootWhitelisted, _proof) || _verify(_leaf(_to), rootExclusive, _proof), "msg.sender is not whitelisted");
        if (_verify(_leaf(_to), rootWhitelisted, _proof)) {
            require(_amount <= 3, "Wrong amount of NFTs");
            require(
                super.balanceOf(_to) + _amount <= 3,
                "You have maximum amount of NFTs"
            );
            
            for (uint256 i = 0; i < _amount; i++) {
                // Mints Elf to `to`
                currentSupply += 1;
                this.mint(_to, currentSupply);
                emit NFTMinted(_to, currentSupply);
            }
        } 
        else if (_verify(_leaf(_to), rootExclusive, _proof)) {
            require(_amount <= 4, "Wrong amount of NFTs");
            require(
                super.balanceOf(_to) + _amount <= 4,
                "You have maximum amount of NFTs"
            );

            for (uint256 i = 0; i < _amount; i++) {
                // Mints Elf to `to`
                currentSupply += 1;
                this.mint(_to, currentSupply);
                emit NFTMinted(_to, currentSupply);
            }
        }  
    }

    function reveal() public onlyOwner {
        revealed = true;
    }

    function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
    {
        if(revealed == false) {
            return notRevealedUri;
        }

        string memory checkbaseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(checkbaseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual override returns(string memory) {
        return baseURI;
    }

    function baseTokenURI() public view returns (string memory) {
        if(revealed == false) {
            return notRevealedUri;
        }

        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setMerkleTreeRoot(uint8 rootNumber, bytes32 _newRoot) external {
        if (rootNumber == 1) {
            rootExclusive = _newRoot;
        } else {
            rootWhitelisted = _newRoot;
        }
    }

    function getAllOwners()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return owners;
    }

    function _leaf(address account) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(account));
    }

    function _verify(bytes32 leaf, bytes32 _root, bytes32[] memory proof) internal pure returns (bool) {
        return MerkleProof.verify(proof, _root, leaf);
    }

    function mint(
        address _to,
        uint256 _tokenId
    ) external {
        if (ownerToToken[_to].length == 0) {
            ownerToToken[_to].push(_tokenId);
            owners.push(_to);
        } else {
            ownerToToken[_to].push(_tokenId);
        }
        super._mint(_to, _tokenId);
        super._setTokenURI(_tokenId, _tokenId.toString());
    }

    function burn(uint256 _tokenId) external {
        super._burn(_tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
