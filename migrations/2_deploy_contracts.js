var MultiOwnershipWallet = artifacts.require("MultiOwnershipWallet");

module.exports = function (deployer) {
  deployer.deploy(MultiOwnershipWallet);
};
