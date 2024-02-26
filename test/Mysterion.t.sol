// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Mysterion.sol";

contract TestERC721 is Test {
    Mysterion public erc721;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    address public alice = address(1);
    address public bob = address(2);
    address public cat = address(3);

    function setUp() public {
        erc721 = new Mysterion(alice);
    }

    function testBaseURI() public {
        string memory uri = erc721.baseURI();
        assertEq(uri, "https://api.mysterion.com/api/v1/token/");
    }

    function testSafeMint() public {
        vm.prank(alice);
        erc721.safeMint(alice); // tokenId 0 mint

        address zero_owner = erc721.ownerOf(0);
        uint256 alice_balance = erc721.balanceOf(alice);
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
        assertEq(uri, "https://api.mysterion.com/api/v1/token/0");

        vm.prank(alice);
        erc721.safeMint(bob);
        string memory uri2 = erc721.tokenURI(1);
        assertEq(uri2, "https://api.mysterion.com/api/v1/token/1");
    }

    function testSetBaseURI() public {
        vm.prank(alice);
        erc721.setBaseURI("https://api.mysterion.com/api/v2/token/");

        string memory uri = erc721.baseURI();
        assertEq(uri, "https://api.mysterion.com/api/v2/token/");

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
        uint256 bob_balance = erc721.balanceOf(bob);
        assertEq(bob_balance, 6);
    }

    function testTransferFrom() public {
        vm.prank(alice);
        erc721.safeMint(alice);
        address owner_token_0 = erc721.ownerOf(0);
        uint256 alice_balance = erc721.balanceOf(alice);
        assertEq(alice, owner_token_0);
        assertEq(alice_balance, 1);

        vm.prank(alice); // transaction caller is set to alice
        erc721.safeTransferFrom(alice, bob, 0);

        owner_token_0 = erc721.ownerOf(0);
        assertEq(bob, owner_token_0);
        alice_balance = erc721.balanceOf(alice);
        uint256 bob_balance = erc721.balanceOf(bob);
        assertEq(alice_balance, 0);
        assertEq(bob_balance, 1);
    }

    function testApprove() public {
        vm.prank(alice);
        erc721.safeMint(bob); // token 0

        vm.prank(bob);
        erc721.approve(alice, 0);
        address owner_token_0 = erc721.ownerOf(0);
        assertEq(bob, owner_token_0);
        assertNotEq(alice, owner_token_0);

        vm.prank(bob);
        address _approved = erc721.getApproved(0);
        assertEq(alice, _approved);
    }

    function testSetApprovalForAll() public {
        vm.prank(alice);
        erc721.safeMint(bob);

        vm.prank(bob);
        erc721.setApprovalForAll(alice, true);
        bool _approved = erc721.isApprovedForAll(bob, alice);
        assertEq(_approved, true);
    }

    function testBurn() public {
        vm.prank(alice);
        erc721.safeMint(bob);

        vm.prank(alice);
        vm.expectRevert(); // "Only token owner can burn the token"
        erc721.burn(0);

        vm.prank(bob);
        vm.expectCall(address(erc721), abi.encodeCall(erc721.burn, 0));
        erc721.burn(0);
        uint256 bob_balance = erc721.balanceOf(bob);
        assertEq(bob_balance, 0);

        vm.expectRevert(); // "Token does not exist"
        erc721.ownerOf(0);
    }

    function testOnlyPauserPause() public {
        vm.expectRevert(); // "Only pauser can pause the contract"
        vm.prank(bob);
        erc721.pause();

        vm.expectCall(address(erc721), abi.encodeCall(erc721.pause, ()));
        vm.prank(alice);
        erc721.pause();
        bool paused = erc721.paused();
        assertEq(paused, true);
    }

    function testGrantRole() public {
        vm.expectRevert(); // "Only admin can grant role"
        vm.prank(bob);
        erc721.grantRole(keccak256("PAUSER_ROLE"), alice);

        vm.expectCall(address(erc721), abi.encodeCall(erc721.grantRole, (keccak256("PAUSER_ROLE"), bob)));
        vm.prank(alice);
        erc721.grantRole(keccak256("PAUSER_ROLE"), bob);
        bool hasRole = erc721.hasRole(keccak256("PAUSER_ROLE"), bob);
        assertEq(hasRole, true);
    }

    function testRevokeRole() public {
        vm.prank(alice);
        erc721.grantRole(keccak256("PAUSER_ROLE"), bob);
        bool hasRole = erc721.hasRole(keccak256("PAUSER_ROLE"), bob);
        assertEq(hasRole, true);

        vm.expectRevert(); // "Only admin can revoke role"
        vm.prank(bob);
        erc721.revokeRole(keccak256("PAUSER_ROLE"), alice);

        vm.prank(alice);
        erc721.revokeRole(keccak256("PAUSER_ROLE"), bob);
        hasRole = erc721.hasRole(keccak256("PAUSER_ROLE"), bob);
        assertEq(hasRole, false);

        vm.prank(bob);
        bool _isPaused = erc721.paused();
        assertEq(_isPaused, false);
    }
}
