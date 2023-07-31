const { network, ethers } = require('hardhat');

module.exports = async function ({ deployments }) {
  const { deploy, log } = deployments;
  const [deployer, additionalAddress] = await ethers.getSigners();
  const localChain = network.config.local;

  if (localChain) {
    log('Deploying Mocks...');
    // Deploy WETH Mock
    const args = [additionalAddress.address];

    const WETH = await deploy('WethMock', {
      from: deployer.address,
      args: args,
      log: true,
      waitConfirmations: 1,
    });

    log('WETH_Mock successfully deployed');
    log('------------------------------');
  }
};
