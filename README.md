# Bank-System
This project is about to create a Smart Contract that simulates most of the common actions of a Bank, such as receive deposits, allow user to withdraw their funds, pay interests to the users who have money deposited in the bank, allow user ask for loans &amp; admit payments for the active loans

# Contract behavior explain in detail

Bank's Contract

- Deposit
	- Issue Interest
- Withdraw
	- Charge fees when withdrawing
	- If the user has a loan, it can't make a withdraw
- Ask for a Loan
	- Validate user has enough funds to cover the requested amount [depositBalance minus amount must be >= to 0)
	- Deny permission to the user to withdraw its funds while the loan has not been paid
	- Charge Interests - Interests will be calculated at a fix rate
	- Charge fees
- Pay a loan
	- Update total debt
	- Once the debt is 0, grant permission to the user to withdraw funds again

- The Bank's contract will:
	- Have two public addresses that represent the two types of tokens that will be supported by the bank - Both variables will be initialized in the constructor.
		- One token will be the token that will be deposited & withdrawn
		- The other token will be the token that represents the interests earned by the users for having their tokens deposited in the bank!!!
			- Note: The interests the user needs to pay for a loan will be charged as the token one
	- Create an array of addresses to store the stakers - Clients who have made a deposit
	- Create a mapping that represents the depositBalance of the stakes (address => uint)
	- Create a mapping that helps us to validate if a user has made a deposit (address => bool)
	- Have a constructor that receives 2 addresses as arguments - Such addresses will be used to initialize the public addresses that represent the tokens supported by the bank
	- Require the IERC20 Interface to interact with the contracts of the two tokens that are already deployed in the blockchain
		- Define the interface using all the functions of the Token's contracts
			- totalSupply(), balanceOf(), transfer(), allowance(), approve(), transferFrom()
		- Don't forget the events
			- Transfer event & Approval event
```
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
```

-  Bank's contract functions:
	- depositToken(uint amount)
		- Update the depositBalance mapping according to the amount that is been deposited. 
		- Will implement the transferFrom() function of the IERC20 interface to execute that same function in the context of the token contract
			- The transfer will be made from the user's address to the bank's contract
		- This function will deposit an X amount of tokens from the user into the bank's contract
		- If the mapping that validates if a user has made a deposit is set to false, that means that this is the first deposit from that user, which means that we need to store that user in the stakes array
		- Outside the if statement, update the mapping to validate if a user has made a deposit and set it to true, by doing it, when the same user makes another deposit, the contract won't push again the same user to the stakes array because the user is already stored in it.
		- 
```
function depositToken(uint _amount) public {
    // Implementing the transferFrom() function
    IERC20(tokenAddress).transferFrom(from,to,amount);
    
}
```

	- withdraw(uint amount)
		- Validate that a user has no loan, if it has, the user can't make a withdraw
		- Validate that a user has enough balance to withdraw the requested amount
		  Get the current user's balance - Before executing the transfer() function 
		- Update the depositBalance mapping according to the amount that was withdrawn
		- Implement the transfer() function of the IERC20 interface to execute that same function in the context of the token contract
			- transfer() function will transfer the requested amount to the user's address
		- Validate if the balance minus the withdrawn amount is 0, if so, update the hasDeposited mapping and set it to false for the user address

```
function withdraw(uint _amount) public {
    // first lines of code
    
    IERC20(tokenAddress).transfer(to,amount);

    // last lines of code
}
```

	- issueInterests()
		- Use the onlyOwner() modifier to ensure that only the contract's owner can execute this function
		- iterate over the stakers array and per each staker:
			- get the address
			- get the balance
			- Issue interests based on the number of tokens it holds:
				- >0 to 999 tokens: issue a 3% interest on the total balance
				- 1k to 4999 tokens: issue a 5% interest on the total balance
				- 5k to 9999 tokens: issue a 7% interest on the total balance
				- 10k to 24999 tokens: issue a 10% interest on the total balance
				- over 25k tokens: issue a 12% interest on the total balance
			- Issue interest means to transfer the corresponding amount of tokens to the user address:
				- Implement the transfer() function of the IERC20 interface to execute that same function in the context of the token contract number 2 (The token for the interests)[RMTRX]
```
function issueInterest() internal onlyOwner {
    
}
```

	- refillInterestsToken(uint _amount)
		- Use the onlyOwner() modifier to ensure that only the contract's owner can execute this function
		- The contract's owner (must be the same owner of the token & the bank) will be able to refill the Bank's contract with the tokens to deliver to the stakers (RMTRX) as their reward for staking the transactional token (MTRX)

	- askLoan(uint _amount)
		- Users can't request a loan bigger than the number of tokens that they hold in the Bank (deposited Tokens)
			- (totalBalance - requestedAmount) must be >= 0
		- Users can't request a loan if they already have a loan
		- If the user is approved to get a loan, update the mapping activeLoan for the user to true
		- Calculate the interests to pay - Fixed interests rate
			- >0 to 999 tokens:  12% interest on the total amount
			- 1k to 4999 tokens: 10% interest on the total amount
			- 5k to 9999 tokens: 8% interest on the total amount
			- 10k to 24999 tokens: 6% interest on the total amount
			- over 25k tokens: 5% interest on the total amount
		- Update the mapping userDebt for the user to reflect the total amount that the user will need to pay, including interests


```
function askLoan(uint _amount) public {

}
```

	- payLoan()
		- The funds will be taken from the depositBalance of the user, which means that we need to validate that the user has enough funds in its depositBalance to pay the requested amount 
		- Validate if the user has an active loan, otherwise, revert the transaction
		- If the two above validations are passed, subtract from the depositBalance mapping of the user the number of tokens that the user is paying 
		- Proceed to update the userDebt mapping by reducing the debt according to the number of tokens that the user paid
		- Validate if the userDebt is 0, if so, update the activeLoan mapping for the user and set it to false, which means that the user has not an active loan anymore - The user has paid its debt
			- If the userDebt is not 0 yet, don't update the activeLoan mapping, must still be true
```
function payLoan(uint _amount) public {

}
```


---
```
Notes

- virtual functions
	- If you do not want a function to be overridden, leave off the virtual marker.
	
- Bug when depositing tokens in the Bank - approve() function
	- I still need to ressearch how to be able to call the approve() function from the token's contracts since the Bank contract.
		- This is required to approve the Bank contract as the token's spender for the user's addresses and be able to execute the transferFrom() function, such function will take the tokens from the user account and deposit them into the Bank contract
```
