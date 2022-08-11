// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.7.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.7.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.7.2/security/Pausable.sol";
import "@openzeppelin/contracts@4.7.2/access/Ownable.sol";
import "@openzeppelin/contracts@4.7.2/utils/Counters.sol";

/// @custom:security-contact happiness@litemint.com
contract LitemintPFP is ERC721, ERC721URIStorage, Pausable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => bytes32) private _hashes;

    constructor() ERC721("Litemint PFP", "LITEPFP") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.litemint.com/";
    }

    function safeMint(address to, string memory uri, bytes32 hash) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        _hashes[tokenId] = hash;
    }
   
    function burn(uint256 tokenId, bytes32 secret) public {
        require(_exists(tokenId), "Litemint PFP: Invalid token.");
        require(keccak256(abi.encodePacked(_hashes[tokenId])) == keccak256(abi.encodePacked(sha256(abi.encodePacked(secret)))), "Litemint PFP: Invalid secret.");
        _burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        // Litemint PFPs are non-transferable.
        require(from == address(0) || to == address(0), "Litemint PFP: non-transferrable token.");
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        delete _hashes[tokenId];
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
