const { util } = require('chai');
const { ethers } = require("hardhat")
const { utils } = require('ethers');
const fs = require('fs')

async function main() {
  let date = Date.now()
  // const [deployer, addr] = await ethers.getSigners();

  console.log('--------------------------------------- Deployment Started  ---------------------------------------')

  // --------------------------------------- RewardToken  ---------------------------------------
  const RewardToken = await ethers.getContractFactory("RewardToken");
  console.log('Deploying RewardToken...');
  const rewardTokenProxy = await upgrades.deployProxy(RewardToken, ['Reward token', "RT"], {
    initializer: "initialize",
    // unsafeAllowCustomTypes: true, 
    // unsafeAllowLinkedLibraries: true
  });
  console.log("RewardToken deployed to:", rewardTokenProxy.address, "\n");

  rewardTokenProxy.deployed()
  
  // --------------------------------------- Turtle  ---------------------------------------
  const TurtleFactory = await ethers.getContractFactory("TurtleNFT");
  console.log('Deploying Turtle...')
  const TurtleProxy = await upgrades.deployProxy(TurtleFactory, ["turtleTest", "YT"], {
    initializer: "initialize",
    // unsafeAllowCustomTypes: true, 
    // unsafeAllowLinkedLibraries: true
  });
  console.log("Turtle deployed to:", TurtleProxy.address, "\n");
  TurtleProxy.deployed()

  // --------------------------------------- RabbitNFT  ---------------------------------------
  const RabbitFactory = await ethers.getContractFactory("RabbitNFT");
  console.log('Deploying RabbitNFT...')
  const RabbitProxy = await upgrades.deployProxy(RabbitFactory, ["Rabbit", "rabbit", "https://ipfs.io/ipfs/QmUPmRqXjQZMxwW9aUGGBMjC3WUYRJvhE1VGZRCjBD8SCR?filename=1.json", "", "0xe8a817035773a622434d127f7154cf0a937bf52cc0ff1e7846eff80aaf9df32c", "0x808b45d27d0b60775b4e14f9e3de6d5f03f2c81ab5af819f977b20cde977b1ca"], {
    initializer: "initialize",
    unsafeAllowCustomTypes: true, 
    unsafeAllowLinkedLibraries: true
  });
  console.log("RabbitNFT deployed to:", RabbitProxy.address, "\n");
  RabbitProxy.deployed()

  // --------------------------------------- Random Consumer  ---------------------------------------
  // const RandomNumberFactory = await ethers.getContractFactory("RandomNumberConsumer");
  // console.log('Deploying RandomNumberConsumer...')
  // const RandomNumberProxy = await upgrades.deployProxy(RandomNumberFactory, [deployer.address], {
  //   initializer: "initialize",
  //   unsafeAllowCustomTypes: true, 
  //   unsafeAllowLinkedLibraries: true
  // });
  // console.log("RandomNumberConsumer deployed to:", RandomNumberProxy.address, "\n");
  // RandomNumberProxy.deployed()

  // --------------------------------------- NFT Stake  ---------------------------------------
  const NFTStakeFactory = await ethers.getContractFactory("NFTStake");
  console.log('Deploying NFTStake...')
  const NFTStakeProxy = await upgrades.deployProxy(NFTStakeFactory, [rewardTokenProxy.address, RabbitProxy.address], {
    initializer: "initialize",
    unsafeAllowCustomTypes: true, 
    unsafeAllowLinkedLibraries: true
  });
  console.log("NFTStake deployed to:", NFTStakeProxy.address, "\n");
  NFTStakeProxy.deployed()

  // --------------------------------------- NFTControl  ---------------------------------------
  
  const ControlFactory = await ethers.getContractFactory("NFTControl");
  console.log('Deploying NFTControl...');
  const controlProxy = await upgrades.deployProxy(ControlFactory, ['0x0000000000000000000000000000000000000000', RabbitProxy.address, '0x0000000000000000000000000000000000000000', 86400, "0x0"], {
    initializer: "initialize",
    unsafeAllowCustomTypes: true, 
    unsafeAllowLinkedLibraries: true
  });
  console.log("NFTControl deployed to:", controlProxy.address);
  controlProxy.deployed()

  // console.log('--------------------------------------- Deployment Finished ---------------------------------------')

  // await rewardTokenProxy.mint(deployer.address, 80000);
  // // await rewardTokenProxy.mint(RabbitProxy.address, );

  // let MINTER_ROLE = await RabbitProxy.MINTER_ROLE()

  // await controlProxy.preSale(deployer.address, 4, { value: utils.parseEther("0.22") });

  // await RabbitProxy.reveal();

  // let check = await RabbitProxy.tokenURI(1)


  // console.log(check.toString())
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.log(error);
    process.exit(1)
  })