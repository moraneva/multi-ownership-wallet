const MultiOwnershipWallet = artifacts.require("MultiOwnershipWallet");

contract('MultiOwnershipWallet', (accounts) => {
    it('should initialize correctly', async () =>{
        const walletInstance = await MultiOwnershipWallet.new([accounts[0], accounts[1], accounts[2]], [3333,3333,3334], 6666);

        await web3.eth.sendTransaction({from: accounts[0], to: walletInstance.address, value: web3.utils.toWei('10', 'ether')});

        const distributionId = (await walletInstance.submitDistribution.call(web3.utils.toWei('5','ether'))).toNumber();
        
        assert.equal(distributionId, 0);

        await walletInstance.confirmDistribution(distributionId, {from: accounts[0]});
        await walletInstance.confirmDistribution(distributionId, {from: accounts[1]});

        console.log(await walletInstance.isConfirmed.call(distributionId));
        console.log((await walletInstance.requiredConfirmationPercentageForDistribution.call()).toNumber());
        assert.equal(web3.utils.toWei('5', 'ether'), await web3.eth.getBalance(walletInstance.address));
    });
})