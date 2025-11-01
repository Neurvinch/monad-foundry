// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/MonadToken.sol";

contract MonadTokenTest is Test {
    MonadToken token;
    address deployer;
    address alice;
    address bob;
    address minter;
    address admin;

    function setUp() public {
        deployer = address(this);
        alice = address(0x1);
        bob = address(0x2);
        minter = address(0x3);
        admin = address(0x4);

        token = new MonadToken();

        // give roles to minter and admin (simulate using grantRole from deployer)
        // by default deployer has ADMIN & MINTER from constructor
        token.grantRole(token.MINTER_ROLE(), minter);
        token.grantRole(token.ADMIN_ROLE(), admin);
    }

    function testInitialSupply() public {
        uint256 supply = token.totalSupply();
        assertGt(supply, 0);
    }

    function testMintByMinter() public {
        vm.prank(minter);
        token.mint(alice, 100 * 10 ** token.decimals());
        assertEq(token.balanceOf(alice), 100 * 10 ** token.decimals());
    }

    function testCannotMintByNonMinter() public {
        vm.prank(bob);
        vm.expectRevert();
        token.mint(bob, 1 ether);
    }

    function testPausePreventsTransfer() public {
        // mint to alice
        vm.prank(minter);
        token.mint(alice, 10 * 10 ** token.decimals());

        vm.prank(admin);
        token.pause();

        vm.prank(alice);
        vm.expectRevert();
        token.transfer(bob, 1 * 10 ** token.decimals());
    }

    function testUnpauseAllowsTransfer() public {
        vm.prank(minter);
        token.mint(alice, 10 * 10 ** token.decimals());

        vm.prank(admin);
        token.pause();

        vm.prank(admin);
        token.unpause();

        vm.prank(alice);
        token.transfer(bob, 1 * 10 ** token.decimals());

        assertEq(token.balanceOf(bob), 1 * 10 ** token.decimals());
    }

    function testGrantAndRevokeRole() public {
        // deployer has default admin. grant role to bob then revoke
        token.grantRole(token.MINTER_ROLE(), bob);
        assertTrue(token.hasRole(token.MINTER_ROLE(), bob));

        token.revokeRole(token.MINTER_ROLE(), bob);
        assertFalse(token.hasRole(token.MINTER_ROLE(), bob));
    }
}
