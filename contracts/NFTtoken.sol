// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ArtworkToken is ERC721 {
    address immutable i_owner;

    uint256 public s_tokenCounter;
    mapping(uint256 => string) public s_tokenIdToURI;
    mapping(address => uint256[]) public s_ownerToTokenIds;

    event ArtworkCreated(uint256 indexed tokenId, address indexed owner);

    constructor(string memory tokenName, string memory tokenSymbol) ERC721(tokenName, tokenSymbol) {
        i_owner = msg.sender;
        s_tokenCounter = 0;
    }

    function createArtwork(string memory newTokenURI) public returns (uint256) {
        // Set the item Id
        uint256 newTokenId = s_tokenCounter;
        // Create the NFT
        _safeMint(msg.sender, newTokenId);
        // Save the metadata uri to the token
        s_tokenIdToURI[newTokenId] = newTokenURI;
        // Save the token to the series of the user
        s_ownerToTokenIds[msg.sender].push(newTokenId);
        // Update the token counter
        s_tokenCounter = s_tokenCounter + 1;

        emit ArtworkCreated(newTokenId, msg.sender);
        return newTokenId;
    }

    // View Functions
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenIdToURI[tokenId];
    }

    function getArtworksOfOwner(address owner) public view returns (uint256[] memory) {
        return s_ownerToTokenIds[owner];
    }

    function getTokenAmount() public view returns (uint256) {
        return s_tokenCounter;
    }
}
