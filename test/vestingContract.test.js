const VestingContract = artifacts.require("VestingContract");
const Token = artifacts.require("Token");

contract("VestingContract", accounts => {
    const [owner, user, partner, team] = accounts;

    let tokenInstance;
    let vestingInstance;

    beforeEach(async () => {
        tokenInstance = await Token.new();
        vestingInstance = await VestingContract.new(tokenInstance.address, 1000000);

        await tokenInstance.transfer(vestingInstance.address, 1000000);
    });

    it("should allow the owner to add beneficiaries", async () => {
        await vestingInstance.addBeneficiary(user, 0, Date.now(), { from: owner });
        const beneficiary = await vestingInstance.beneficiaries(user);
        assert.equal(beneficiary.amount.toNumber(), 500000); // 50% of total allocated tokens
    });

    it("should allow beneficiaries to claim vested tokens", async () => {
        const start = Math.floor(Date.now() / 1000);
        await vestingInstance.addBeneficiary(user, 0, start, { from: owner });

        // Fast-forward time to after the cliff
        await time.increase(10 * 30 * 24 * 60 * 60); // 10 months

        await vestingInstance.claimTokens({ from: user });
        const balance = await tokenInstance.balanceOf(user);
        assert(balance.toNumber() > 0, "Tokens not claimed correctly");
    });
});
