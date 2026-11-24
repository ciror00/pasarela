// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice NFT recibo de la pasarela de pago. Un token por pago.
contract PaymentReceipt is ERC721, ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    event ReceiptIssued(uint256 indexed tokenId, address indexed to, string uri);

    constructor(address initialOwner) ERC721("Payment Receipt", "RCPT") Ownable(initialOwner) {}

    function mintReceipt(address to, string calldata uri) external onlyOwner returns (uint256 tokenId) {
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        emit ReceiptIssued(tokenId, to, uri);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}