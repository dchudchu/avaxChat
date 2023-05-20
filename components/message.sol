// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Messaging {
    event MessageSent(address indexed from, string message);

    function sendMessage(string memory message) public {
        emit MessageSent(msg.sender, message);
    }
}
