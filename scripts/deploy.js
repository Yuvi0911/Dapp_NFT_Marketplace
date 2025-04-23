const {ethers} = require("hardhat");

async function main() {
    const Contract = await ethers.getContractFactory("TimelessNFT");

    const contract = await Contract.deploy(
        'YUVI',
        'UV',
        10,
        '0xeaed630De47C96F2511c24A6CD00586C0663446'
    );

    await contract.waitForDeployment(); 

    console.log("NFT contract deployed to:", await contract.getAddress());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
