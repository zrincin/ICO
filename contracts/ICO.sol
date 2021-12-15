//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ZCC.sol";


contract ICO is ZrinCinCoin {
    
    address public manager;
    address payable public deposit;
    address public tokenAddress;

    struct Sale {
        address payable investor;
        uint quantity;
    }

    Sale[] public sales;

    mapping(address => bool) private approvedInvestors;
    mapping(address => uint) private investedAmount;

    uint public tokenPrice = 0.01 ether;  
    uint public goal = 5000 ether; // 50% of the total supply
    uint public minInvestment = 0.1 ether;
    uint public maxInvestment = 50 ether;
    uint public raisedAmount; 
    uint public saleStart;
    uint public saleEnd;   
    uint public tokenTradeStart;
    
    enum State { NOT_STARTED, RUNNING, ENDED, SUSPENDED} 
    State ICOState;

    modifier managerOnly() {
        require(msg.sender == manager, "ERROR: Only manager allowed");
        _;
    }

    modifier onlyInvestors() {
        require(approvedInvestors[msg.sender] == true, "ERROR: Only approved investors allowed");
        _;
    }

    constructor(address payable _deposit) {
        manager = msg.sender;
        deposit = _deposit;
        ICOState = State.NOT_STARTED;
        tokenAddress = address(new ZrinCinCoin());
    }

    receive() payable external {
        invest();
    }

    // Only KYC-ed investors are allowed
    function whitelist(address _investor) external managerOnly {
        require(ICOState == State.NOT_STARTED, "ICO already started");
        approvedInvestors[_investor] = true;
    }

    function startICO(uint _duration, uint _lockupPeriod) external managerOnly {
       ICOState = getCurrentState(); 
       require(ICOState == State.NOT_STARTED, "ERROR: ICO already started");
       saleStart = block.timestamp;
       saleEnd = saleStart + _duration;
       tokenTradeStart = saleEnd + _lockupPeriod;
       ICOState = State.RUNNING;
   }

    event Invest(address _investor, uint _value, uint _tokens);

    function invest() payable public onlyInvestors returns (bool success) { 
        ICOState = getCurrentState();
        require(ICOState == State.RUNNING, "ERROR: ICO must be active");
        require(msg.value >= minInvestment && msg.value <= maxInvestment, "ERROR: Amount too low or too high");

        require(raisedAmount <= goal, "ERROR: Not enough tokens left");
        raisedAmount += msg.value;
        
        investedAmount[msg.sender] += msg.value;
        require(investedAmount[msg.sender] <= maxInvestment, "ERROR: Max investment exceeded");
       
        uint tokens = msg.value / tokenPrice;
        uint totalSupply = ZrinCinCoin(tokenAddress).totalSupply();
        assert(tokens <= totalSupply);

        sales.push(Sale(payable(msg.sender), tokens));
 
        balances[msg.sender] += tokens;
        balances[creator] -= tokens; 
        deposit.transfer(msg.value); 
        
        emit Invest(msg.sender, msg.value, tokens);
        
        return true;
    }

    function transfer(address _to, uint _tokens) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart, "ERROR: Lock-up period, tokens not released yet" );
     
        ZrinCinCoin.transfer(_to, _tokens); 
        
        return true;
    }

    function transferFrom(address _from, address _to, uint _tokens) public override returns (bool success) {
        require(block.timestamp > tokenTradeStart, "ERROR: Lock-up period, tokens not released yet"); 
       
        ZrinCinCoin.transferFrom(_from, _to, _tokens); 

        return true;
    }

    function getCurrentState() public view returns (State) {
        if (ICOState == State.SUSPENDED){
            return State.SUSPENDED;
        } else if (block.timestamp <= saleStart || saleEnd == 0) {
            return State.NOT_STARTED;
        } else if (block.timestamp >= saleStart && block.timestamp <= saleEnd) {
            return State.RUNNING;
        } else {
            return State.ENDED;
        }
    }

    function stopICO() external managerOnly {
        ICOState = getCurrentState(); 
        require(ICOState == State.RUNNING, "ERROR: ICO already stopped or not yet started");
        ICOState = State.SUSPENDED;
    }

     function resumeICO() external managerOnly {
        ICOState = getCurrentState(); 
        require(ICOState == State.SUSPENDED, "ERROR: ICO already running or not yet started");
        ICOState = State.RUNNING;
    }

    function changeDepositAddress(address payable _newDeposit) external managerOnly {
        deposit = _newDeposit;
    }

     function burnTokens() external managerOnly returns (bool success) {
        ICOState = getCurrentState();
        require(ICOState == State.ENDED, "ERROR: ICO still in progress");
        
        balances[creator] = 0;
        
        return true;
    }
}