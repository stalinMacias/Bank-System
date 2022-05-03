//RMTRX wil be the Reward token, meaning, will be the token that will be issued to the investors/users that have depositted some amount of MTRX token in the Bank
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RMTRX is ERC20 {
    constructor () ERC20("MTRX","MTRX") {
        _mint(msg.sender,1000000000000000000000000); // 1 million tokens
    }
}
