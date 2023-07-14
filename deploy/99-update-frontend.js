const { ethers, deployments, network } = require('hardhat');
const fs = require('fs');

const NFT_ADDRESS_FILE = '../NFT-Marketplace_frontend/constants/contractAddresses.json';
const NFT_ABI_FILE = '../NFT-Marketplace_frontend/constants/abi.json';

const MARKET_ADDRESS_FILE = '../NFT-Marketplace_frontend/constants/contractAddresses_Market.json';
const MARKET_ABI_FILE = '../NFT-Marketplace_frontend/constants/abi_Market.json';

module.exports = async ({}) => {
  // const { log } = deployments;

  if (process.env.UPDATE_FRONT_END) {
    console.log('Updating front end...');
    await updateNftAddress();
    await updateNftAbi();
    await updateMarketAddress();
    await updateMarketAbi();
    console.log('Finished updating front end');
  }
};

async function updateNftAddress() {
  const contract = await deployments.get('NFTtoken');
  const chainId = network.config.chainId.toString();
  const currentAddresses = JSON.parse(fs.readFileSync(NFT_ADDRESS_FILE, 'utf8'));
  if (chainId in currentAddresses) {
    if (!currentAddresses[chainId].includes(contract.address)) {
      currentAddresses[chainId].push(contract.address);
    }
  } else {
    currentAddresses[chainId] = [contract.address];
  }

  fs.writeFileSync(NFT_ADDRESS_FILE, JSON.stringify(currentAddresses));
}

async function updateMarketAddress() {
  const contract = await deployments.get('Market');
  const chainId = network.config.chainId.toString();
  const currentAddresses = JSON.parse(fs.readFileSync(MARKET_ADDRESS_FILE, 'utf8'));
  if (chainId in currentAddresses) {
    if (!currentAddresses[chainId].includes(contract.address)) {
      currentAddresses[chainId].push(contract.address);
    }
  } else {
    currentAddresses[chainId] = [contract.address];
  }

  fs.writeFileSync(MARKET_ADDRESS_FILE, JSON.stringify(currentAddresses));
}

async function updateNftAbi() {
  const contract = await deployments.get('NFTtoken');
  fs.writeFileSync(NFT_ABI_FILE, JSON.stringify(contract.abi));
}

async function updateMarketAbi() {
  const contract = await deployments.get('Market');
  fs.writeFileSync(MARKET_ABI_FILE, JSON.stringify(contract.abi));
}

module.exports.tags = ['all', 'frontend'];
