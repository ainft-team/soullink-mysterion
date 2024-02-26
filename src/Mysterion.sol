// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "openzeppelin-contracts/contracts/utils/Strings.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract Mysterion is ERC721, ERC721Enumerable, ERC721Pausable, ERC721Burnable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _nextTokenId;
    string public baseURI;

    event updateBaseURI(string newBaseURI);

    constructor(address defaultAdmin) ERC721("Mysterion", "MYST") {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, defaultAdmin);
        baseURI = "https://api.mysterion.com/api/v1/token/";
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override(ERC721) returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newBaseURI) public onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        require(bytes(newBaseURI).length > 0, "Mysterion: baseURI is empty");
        string memory oldBaseURI = baseURI;
        require(
            keccak256(abi.encodePacked(oldBaseURI)) != keccak256(abi.encodePacked(newBaseURI)),
            "Mysterion: newBaseURI is the same as current baseURI"
        );

        baseURI = newBaseURI;
        emit updateBaseURI(newBaseURI);
        return true;
    }
}
