// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {PaymentReceipt} from "../src/PaymentReceipt.sol";

contract PaymentReceiptTest is Test {
    PaymentReceipt receipt;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    string constant URI = "https://ipfs.io/ipfs/bafkreihctecijaiztacdqpi3lhuavlmrgkwldfcwgbefynswyjactihstu";

    function setUp() public {
        receipt = new PaymentReceipt(owner);
    }

    function test_OwnerMintsReceipt() public {
        vm.prank(owner);
        uint256 id = receipt.mintReceipt(alice, URI);
        assertEq(id, 0);
        assertEq(receipt.ownerOf(0), alice);
        assertEq(receipt.tokenURI(0), URI);
    }

    function test_RevertWhen_NonOwnerMints() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        vm.prank(alice);
        receipt.mintReceipt(alice, URI);
    }

    function testFuzz_IdsAreSequential(uint8 n) public {
        vm.startPrank(owner);
        for (uint256 i = 0; i < n; i++) {
            assertEq(receipt.mintReceipt(alice, URI), i);
        }
        vm.stopPrank();
        assertEq(receipt.balanceOf(alice), n);
    }

    // --- los dos tests propios que pide el lab ---

    function test_EmitsReceiptIssued() public {
        vm.expectEmit(true, true, false, true, address(receipt));
        emit PaymentReceipt.ReceiptIssued(0, alice, URI);
        vm.prank(owner);
        receipt.mintReceipt(alice, URI);
    }

    function test_RevertWhen_OwnerOfNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSelector(IERC721Errors.ERC721NonexistentToken.selector, 99));
        receipt.ownerOf(99);
    }
}