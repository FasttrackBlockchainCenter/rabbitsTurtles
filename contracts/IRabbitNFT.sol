// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

interface IRabbitNFT is IERC721Upgradeable, IAccessControlUpgradeable {
    event NFTMinted(address to, string tokenURI);

    function getAllOwners() external view returns (address[] memory);
    function mint(address _to, uint256 _tokenId) external;
    function burn(uint256 _tokenId) external;
}
