const { ethers, deployments, network } = require('hardhat');
const fs = require('fs');

const NFT_ADDRESS_FILE = '../NFT-Marketplace_frontend/constants/contractAddresses.json';
const NFT_ABI_FILE = '../NFT-Marketplace_frontend/constants/abi.json';

const MARKET_ADDRESS_FILE = '../NFT-Marketplace_frontend/constants/contractAddresses_Market.json';
const MARKET_ABI_FILE = '../NFT-Marketplace_frontend/constants/abi_Market.json';

const WETH_ADDRESS_FILE = '../NFT-Marketplace_frontend/constants/contractAddresses_Weth.json';
const WETH_ABI_FILE = '../NFT-Marketplace_frontend/constants/abi_Weth.json';

module.exports = async ({}) => {
  // const { log } = deployments;
  const localChain = network.config.local;

  if (process.env.UPDATE_FRONT_END) {
    console.log('Updating front end...');
    await updateNftAddress();
    await updateNftAbi();
    await updateMarketAddress();
    await updateMarketAbi();
    console.log('Finished updating front end');
    if (localChain) {
      await updateWethAddress();
      await updateWethAbi();
    }
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

async function updateWethAddress() {
  const contract = await deployments.get('WethMock');
  const chainId = network.config.chainId.toString();
  const currentAddresses = JSON.parse(fs.readFileSync(WETH_ADDRESS_FILE, 'utf8'));
  currentAddresses[chainId] = [contract.address];

  fs.writeFileSync(WETH_ADDRESS_FILE, JSON.stringify(currentAddresses));
}

async function updateNftAbi() {
  const contract = await deployments.get('NFTtoken');
  fs.writeFileSync(NFT_ABI_FILE, JSON.stringify(contract.abi));
}

async function updateMarketAbi() {
  const contract = await deployments.get('Market');
  fs.writeFileSync(MARKET_ABI_FILE, JSON.stringify(contract.abi));
}

async function updateWethAbi() {
  const contract = await deployments.get('Market');
  const chainId = network.config.chainId.toString();
  const currentAbi = JSON.parse(fs.readFileSync(WETH_ABI_FILE, 'utf8'));
  currentAbi[chainId] = [contract.abi];
  fs.writeFileSync(WETH_ABI_FILE, JSON.stringify(currentAbi));
}

module.exports.tags = ['all', 'frontend'];
