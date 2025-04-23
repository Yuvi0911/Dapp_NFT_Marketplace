require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/8YIbcw3LeWWZxEP58Yllha_oebANKTpu",
      accounts: ["6d5a53a0b1bc15d5ed87574cd69a9e020754b2e5befd72f027def3ba5152f7ff"]
    }
  },
  etherscan: {
    apiKey: {
      sepolia: '5G9P94KIE7IUMBR1A45E6THWD6CKD1VRPJ'
    }
  }
};
