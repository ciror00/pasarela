// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {PagoToken} from "../src/PagoToken.sol";

contract PagoTokenTest is Test {
    PagoToken token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");

    function setUp() public {
        token = new PagoToken(owner, 1_000_000e6);
    }

    function test_InitialSupplyGoesToOwner() public view {
        assertEq(token.balanceOf(owner), 1_000_000e6);
        assertEq(token.decimals(), 6);
    }

    function test_ApproveAndTransferFrom() public {
        vm.prank(owner);
        token.approve(alice, 50e6);
        vm.prank(alice);
        token.transferFrom(owner, alice, 30e6);
        assertEq(token.allowance(owner, alice), 20e6);
    }

    function test_MintRevertsIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, alice));
        token.mint(alice, 1);
    }

    function testFuzz_Transfer(uint256 amount) public {
        amount = bound(amount, 0, token.balanceOf(owner));
        vm.prank(owner);
        token.transfer(alice, amount);
        assertEq(token.balanceOf(alice), amount);
    }

    // --- Parte C: los tres tests que suman los alumnos ---

    function test_Transfer_EmitsEvent() public {
        vm.expectEmit(true, true, false, true, address(token));
        emit IERC20.Transfer(owner, alice, 10e6);
        vm.prank(owner);
        token.transfer(alice, 10e6);
    }

    function test_RevertWhen_TransferExceedsBalance() public {
        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, alice, 0, 1e6)
        );
        vm.prank(alice);
        token.transfer(owner, 1e6);
    }

    function test_Permit_SetsAllowance() public {
        (address signer, uint256 pk) = makeAddrAndKey("signer");
        uint256 value = 25e6;
        uint256 deadline = block.timestamp + 1 hours;

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                signer, alice, value, token.nonces(signer), deadline
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);

        token.permit(signer, alice, value, deadline, v, r, s);

        assertEq(token.allowance(signer, alice), value);
        assertEq(token.nonces(signer), 1);
    }
}