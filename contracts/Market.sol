// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error Market_WrongSignature();
error Market_NonceUsed();
error Market_Expired();
error Market_NotOwner();
error Market_IsAlreadOwner();

contract Market {
    uint256 private constant MIN_PRICE = 1000000000000000;

    IERC721 private immutable i_nft;
    IERC20 private immutable i_weth;
    mapping(uint256 => bool) s_nonceIsUsed;

    event Transfer(address indexed from, address indexed to, uint256 tokenId);

    struct Message {
        uint256 tokenId;
        address user;
        uint256 nonce;
        uint256 price;
        string typeOf;
        uint256 timestamp;
    }

    constructor(address nftAddress, address wethAddress) {
        i_nft = IERC721(nftAddress);
        i_weth = IERC20(wethAddress);
    }

    function BuyNft(Message memory message, bytes memory signature) external {
        message.typeOf = "sale";

        address tokenOwner = i_nft.ownerOf(message.tokenId);
        if (tokenOwner != message.user) revert Market_NotOwner();
        if (message.timestamp < block.timestamp) revert Market_Expired();
        if (tokenOwner == msg.sender) revert Market_IsAlreadOwner();
        if (s_nonceIsUsed[message.nonce] == true) revert Market_NonceUsed();
        address ownerOfSignature = getSigner(message, signature);
        if (ownerOfSignature != tokenOwner) revert Market_WrongSignature();

        // Send Money
        i_weth.transferFrom(msg.sender, tokenOwner, message.price);
        // Transfer NFT
        i_nft.safeTransferFrom(tokenOwner, msg.sender, message.tokenId);

        s_nonceIsUsed[message.nonce] = true;
    }

    function SellNft(
        /*uint256 tokenId,
        address offerOwner,
        uint256 price,
        uint256 nonce,
        uint256 timestamp, */
        Message memory message,
        bytes memory signature
    ) external {
        // Set Message type as "offer"
        message.typeOf = "offer";

        address tokenOwner = i_nft.ownerOf(message.tokenId);
        if (tokenOwner != msg.sender) revert Market_NotOwner();
        if (message.timestamp < block.timestamp) revert Market_Expired();
        if (message.user == msg.sender) revert Market_IsAlreadOwner();
        if (s_nonceIsUsed[message.nonce] == true) revert Market_NonceUsed();
        address ownerOfSignature = getSigner(message, signature);
        if (ownerOfSignature != message.user) revert Market_WrongSignature();

        // Get Money
        i_weth.transferFrom(message.user, tokenOwner, message.price);
        // Sell NFT
        i_nft.safeTransferFrom(tokenOwner, message.user, message.tokenId);

        s_nonceIsUsed[message.nonce] = true;
    }

    // View Functions
    function getSigner(Message memory message, bytes memory signature) public view returns (address) {
        // address user = msg.sender;

        // stringified types
        string
            memory EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
        string
            memory MESSAGE_TYPE = "Message(uint256 tokenId,uint256 nonce,uint256 price,uint256 timestamp,string typeOf,address user)";

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
        // IMPORTANT!! abi.encode with MULTIPLE values/types. But with a SINGLE string, you MUST use abi.encodePacked
        // this is relevant for the abi.encode that comes AFTER the DOMAIN_SEPARATOR!
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01", // backslash is needed to escape the character
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        keccak256(abi.encodePacked(MESSAGE_TYPE)),
                        message.tokenId,
                        message.nonce,
                        message.price,
                        message.timestamp,
                        keccak256(abi.encodePacked(message.typeOf)),
                        message.user
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
}
