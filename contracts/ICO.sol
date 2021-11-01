//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ZCC.sol";

// deployed at 0xdb79ecBC4C32C6C08f9F901d0cA8f3b2D65761fd (Ropsten)

contract ICO is ZrinCinCoin {
    address public manager;
    address payable public deposit;
    
    uint tokenPrice = 0.01 ether;  
    uint public goal = 10000 ether; // 100% of the total supply
    uint public raisedAmount; 
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp + 259200;    
    uint public minInvestment = 0.1 ether;
    uint public maxInvestment = 5 ether;
    
    uint public tokenTradeStart = saleEnd + 864000; 

    
    enum State { NOT_STARTED, RUNNING, ENDED, SUSPENDED} 
    State public ICOState;

    modifier managerOnly() {
        require(msg.sender == manager);
        _;
    }

    constructor(address payable _deposit) {
        deposit = _deposit;
        manager = msg.sender;
        ICOState = State.NOT_STARTED;
    }

    receive() payable external {
        invest();
    }

    event Invest(address _investor, uint _value, uint _tokens);

    function invest() payable public returns (bool) { 
        ICOState = getCurrentState();
        require(ICOState == State.RUNNING);
        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        
        raisedAmount += msg.value;
        require(raisedAmount <= goal);
        
        uint tokens = msg.value / tokenPrice;
 
      
        balances[msg.sender] += tokens;
        balances[creator] -= tokens; 
        deposit.transfer(msg.value); 
        
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
    }

    function transfer(address _to, uint _tokens) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart);
     
        ZrinCinCoin.transfer(_to, _tokens); 
        
        return true;
    }

    function transferFrom(address _from, address _to, uint _tokens) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart); 
       
        ZrinCinCoin.transferFrom(_from, _to, _tokens); 

        return true;
    }

    function getCurrentState() public view returns (State) {
        if (ICOState == State.SUSPENDED){
            return State.SUSPENDED;
        } else if (block.timestamp < saleStart) {
            return State.NOT_STARTED;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.RUNNING;
        } else {
            return State.ENDED;
        }
    }

    function stopICO() public managerOnly {
        ICOState = State.SUSPENDED;
    }

    function resumeICO() public managerOnly {
        ICOState = State.RUNNING;
    }

    function changeDepositAddress(address payable _newDeposit) public managerOnly {
        deposit = _newDeposit;
    }

     function burnTokens() public returns (bool) {
        ICOState = getCurrentState();
        require(ICOState == State.ENDED);
        
        balances[creator] = 0;
        
        return true;
    }
}