// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./VRFConsumerBaseUpgradable.sol";

contract RandomNumberConsumer is VRFConsumerBaseUpgradable, Initializable {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;
    
    address private owner;
    
    function initialize(address _owner)
        public
        initializer
    {
        VRFConsumerBaseUpgradable._VRF_INIT(
            0xa555fC018435bef5A13C6c6870a9d4C11DEC329C, // VRF Coordinator
            0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06  // LINK Token
        );

        keyHash = 0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186;
        fee = 0.1 * 10 ** 18; 
        
        owner = _owner;
    }
    
    /** 
     * Requests randomness 
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return VRFConsumerBaseUpgradable.requestRandomness(keyHash, fee, 512348532185321541312182);
    }

    function getResult() public view returns(uint256) {
        return randomResult;
    } 

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
