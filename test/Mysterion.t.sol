// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import "forge-std/Test.sol";
import "../src/Mysterion.sol";


contract TestERC721 is Test {
    Mysterion public erc721;
    
    event Transfer(address indexed from, address indexed to, uint indexed id);
    event Approval(address indexed owner, address indexed spender, uint indexed id);
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    address public alice = address(1);
    address public bob = address(2);
    address public cat = address(3);

    function setUp() public {
        erc721 = new Mysterion(alice);
    }

    function testBaseURI() public {
        string memory uri = erc721.baseURI();
        assertEq(uri,"https://api.mysterion.com/api/v1/token/");
    }

    function testSafeMint() public {
        vm.prank(alice);
        erc721.safeMint(alice); // tokenId 0 mint
        
        address zero_owner = erc721.ownerOf(0);
        uint alice_balance = erc721.balanceOf(alice);
        assertEq(alice_balance, 1);
        assertEq(alice, zero_owner);
    }

    function testOnlyMinterSafeMint() public {
        vm.startPrank(bob);
        
        vm.expectRevert(); // "Only minter can mint the token"
        erc721.safeMint(bob);
        
        vm.stopPrank();
    }

    function testTokenURI() public {
        vm.prank(alice);
        erc721.safeMint(alice);
        
        string memory uri = erc721.tokenURI(0);
        assertEq(uri,"https://api.mysterion.com/api/v1/token/0");

        vm.prank(alice);
        erc721.safeMint(bob);
        string memory uri2 = erc721.tokenURI(1);
        assertEq(uri2,"https://api.mysterion.com/api/v1/token/1");
    }

    function testSetBaseURI() public {
        vm.prank(alice);
        erc721.setBaseURI("https://api.mysterion.com/api/v2/token/");
        
        string memory uri = erc721.baseURI();
        assertEq(uri,"https://api.mysterion.com/api/v2/token/");

        vm.prank(alice);
        erc721.safeMint(alice);
        string memory uri_token_0 = erc721.tokenURI(0);
        assertEq(uri_token_0, "https://api.mysterion.com/api/v2/token/0");
    }

    function testGetBalance() public {
        vm.startPrank(alice);
        erc721.safeMint(bob);
        erc721.safeMint(bob);
        erc721.safeMint(bob);
        erc721.safeMint(bob);
        erc721.safeMint(bob);
        erc721.safeMint(bob);
        vm.stopPrank();
        uint bob_balance = erc721.balanceOf(bob);
        assertEq(bob_balance, 6);
    }

    function testTransferFrom() public {
        vm.prank(alice);
        erc721.safeMint(alice);
        address owner_token_0 = erc721.ownerOf(0);
        uint alice_balance = erc721.balanceOf(alice);
        assertEq(alice, owner_token_0);
        assertEq(alice_balance, 1);

        vm.prank(alice); // transaction caller is set to alice
        erc721.safeTransferFrom(alice, bob, 0);

        owner_token_0 = erc721.ownerOf(0);
        assertEq(bob, owner_token_0);
        alice_balance = erc721.balanceOf(alice);
        uint bob_balance = erc721.balanceOf(bob);
        assertEq(alice_balance, 0);
        assertEq(bob_balance, 1);
    }   
}