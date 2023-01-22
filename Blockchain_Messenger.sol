pragma solidity 0.8.15;

// it can store a string on the blockchain 
// it is readable for everyone
// it's readable only for the person who deployed the smart contract in the first place 
// How many time the message was updated 

contract BlockchainMessenger{

    address public contractDeployer;
    string public myMessage;
    uint public msg_updated;

    constructor() public{
        contractDeployer = msg.sender;
    }
  
    function update_message(string memory _myMessage) public{
        if(msg.sender != contractDeployer){
            revert();
        }
        myMessage = _myMessage;
        msg_updated++;
    }
}

