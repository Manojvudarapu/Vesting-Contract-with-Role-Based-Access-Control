const VestingContract = artifacts.require("VestingContract");
const Token = artifacts.require("Token"); // Assume you have a token contract

module.exports = async function(deployer) {
    const tokenInstance = await Token.deployed();
    await deployer.deploy(VestingContract, tokenInstance.address, 1000000); // Example total allocated tokens
};


