const { ethers, network } = require('hardhat');
const fs = require('fs');

const NFT_ADDRESS_FILE = '../NFT-Marketplace_frontend/constants/contractAddresses.json';
const NFT_ABI_FILE = '../NFT-Marketplace_frontend/constants/abi.json';

module.exports = async ({ deployments }) => {
  const { log } = deployments;

  if (process.env.UPDATE_FRONT_END) {
    log('Updating front end...');
    await updateNftAddress();
    await updateNftAbi();
    log('Finished updating front end');
  }
};

async function updateNftAddress() {
  const contract = await ethers.getContract('NFTtoken');
  const chainId = network.config.chainId.toString();
  const currentAddresses = JSON.parse(fs.readFileSync(NFT_ADDRESS_FILE, 'utf8'));
  if (chainId in currentAddresses) {
    if (!currentAddresses[chainId].includes(contract.address)) {
      currentAddresses[chainId].push(raffle.address);
    }
  } else {
    currentAddresses[chainId] = [raffle.address];
  }
}

async function updateNftAbi() {
  const contract = await ethers.getContract('NFTtoken');
  fs.writeFileSync(NFT_ABI_FILE, contract.interface.format(ethers.utils.FormatTypes.json));
}

module.exports.tags = ['all', 'frontend'];
