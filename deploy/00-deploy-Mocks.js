const { network, ethers } = require('hardhat');

module.exports = async function ({ deployments }) {
  const { deploy, log } = deployments;
  const [deployer, additionalAddress] = await ethers.getSigners();
  const localChain = network.config.local;

  if (localChain) {
    log('Deploying Mocks...');
    // Deploy WETH Mock
    const args = [additionalAddress.address];
    log('Additional Address for tokens: ', additionalAddress.address);

    const WETHDeployment = await deploy('WethMock', {
      from: deployer.address,
      args: args,
      log: true,
      waitConfirmations: 1,
    });

    const WETH = new ethers.Contract(WETHDeployment.address, WETHDeployment.abi, deployer);

    const currentBalance = await WETH.balanceOf(deployer.address);
    log('WETH on dev account: ', currentBalance.toString());

    log('WETH_Mock successfully deployed');
    log('------------------------------');
  }
};
