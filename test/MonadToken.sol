// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "forge-std/Test.sol";
import "../src/MonadToken.sol";

contract MonadTokenTest is Test {
    MonadToken token;
    address admin = address(0xA);
    address minter = address(0xB);
    address user = address(0xC);

    function setUp() public {
        vm.prank(admin);
        token = new MonadToken();

        vm.startPrank(admin);
        token.grantRole(token.MINTER_ROLE(), minter);
        vm.stopPrank();
    }

    function testInitialMint() public {
        assertEq(token.totalSupply(), 1000 * 10 ** token.decimals());
    }

    function testMint() public {
        vm.startPrank(minter);
        token.mint(user, 500 * 10 ** token.decimals());
        vm.stopPrank();
        assertEq(token.balanceOf(user), 500 * 10 ** token.decimals());
    }

    function testPauseAndUnpause() public {
        vm.startPrank(admin);
        token.pause();
        vm.stopPrank();

        vm.expectRevert();
        vm.prank(user);
        token.transfer(admin, 1);

        vm.startPrank(admin);
        token.unpause();
        vm.stopPrank();

        vm.prank(admin);
        token.transfer(user, 1);
        assertEq(token.balanceOf(user), 1);
    }
}
