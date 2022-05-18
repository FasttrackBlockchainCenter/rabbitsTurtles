## Contracts ##
 - ***NFTContract.sol***  | NFT generator contract
    - **Used Plugins**
        - AccessControl
        - ERC721
        - ERC721URIStorage
        - IERC20
    - **Functions**
        1. pre_sale | Mints token with some **Metadata**
        2. public_sale | Mints token with some **Metadata**
        3. getAllOwners | Returns the address of each owner of each sold token.
 - ***NFTControl.sol***
    - **Used Plugins**
        - AccessControl
        - ERC20
        - ERC20Burnable
        - IERC721
    - **Functions**
        1. mint | Mints reward tokens for staked NFT
        2. isStakeholder | Returns true if provided address is staker
        3. stakeOf | Returns stake details for provided address
        4. stake | **Locks** provided NFT in contract until locktime end
        5. claim | **Claims** staked NFT and reward for staking
 - ***RewardToken.sol***
    - **Used Plugins**
        - ERC20

*For better code understanding check the contract files and comments.*

#### Roles ####
There are **2 Roles** in contract:
 - ***DEFAULT_ADMIN_ROLE***
    This is the role for owner / deployer of the contract.
 - ***MINTER_ROLE***
    Is required for `pre_sale` function call.


## How to run the code ##
### Initialization of the project ###
```npm install``` - Installs all packages required for project

### Contracts Testing ###
```npx hardhat test``` - Runs all unit tests from folder *test*

### Contracts Deployment ###
```npx hardhat run scripts/deploy.js``` - Deploys the contract to local blockchain
```npx hardhat run scripts/deploy.js --network kovan --network kovan``` - Deploys the contract to Kovan testnet
```npx hardhat run scripts/deploy.js --network kovan --network mainnet``` - Deploys the contract to Ethereum mainnet

***BEFORE DEPLOYING TO TESTNET OR MAINNET CONFIGURE THE `secrets.json` FILE***