const ICO = artifacts.require("ICO");

module.exports = function (deployer, networks, accounts) {
  deployer.deploy(ICO, accounts[1], { from: accounts[0] });
};
