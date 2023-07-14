// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTtoken is ERC721 {
    address immutable i_owner;

    uint256 public s_tokenCounter;

    mapping(uint256 => string) public s_tokenIdToURI;
    mapping(uint256 => address) public s_tokenIdToCreator;
    mapping(uint256 => uint256) public s_currentTokenIndex;
    // NFT ownership
    mapping(address => uint256[]) public s_ownerToTokenIds;
    mapping(address => uint256[]) public s_creatorToTokenIds;
    // User Settings
    mapping(address => string) public s_addressToSeries;
    mapping(address => uint256) public s_addressToTitleIndex;

    event ArtworkCreated(uint256 indexed tokenId, address indexed owner);

    constructor(string memory tokenName, string memory tokenSymbol) ERC721(tokenName, tokenSymbol) {
        i_owner = msg.sender;
        s_tokenCounter = 0;
    }

    function setSeriesName(string memory seriesName) public {
        s_addressToSeries[msg.sender] = seriesName;
    }

    function setSeriesTitleIndex(uint256 titleIndex) public {
        require(titleIndex < s_creatorToTokenIds[msg.sender].length, "Index out of range");
        require(titleIndex != s_addressToTitleIndex[msg.sender], "Index is identical");
        s_addressToTitleIndex[msg.sender] = titleIndex;
    }

    function createArtwork(string memory newTokenURI) public returns (uint256) {
        // Set the item Id
        uint256 newTokenId = s_tokenCounter;
        // Create the NFT
        _safeMint(msg.sender, newTokenId);
        // Save the metadata uri to the token
        s_tokenIdToURI[newTokenId] = newTokenURI;
        // Save the owner to the token ID
        s_tokenIdToCreator[newTokenId] = msg.sender;
        // Save the token to the series of the user
        s_ownerToTokenIds[msg.sender].push(newTokenId);
        // Save the current Index of the token
        s_currentTokenIndex[newTokenId] = s_ownerToTokenIds[msg.sender].length - 1;
        // Save the token to his created tokens
        s_creatorToTokenIds[msg.sender].push(newTokenId);
        // Update the token counter
        s_tokenCounter = s_tokenCounter + 1;

        // Check if its the first NFT of the user
        if (s_ownerToTokenIds[msg.sender].length == 1) {
            // Set Title image if first NFT in series
        }

        emit ArtworkCreated(newTokenId, msg.sender);
        return newTokenId;
    }

    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override {
        // Check if minted
        bool minted = from == address(0);
        // Check if burned
        bool burned = to == address(0);
        if (!minted) {
            // Get the index of the token that needs to be delete from the user
            uint256 currentIndex = s_currentTokenIndex[firstTokenId];
            // Get the Token Id of the index that was last in the array and will be moved to the current Index spot
            uint256 movedTokenId = s_ownerToTokenIds[from][s_ownerToTokenIds[from].length - 1];
            // Move the last Token to the token that needs deletion and override it
            s_ownerToTokenIds[from][currentIndex] = movedTokenId;
            // Delete the last position of the array, since it is not needed anymore
            s_ownerToTokenIds[from].pop();
            // Update the index of the moved Token ID
            s_currentTokenIndex[movedTokenId] = currentIndex;
        }
        if (!burned && !minted) {
            // Add the token to its new owner
            s_ownerToTokenIds[to].push(firstTokenId);
            // Update the token index
            s_currentTokenIndex[firstTokenId] = s_ownerToTokenIds[to].length - 1;
        }
    }

    // View Functions
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return s_tokenIdToURI[tokenId];
    }

    function getArtworksOfOwner(address owner) public view returns (uint256[] memory) {
        return s_ownerToTokenIds[owner];
    }

    function getCreatedArtworks(address creator) public view returns (uint256[] memory) {
        return s_creatorToTokenIds[creator];
    }

    function getTokenAmount() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getSeriesName(address owner) public view returns (string memory) {
        return s_addressToSeries[owner];
    }

    function getSeriesTitleToken(address owner) public view returns (uint256) {
        return s_addressToTitleIndex[owner];
    }
}
