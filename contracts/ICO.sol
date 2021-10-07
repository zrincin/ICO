//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address _tokenOwner) external view returns (uint balance);
    function transfer(address _to, uint _tokens) external returns (bool success);
    function allowance(address _tokenOwner, address _spender) external view returns (uint remaining);
    function approve(address _spender, uint _tokens) external returns (bool success);
    function transferFrom(address _from, address _to, uint _tokens) external returns (bool success);
    
    event Transfer(address indexed _from, address indexed _to, uint _tokens);
    event Approval(address indexed _tokenOwner, address indexed _spender, uint _tokens);
}


contract ZrinCinCoin is ERC20 {

    string public name = "ZrinCinCoin";
    string public symbol = "ZCC";
    uint public decimals = 5;
    uint public tokenTotalSupply;

    address public creator;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowances;


    constructor() {
        tokenTotalSupply = 1000000;
        creator = msg.sender;
        balances[creator] = tokenTotalSupply;
    }
    
    function totalSupply() public view override returns (uint) {
        return tokenTotalSupply;
    }

    function balanceOf(address _tokenOwner) public view override returns (uint balance) {
        return balances[_tokenOwner];
    }

    function transfer(address _to, uint _tokens) public override returns (bool success) {
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

    function transferFrom(address _from, address _to, uint _tokens) public override returns (bool success) {
        require(balances[_from] >= _tokens);
        require(allowances[_from][_to] >= _tokens);

        balances[_from] -= _tokens;
        balances[_to] += _tokens;
        allowances[_from][_to] -= _tokens;

        return true;
    }

}
