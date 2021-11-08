// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;
import "./ERC20Interface.sol";

contract Token is ERC20Interface {
    string public name = "Token";
    string public symbol = "TOK";
    uint public decimals = 8;
    uint public override totalSupply;

    address public founder;
    mapping(address => uint) balances;

    constructor() {
        founder = msg.sender;
        totalSupply = 1000000;
        balances[founder] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        return balances[tokenOwner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(_value <= balances[msg.sender]);

        balances[to] += _value;
        balances[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
}