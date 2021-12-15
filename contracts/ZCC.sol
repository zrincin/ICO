//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IERC20.sol";


contract ZrinCinCoin is IERC20 {

    string public constant name = "ZrinCinCoin";
    string public constant symbol = "ZCC";
    uint tokenTotalSupply = 100000000000; // 1 million tokens (with 5 decimals)
    uint public decimals = 5;
   
    address public creator;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;

    constructor() {
        creator = msg.sender;
        balances[creator] = tokenTotalSupply;
    }
    
    function totalSupply() public view override returns (uint) {
        return tokenTotalSupply;
    }

    function balanceOf(address _tokenOwner) public view override returns (uint balance) {
        return balances[_tokenOwner];
    }

    function transfer(address _to, uint _tokens) public virtual override returns (bool success) {
        require(balances[msg.sender] >= _tokens);

        balances[msg.sender] -= _tokens;
        balances[_to] += _tokens;

        emit Transfer(msg.sender, _to, _tokens);

        return true;
    }

    function allowance(address _tokenOwner, address _spender) public view override returns (uint remaining) {
        return allowances[_tokenOwner][_spender];
    }

    function approve(address _spender, uint _tokens) public override returns (bool success) {
        require(_spender != msg.sender);
        require(_tokens > 0);

        allowances[msg.sender][_spender] = _tokens;

        emit Approval(msg.sender, _spender, _tokens);

        return true;
    }

    function transferFrom(address _from, address _to, uint _tokens) public virtual override returns (bool success) {
        require(balances[_from] >= _tokens);
        require(allowances[_from][msg.sender] >= _tokens);

        balances[_from] -= _tokens;
        balances[_to] += _tokens;
        allowances[_from][msg.sender] -= _tokens;

        emit Transfer(msg.sender, _to, _tokens);

        return true;
    }
}