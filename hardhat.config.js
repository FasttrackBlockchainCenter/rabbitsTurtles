require("@nomiclabs/hardhat-waffle");
require('@nomiclabs/hardhat-ethers');
require('@openzeppelin/hardhat-upgrades');


const {
  INFURA_API,
  mnemonic
} = require('./secrets.json')
require('hardhat-docgen');

module.exports = {
  solidity: "0.8.4",
  docgen: {
    path: './docs',
    clear: true,
    runOnCompile: true,
  },
  networks: {
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_API}`,
      accounts: {
        mnemonic: mnemonic
      },
      
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${INFURA_API}`,
      accounts: {
        mnemonic: mnemonic
      },
      // blockGasLimit: 5

    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_API}`,
      accounts: {
        mnemonic: mnemonic
      },
      // blockGasLimit: 500000

    },
    matic: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: {
        mnemonic: mnemonic
      }, 
    }
  },
  gasReporter: {
    enabled: true
  }
};