// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract VulnerableVault is ReentrancyGuard{
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external nonReentrant {
        uint256 amount = balances[msg.sender];          // Checks
        require(amount > 0, "nothing to withdraw");
        balances[msg.sender] = 0;                        // Effects
        (bool ok,) = msg.sender.call{value: amount}("");  // Interactions
        require(ok, "transfer failed");
    }
}