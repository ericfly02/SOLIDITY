pragma solidity 0.8.15;

/*
 This smart contract allows:
    - Deposits from everyone
    - Withdrawals only in the amount that was deposited by the person who likes to withdraw
*/

contract SmartWallet{

    uint public balance;

    function deposit() public payable{
        balance += msg.value;
    }

    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }

    function WithdrawAll() public {
        address payable to = payable(msg.sender);
        to.transfer(getContractBalance());
    }

    function WithdrawAddress(address payable to) public{
        to.transfer(getContractBalance());
    }
}