//SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

interface IERC20 {
    
    function totalSupply() external view returns (uint);
    function balanceOf(address _tokenOwner) external view returns (uint balance);
    function transfer(address _to, uint _tokens) external returns (bool success);
    function allowance(address _tokenOwner, address _spender) external view returns (uint remaining);
    function approve(address _spender, uint _tokens) external returns (bool success);
    function transferFrom(address _from, address _to, uint _tokens) external returns (bool success);
    
    event Transfer(address indexed _from, address indexed _to, uint _tokens);
    event Approval(address indexed _tokenOwner, address indexed _spender, uint _tokens);
}