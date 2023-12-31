const { network, ethers } = require('hardhat');
const { verify } = require('../utils/verify');

module.exports = async function ({ deployments }) {
  const { deploy, log } = deployments;
  const [deployer] = await ethers.getSigners();
  const localChain = network.config.local;

  let wethAddress;

  if (localChain) {
    // Handle Local Mocks and Addresses
    const weth = await deployments.get('WethMock');
    wethAddress = weth.address;
    log(`WETH contract address: ${wethAddress}`);
  } else {
    // Handle Live Addresses
  }

  const waitBlockConfirmations = network.config.blockConfirmations || 1;

  const args = ['NFT Market', 'ART'];

  const NFTtoken = await deploy('NFTtoken', {
    from: deployer.address,
    args: args,
    log: true,
    waitConfirmations: waitBlockConfirmations,
  });

  const Market = await deploy('Market', {
    from: deployer.address,
    args: [NFTtoken.address, wethAddress],
    log: true,
    waitConfirmations: waitBlockConfirmations,
  });

  if (!localChain && process.env.ETHERSCAN_TOKEN) {
    log('Verifying...');
    await verify(NFTtoken.address, args);
    await verify(Market.address, [NFT.address]);
  }
  log('------------------------------');
};

module.exports.tags = ['all', 'nft'];
