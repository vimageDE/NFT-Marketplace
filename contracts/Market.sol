// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract Market {
    uint256 private constant MIN_PRICE = 1000000000000000;

    IERC721 private immutable i_nft;
    mapping(address => uint256) s_addressToNonce;

    constructor(address nftAddress) {
        i_nft = IERC721(nftAddress);
    }

    function PurchaseNft(
        uint256 tokenId,
        address sigOwner,
        uint256 price,
        string memory typeOf,
        uint256 nonce,
        bytes memory signature
    ) public view returns (bool) {
        require(i_nft.ownerOf(tokenId) == msg.sender, "Not owner");

        address signerOfSignature = getSigner(tokenId, sigOwner, price, typeOf, nonce, signature);
        require(signerOfSignature == sigOwner, "Wrong Signature");

        // Do the purchase!
        return true;
    }

    function SellNft(uint256 tokenId, uint256 price) public {}

    // View Functions
    function getSigner(
        uint256 tokenId,
        address sigOwner,
        uint256 price,
        string memory typeOf,
        uint256 nonce,
        bytes memory signature
    ) public view returns (address) {
        // EIP 721 domain type /*
        /*string memory name = "NFT Portfolio";
        string memory version = "1";
        uint256 chainId = block.chainid;
        address verifyingContract = address(this); */

        // stringified types
        string
            memory EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
        string memory MESSAGE_TYPE = "Message(uint256 tokenId,uint256 nonce,string typeOf)";
        // memory MESSAGE_TYPE = "Message(uint256 tokenId, address sigOwner, uint256 price, string typeOf, uint256 nonce)";

        // hash to prevent signature collision
        bytes32 DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(abi.encodePacked(EIP712_DOMAIN_TYPE)),
                keccak256(abi.encodePacked("NFT Portfolio")),
                keccak256(abi.encodePacked("1")),
                block.chainid,
                address(this)
            )
        );

        // hash typed data
        // IMPORTANT!! the same data types MUST be packed together! it will not work to mix uint256, then string, then uint256!
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01", // backslash is needed to escape the character
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encodePacked(
                        keccak256(abi.encodePacked(MESSAGE_TYPE)),
                        tokenId,
                        nonce,
                        // price,
                        // sigOwner,
                        //
                        keccak256(abi.encodePacked(typeOf))
                        // nonce
                    )
                )
            )
        );

        return recover(hash, signature);
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // split signature
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (signature.length != 65) {
            return address(0);
        }
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }
        if (v < 27) {
            v += 27;
        }
        if (v != 27 && v != 28) {
            return address(0);
        } else {
            // verify
            return ecrecover(hash, v, r, s);
        }
    }

    function getNonce() public view returns (uint256) {
        return s_addressToNonce[msg.sender];
    }
}
