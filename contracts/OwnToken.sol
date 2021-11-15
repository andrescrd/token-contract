// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;
import "./ERC20Interface.sol";

contract Token is ERC20Interface {
    string public name = "Token";
    string public symbol = "TOK";
    uint public decimals = 8;
    uint public totalSupply;

    address public founder;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() {
        founder = msg.sender;
        totalSupply = 1000000;
        balances[founder] = totalSupply;
    }

    function balanceOf(address _owner) public override view returns (uint256 balance){
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public override returns (bool success){
        require(_value <= balances[msg.sender]);

        balances[_to] += _value;
        balances[msg.sender] -= _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint256 remaining){
        return allowed[_owner][_spender];
    }
    
    function approve(address _spender, uint256 _value) public override returns (bool success){
        require(balances[msg.sender] >= _value);
        require(_value > 0);

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool success){
        require(balances[_from] >= _value);
        require(allowed[_from][_to] >= _value);
        require(_value > 0);

        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][_to] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }
}