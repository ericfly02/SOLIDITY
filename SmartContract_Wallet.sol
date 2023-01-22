pragma solidity 0.8.15;

/*
REQUIREMENTS:
1- The wallet has one owner
2- The wallet should be able to receive funds, no matter what
3- It is possible for the owner to spend funds on any kind of address, no matter if its a so-called Externally Owned Account (EOA - with a private key), or a Contract Address.
4- It should be possible to allow certain people to spend up to a certain amount of funds.
5- It should be possible to set the owner to a different address by a minimum of 3 out of 5 guardians, in case funds are lost.
*/

contract Consumer{
    function getBalance() public view returns(uint){
        return address(this).balance; 
    } 
    function deposit() public payable{ }
}


contract SmartContractWallet{

    address payable public owner;

    mapping(address => uint) public allowance;
    mapping(address => bool) public isAllowedToSend;

    mapping(address => bool) public guardians;
    address payable nextOwner;
    // way to find that the guardian didn't voted yet on this address
    mapping(address => mapping(address => bool)) nextOwnerGuardianVotedBool;
    uint guardiansResetCount;
    uint public constant confirmationsFromGuardiansForReset = 3;

    constructor(){
        owner = payable(msg.sender);
    }

    // Set some guardians just in case the person lost his private key
    function setGuardian(address _guardian, bool _isGuardian) public{
        require(msg.sender == owner, "you are not the owner, aborting");
        guardians[_guardian] = _isGuardian;
    }

    function proposeNewOwner(address payable _newOwner) public{
        require(guardians[msg.sender], "You're not guardian of this wallet, aborting");
        require(nextOwnerGuardianVotedBool[_newOwner][msg.sender] == false, "You already voted, aborting");
        if (_newOwner != nextOwner){
            nextOwner = _newOwner;
            guardiansResetCount = 0;
        }

        guardiansResetCount++;

        if(guardiansResetCount >= confirmationsFromGuardiansForReset){
            owner = nextOwner;
            nextOwner = payable(address(0));
        }
    }

    function setAllowance(address _for, uint _amount) public {
        require(msg.sender == owner, "you are not the owner, aborting");
        allowance[msg.sender] = _amount;

        if(_amount > 0){
            isAllowedToSend[_for] = true;
        }
        else{
            isAllowedToSend[_for] = false;
        }
    }

    function transfer(address payable _to, uint _amount, bytes memory _payload) public returns(bytes memory){
        //require(msg.sender == owner, "You're not the owner, aborting");
        if(msg.sender != owner){
            require(isAllowedToSend[msg.sender], "You are not allowed to send anything from this smart contract, aborting");
            require(allowance[msg.sender] >= _amount, "You are trying to send more than you are allowed to, aborting");
            allowance[msg.sender] -= _amount;
        }

        (bool success, bytes memory returnData) = _to.call{value:_amount}(_payload);
        require(success, "Aborting, call was not successful");
        return returnData;
    }

    receive() external payable {}
}