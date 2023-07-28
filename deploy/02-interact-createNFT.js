const { ethers, deployments, network } = require('hardhat');
const { NFTStorage, File } = require('nft.storage');
const fs = require('fs');

const IMAGE_FILE = './pexels-pixabay-106152.jpg';
const client = new NFTStorage({
  token:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweDk0OERkOTIxMDBjNDk1YTI0NTkwNGE4N2JGMTU1MGI3NkFBRDZjYTgiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTY4ODY0MjQxNTk2NCwibmFtZSI6Ik5GVCBQb3J0Zm9saW8ifQ.GH6K7ALQoX9vCzEJDmaHBn2t61UjenCMiDzzApTRPcE',
});

module.exports = async ({ deployments }) => {
  if (process.env.CREATE_NFT !== 'false') {
    const [deployer] = await ethers.getSigners();
    const NFTtoken = await deployments.get('NFTtoken');
    const contract = new ethers.Contract(NFTtoken.address, NFTtoken.abi, deployer);

    // ------------------------- Only functions
    const setSeries = async (name) => {
      const tx = await contract.setSeriesName(name);
      const response = await tx.wait();
    };
    const uploadToIPFS = async (filePath) => {
      const fileBuffer = fs.readFileSync(filePath);
      const file = new File([fileBuffer], 'image.jpg', { type: 'image/jpg' }); // change the type based on your file
      const metadata = await client.store({
        name: 'Money',
        description: 'NFT Image',
        image: file,
      });
      return metadata;
    };

    const createArtwork = async (tokenURI) => {
      const tx = await contract.createArtwork(tokenURI);
      const response = await tx.wait();

      return;
      const ArtworkCreatedEvent = response.events.find((e) => e.event === 'ArtworkCreated'); // something like this
      if (ArtworkCreatedEvent) {
        const tokenId = ArtworkCreatedEvent.args.tokenId.toString();
        const address = ArtworkCreatedEvent.args.owner.toString();
        console.log(`Artwork with ID ${tokenId} was created by ${address}.`);
      } else {
        console.error('ArtworkCreated event not found in the transaction receipt.');
      }
      return tokenId;
    };
    // ------------------------- Task

    console.log('creating NFT...');
    // Create Profile with name
    await setSeries('Mark');
    // Upload Image to IPFS
    const metadata = await uploadToIPFS(IMAGE_FILE);
    await createArtwork(metadata.url);

    console.log('NFT was created!');

    // ------------------------- Only functions
  }
};

module.exports.tags = ['all', 'interact'];
