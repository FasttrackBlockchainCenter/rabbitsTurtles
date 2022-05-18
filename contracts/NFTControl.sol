// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./IRabbitNFT.sol";
import "./ITurtleNFT.sol";
import "./IRewardToken.sol";
import "./IRandomNumberConsumer.sol";

contract NFTControl is AccessControlUpgradeable {
    address public rewardToken;                         // Reward token address
    address public rabbitContract;                         // Winter rabbit Nft Contract 
    address public turtleContract;                        // Space turtle Contract
    uint256 public DECIMAL;                             // Decimals for reward token
    mapping(address => uint256) public winners;         // List of winners in present 2
    address[] public betters;                           // List of betters for present 3
    mapping(address => uint256[2]) public bettersToNFTs;// Betters to NFTs
    uint256 public winnersCount;                        // Count of present 2 winners
    address public finalWinner;                         // Address of present 3 winner 
    uint256 public BETTING_PERIOD;                      // Duration of betting
    uint256 public initTime;                            // First bet time
    address public randomContract;

    event NFTMinted(address to, uint256 tokenId);

 
    /**
     * @dev Initializes the contract by setting a `_name`, `_symbol` and a `_rewardToken`.
     * @param _rewardToken   Already deployed Reward token's address (ERC20)
     * @param _rabbitContract   Already deployed Elves token's address (ERC721)
     * @param _turtleContract  Already deployed Space turtles token's address (ERC721)
     * @param _bettingPeriod Duration of betting counteed after first bet 
     */
    function initialize(address _rewardToken, address _rabbitContract, address _turtleContract, uint256 _bettingPeriod, address _randomContract)
        public
        initializer
    {
        // Initialization of AccessControl
        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        // Initialization of variables
        rewardToken = _rewardToken;
        rabbitContract = _rabbitContract;
        turtleContract = _turtleContract;
        DECIMAL = 2;
        winnersCount = 0;
        BETTING_PERIOD = _bettingPeriod;
        randomContract = _randomContract;
    }

    function grantRoleBatch(address[] calldata _addresses, bytes32 _role) external onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint256 i = 0; i < _addresses.length; i++) {
            grantRole(_role, _addresses[i]);
        }
    }

    /**
     * @dev Mints Space turtle
     * Msg.sender must have at least 2 Elves to call the function 
     * @param _tokenId1 First NFT
     * @param _tokenId2 Second NFT
     */
    function mintGenesis(uint256 _tokenId1, uint256 _tokenId2) external {
        require(
            IRabbitNFT(rabbitContract).ownerOf(_tokenId1) == _msgSender() &&
                IRabbitNFT(rabbitContract).ownerOf(_tokenId2) == _msgSender(),
            "msg.sender is not the owner of the tokens"
        );
        require(ITurtleNFT(turtleContract).balanceOf(_msgSender()) == 0, "The token has already been minted");
        require(IRewardToken(rewardToken).balanceOf(_msgSender()) >= 500 * (10 ** DECIMAL), "msg.sender balance should be above 50000 tokens to run this function");
        
        ITurtleNFT(turtleContract).mint(_msgSender(), '');
    }

    /**
     * @dev Claims reward ether (1 eth / 0.2 eth)
     * Msg.sender must approve `_tokenId1` & `_tokenId2` to run this function
     * @param _tokenId1 Burns rabbit with Id `_tokenId1`
     * @param _tokenId2 Burns rabbit with Id `_tokenId2`
     */
    function claimPresent2(uint256 _tokenId1, uint256 _tokenId2) external {
        require(
            IRabbitNFT(rabbitContract).getApproved(_tokenId1) == address(this) &&
                IRabbitNFT(rabbitContract).getApproved(_tokenId2) == address(this),
            "Approve those tokens before calling the function"
        );
        require(IRewardToken(rewardToken).allowance(_msgSender(), address(this)) >= 800 * (10 ** DECIMAL), "msg.sender should approve 800 tokens to run this function");
        IRandomNumberConsumer(randomContract).getRandomNumber();
        if (IRandomNumberConsumer(randomContract).getResult() % 10 == 0) {
            payable(_msgSender()).transfer(1 ether);
            winners[_msgSender()] = winnersCount + 1;
            winnersCount++;
        } else {
            payable(_msgSender()).transfer(0.2 ether);
        }

        IRabbitNFT(rabbitContract).burn(_tokenId1);
        IRabbitNFT(rabbitContract).burn(_tokenId2);
        IRewardToken(rewardToken).burn(_msgSender(), 800 * (10 ** DECIMAL));
    }

    /**
     * @dev Bets NFTs and RewardTokens for Present 3
     * Msg.sender must approve `_tokenId1` & `_tokenId2` to run this function
     * @param _tokenId1 Burns rabbit with Id `_tokenId1`
     * @param _tokenId2 Burns rabbit with Id `_tokenId2`
     */
    function betForPresent3(uint256 _tokenId1, uint256 _tokenId2) external {
        require(winners[_msgSender()] != 0, "msg.sender is not a winner of present 2");
        IRabbitNFT(rabbitContract).transferFrom(_msgSender(), address(this), _tokenId1);
        IRabbitNFT(rabbitContract).transferFrom(_msgSender(), address(this), _tokenId2);
        IRewardToken(rewardToken).transferFrom(_msgSender(), address(this), 800 * (10 ** DECIMAL));
    
        betters.push(_msgSender());
        bettersToNFTs[_msgSender()] = [_tokenId1, _tokenId2];
        initTime = block.timestamp;
    }

    /**
     * @dev Claims the betted NFTs 
     */
    function claimBetted() external {
        require(finalWinner != address(0x0) && finalWinner != _msgSender());
        require(bettersToNFTs[_msgSender()][0] != 0);

        IRabbitNFT(rabbitContract).transferFrom(address(this), _msgSender(), bettersToNFTs[_msgSender()][0]);
        IRabbitNFT(rabbitContract).transferFrom(address(this), _msgSender(), bettersToNFTs[_msgSender()][1]);
        IRewardToken(rewardToken).transfer(_msgSender(), 800 * (10 ** DECIMAL));
        delete bettersToNFTs[_msgSender()];
    }

    /**
     * @dev Selects the winner from `betters` list (only for DEFAULT_ADMIN_ROLE)
     */
    function selectPresent3Winner() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(block.timestamp >= initTime + BETTING_PERIOD, "");
        require(finalWinner == address(0x0), "The winner has already been announced");
       
        IRandomNumberConsumer(randomContract).getRandomNumber();
        finalWinner = betters[(IRandomNumberConsumer(randomContract).getResult() % betters.length)];
    }

    /**
     * @dev `finalWinner` calls the function and claims Present 3
     */
    function claimPresent3() external {
        require(_msgSender() == finalWinner, "msg.sender is not the winner");
        // Reward present 3
        IRabbitNFT(rabbitContract).burn(bettersToNFTs[_msgSender()][0]);
        IRabbitNFT(rabbitContract).burn(bettersToNFTs[_msgSender()][1]);
        IRewardToken(rewardToken).burn(address(this), 800);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
