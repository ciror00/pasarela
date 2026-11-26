// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// SOLO PARA PRACTICA: contiene una vulnerabilidad a proposito. No desplegar.
contract VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender]; // 1. lee el saldo
        require(amount > 0, "nothing to withdraw"); // 2. valida
        (bool ok,) = msg.sender.call{value: amount}(""); // 3. ENVÍA el ETH
        require(ok, "transfer failed");
        balances[msg.sender] = 0; // 4. recién ahora pone el saldo en cero
    }
