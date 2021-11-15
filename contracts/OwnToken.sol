// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "./ERC20Interface.sol";

contract  OwnToken is ERC20Interface {
    string public name ="OwnToken";
    string public symbol = "OTK";
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

contract CryptosICO is OwnToken {
    address public admin;
    address payable public deposit;
    uint public tokenPrice = 0.001 ether;  // 1 token = 0.001 ether, 1 ether = 1000 token
    uint public hardCap = 300 ether;
    uint public raiseAmount;
    uint public saleStart = block.timestamp;
    uint public saleEnd = block.timestamp +  604800; // 7 days
    uint public tokenTradeStart = saleEnd + 604800; // 7 days after sale end
    uint public maxInvestment = 5 ether;
    uint public minInvestment = 0.1 ether;

    enum State { BeforeStart, Running, AfterEnd, Halted }
    State public icoState;

    event Invest(address investor, uint investedAmount, uint tokens);

    constructor(address payable _deposit) {
        admin = msg.sender;
        deposit = _deposit;
        icoState = State.BeforeStart;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    function halt() onlyAdmin public {
        icoState = State.Halted;
    }

    function resume() onlyAdmin public {
        icoState = State.Running;
    }

    function changeDeposit(address payable _deposit) onlyAdmin public {
        deposit = _deposit;
    }

    function getCurrentState() public view returns (State) {
        if(icoState == State.Halted){
            return State.Halted;
        }
        else if(block.timestamp < saleStart){
            return State.BeforeStart;
        }       
        else if(block.timestamp >= saleStart && block.timestamp <= saleEnd){
            return State.Running;
        } 
        else{
            return State.AfterEnd;
        }
    }

    function invest() payable public returns(bool){
        icoState = getCurrentState();
        require(icoState == State.Running);

        require(msg.value >= minInvestment && msg.value <= maxInvestment);
        raiseAmount += msg.value;
        require(raiseAmount <= hardCap);

        uint tokens = msg.value / tokenPrice;
        balances[msg.sender] += tokens;
        balances[founder] -= msg.value;
        deposit.transfer(msg.value);

        emit Invest(msg.sender, msg.value, tokens);

        return true;
    }

    receive() payable external{
        invest();
    }
}