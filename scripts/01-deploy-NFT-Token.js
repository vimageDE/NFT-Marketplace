const { network, ethers } = require('hardhat');
const { verify } = require('../utils/verify');

module.exports = async function ({ deployments }) {
  const { deploy, log } = deployments;
  const [deployer] = await ethers.getSigners();
  const localChain = network.config.local;

  if (localChain) {
    // Handle Local Mocks and Addresses
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

  if (!localChain && process.env.ETHERSCAN_TOKEN) {
    log('Verifying...');
    await verify(NFTtoken.address, args);
  }
  log('------------------------------');
};

module.exports.tags = ['all', 'nft'];
