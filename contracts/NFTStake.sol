pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

import "./RabbitNFT.sol";
import "./ITurtleNFT.sol";
import "./IRewardToken.sol";

contract NFTStake is Initializable, ContextUpgradeable {
    address public rewardToken;                         // Reward token address
    address public rabbitContract;                         // Winter Elf Nft Contract 
    uint256 public DECIMAL;                             // Decimals for reward token

    mapping(address => Stake[]) public OwnerToTokens;   // Owners to owned Elves
    struct Stake {
        uint256 tokenId;
        uint256 locktime;
    }

    function initialize(address _rewardToken, address _rabbitContract)
        public
        initializer
    {
        rewardToken = _rewardToken;
        rabbitContract = _rabbitContract;
        DECIMAL = 2;
    }

    /**
     * @dev Checks the given address status
     * @param _address The address which will be checked
     */
    function isStakeholder(address _address) public view returns (bool) {
        return OwnerToTokens[_address].length != 0;
    }

    /**
     * @dev Stakes Elf with id `_tokenId`
     * @param _stakeholder The address which will stake NFT
     * @param _tokenId The NFT which will be staked
     */
    function stake(address _stakeholder, uint256 _tokenId) external {
        require(
            IRabbitNFT(rabbitContract).ownerOf(_tokenId) == _msgSender(),
            "Given address is not an owner of the NFT"
        );
        IRabbitNFT(rabbitContract).transferFrom(
            _msgSender(),
            address(this),
            _tokenId
        );

        if (!isStakeholder(_stakeholder)) {
            OwnerToTokens[_stakeholder].push(Stake(_tokenId, block.timestamp));
        } else {
            OwnerToTokens[_stakeholder].push(Stake(_tokenId, block.timestamp));
        }
    }

    /**
     * @dev Claims reward tokens for Staked NFT
     */
    function claimReward() external {
        require(
            isStakeholder(_msgSender()),
            "The msg.sender is not a stake holder"
        );
        uint256 rewardAmount = 0;
        for (uint256 i = 0; i <= OwnerToTokens[_msgSender()].length; i++) {
            if (
                OwnerToTokens[_msgSender()][i].locktime + 24 hours >=
                block.timestamp
            ) {
                rewardAmount +=
                    ((block.timestamp -
                        OwnerToTokens[_msgSender()][i].locktime) / 24 hours) *
                    (10**DECIMAL);
                OwnerToTokens[_msgSender()][i].locktime =
                    block.timestamp +
                    ((block.timestamp -
                        OwnerToTokens[_msgSender()][i].locktime) % 24 hours);
            }
        }
        require(
            rewardAmount > 0,
            "None of the NFTs were staked for more than 24 hours after the last claim"
        );
        IRewardToken(rewardToken).mint(_msgSender(), rewardAmount);
    }

    /**
     * @dev Withdraws collected reward tokens and staked NFT
     */
    function withdraw() external {
        require(
            isStakeholder(_msgSender()),
            "The msg.sender is not a stake holder"
        );
        uint256 rewardAmount = 0;
        for (uint256 i = 0; i <= OwnerToTokens[_msgSender()].length; i++) {
            if (
                OwnerToTokens[_msgSender()][i].locktime + 24 hours >=
                block.timestamp
            ) {
                rewardAmount +=
                    ((block.timestamp -
                        OwnerToTokens[_msgSender()][i].locktime) / 24 hours) *
                    (10**DECIMAL);
            }
            IRabbitNFT(rabbitContract).transferFrom(
                address(this),
                _msgSender(),
                OwnerToTokens[_msgSender()][i].tokenId
            );
        }
        IRewardToken(rewardToken).mint(_msgSender(), rewardAmount);
    }
}