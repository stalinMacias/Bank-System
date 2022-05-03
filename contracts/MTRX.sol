// MTRX will be the token that works as a currency, meaning, will be used to make deposits, withdraws, ask for loans (you'll receive MTRX when you ask a loan) and pay loans
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MTRX is ERC20 {
    constructor () ERC20("MTRX","MTRX") {
        _mint(msg.sender,1000000000000000000000000); // 1 million tokens
    }
}
