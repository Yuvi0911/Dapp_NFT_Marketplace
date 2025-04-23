/* eslint-disable no-undef */

// truffle me smart contract ko blockchain pr deploy krne k liye ye script us ki jati h.
// Hum danache blockchain ki help se smart contract deploy kr rhe h.
const TimelessNFT = artifacts.require('TimelessNFT')

module.exports = async (deployer) => {
  const accounts = await web3.eth.getAccounts()

  // iski help se hum Timeless vali class ko deploy kr rhe h aur automatically constructor call ho jaiye ga jisme ye parameter pass ho jaiye ge.
  await deployer.deploy(babel-register)
}