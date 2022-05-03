// BankDex is the contract that will simulate a bank, which will allows the users to make deposits & withdraws, ask for loans and pay their loans.
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20 {
    // events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    // functions
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract BANKDEX {

    using SafeMath for uint;

    address private owner;

    address public MTRX_Token;
    address public RMTRX_Token;                         // To issue interest to the users who have some amount of MTRX token deposited in the bank

    address[] public stakers;                           // Store in this array of addresses the clients who have made a deposit
    mapping(address => uint) public depositBalance;     // Track the deposit balance of the bank's clients
    mapping(address => bool) public hasDeposit;         // Keep track of the client's status deposits ... If their balance is greater than 0, the bool value will be true, which means that the user has some MTRX deposited in the Bank

    mapping(address => bool) public activeLoan;         // Initialize set to false, when a user asks for a loan, this mapping will be set to true for that user, and will be set only and only until the loan is liquidated.
    mapping(address => uint) public userDebt;          // When a user requests a loan, this mapping will save the total amount of debt that the user have, and as the user pays his debt, the total amount of debt will be decreasing accordingly

    constructor(address _MTRX, address _RMTRX) {
        owner = msg.sender;
        MTRX_Token = _MTRX;
        RMTRX_Token = _RMTRX;
    }

    // If Ethers are sent with data
    fallback() external payable {
        revert("This contract is not expected to receive ETHERs, your transaction will be reverted");
    }

    // If Ethers are sent without data
    receive() external payable {
        revert("This contract is not expected to receive ETHERs, your transaction will be reverted");
    }

    modifier onlyOwner(uint _amount) {
        require(msg.sender == owner, "Only the contract's owner can execute this function");
        _;
    }

    modifier enoughFundsAndNoLoan(uint _amount) {
        require(activeLoan[msg.sender] == false, "Reverting transaction, user has an active loan");
        require(depositBalance[msg.sender] - _amount >= 0, "Reverting transaction, user has not enough funds to perform this action");
        _;
    }

    /*
    function getTotalSupply(address _token) public view returns(uint) {
        return IERC20(_token).totalSupply();
    }
    */

    function getAllowance() public view returns(uint) {
        return IERC20(MTRX_Token).allowance(msg.sender,address(this));
    }

    function depositToken(uint _amount) public {
        depositBalance[msg.sender] = depositBalance[msg.sender].add(_amount);
        // Discovered bug: Previous to execute this function, the Bank's contract must have already been approved with X amount of tokens to spend on behalf of the token's owner
        IERC20(MTRX_Token).transferFrom(msg.sender,address(this),_amount);
        if (hasDeposit[msg.sender] == false) {
            stakers.push(msg.sender);
        }
        hasDeposit[msg.sender] = true;
    }

    function withdraw(uint _amount) public enoughFundsAndNoLoan(_amount) {
        depositBalance[msg.sender] = depositBalance[msg.sender].sub(_amount);
        IERC20(MTRX_Token).transfer(msg.sender,_amount);
        // if current balance is equals to 0, set to false the hasDeposit mapping for this user...
        if(depositBalance[msg.sender] == 0) {
            hasDeposit[msg.sender] = false;
        }
    }

    // Visiblity modifier should be private, but for development purposes in Remix will be set to public!
    function issueInterest() public onlyOwner() {
        for(uint i = 0; i < stakers.length; i++) {
            address staker = stakers[i];
            uint balanceStaker = depositBalance[staker];
            uint interests;

            if(balanceStaker > 0 || balanceStaker <= 999){
                // Issue a 3% of interests
                interests = balanceStaker.div(100).mul(3);
            } else if(balanceStaker >= 1000 || balanceStaker <= 4999){
                // Issue a 5% of interests
                interests = balanceStaker.div(100).mul(5);
            } else if(balanceStaker >= 5000 || balanceStaker <= 9999){
                // Issue a 7% of interests
                interests = balanceStaker.div(100).mul(7);
            } else if(balanceStaker >= 10000 || balanceStaker <= 24999){
                // Issue a 10% of interests
                interests = balanceStaker.div(100).mul(10);
            } else {
                // Issue a 12% of interests
                interests = balanceStaker.div(100).mul(12);
            }
            // Send the interests token to the user
            IERC20(RMTRX_Token).transfer(msg.sender,interests);

        }
    }

    // Visiblity modifier should be private, but for development purposes in Remix will be set to public!
    function refillInterestsToken(uint _amount) public onlyOwner() {
        // Transfer from the owner's balance to the Banks contract X amount of RMTRX token
        // Will hit the same bug as in the Deposit function - Before executing this function, make sure that in the RMTRX contract the Bank's contract has already been approved as the Spender of the owner's tokens
        IERC20(RMTRX_Token).transferFrom(msg.sender,address(this),_amount);
    }

    function askLoan(uint _amount) public enoughFundsAndNoLoan(_amount) {
        activeLoan[msg.sender] = true;
        uint totalInterest;
        if(_amount > 0 || _amount <= 999){
            // Charge a 12% of interests
            totalInterest = _amount.div(100).mul(12);
        } else if(_amount >= 1000 || _amount <= 4999){
            // Charge a 10% of totalInterest
            totalInterest = _amount.div(100).mul(10);
        } else if(_amount >= 5000 || _amount <= 9999){
            // Charge a 8% of totalInterest
            totalInterest = _amount.div(100).mul(8);
        } else if(_amount >= 10000 || _amount <= 24999){
            // Charge a 6% of totalInterest
            totalInterest = _amount.div(100).mul(6);
        } else {
            // Charge a 5% of totalInterest
            totalInterest = _amount.div(100).mul(5);
        }
        userDebt[msg.sender] = _amount + totalInterest;
    }



}
