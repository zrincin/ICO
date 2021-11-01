//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./IERC20.sol";

// deployed at 0xdf760F30aE6D29a190596c668a346837a2509549 (Ropsten)

contract ZrinCinCoin is ERC20 {

    string public constant name = "ZrinCinCoin";
    string public symbol = "ZCC";
    uint public decimals = 5;
    uint tokenTotalSupply;

    address public creator;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;


    constructor() {
        tokenTotalSupply = 100000000000; // 1 million tokens (with 5 decimals)
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
        require(_tokens > 0);
        require(balances[msg.sender] >= _tokens);

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

        return true;
    }

}
