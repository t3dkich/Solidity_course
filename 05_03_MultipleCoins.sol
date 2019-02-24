pragma solidity >=0.4.22 <0.6.0;

contract MultipleCoins {
    struct Coins {
        uint RedCoins;
        uint GreenCoins;
    }
    
    mapping(address => Coins) public _users;
    
    address public _owner;
    
    event transferInfo(address fromUser, address toUser, uint amount, string coinType);
    
    modifier hasGreen(uint value) {
        require(_users[msg.sender].GreenCoins >= value, 'You do not have enough green coins!');
        _;
    }
    
    modifier hasRed(uint value) {
        require(_users[msg.sender].RedCoins >= value, 'You do not have enough red coins!');
        _;
    }
    
    constructor() public {
        _owner = msg.sender;
        _users[_owner].RedCoins = 10000;
        _users[_owner].GreenCoins = 5000;
    }
    
    function sendGreen(address to, uint value) 
        public 
        hasGreen(value)
    {
        address _sender = msg.sender;
        _users[_sender].GreenCoins -= value;
        _users[to].GreenCoins += value;
        emit transferInfo(_sender, to, value, 'GreenCoin');
    }
    
    function sendRed(address to, uint value) 
        public 
        hasRed(value)
    {
        address _sender = msg.sender;
        _users[_sender].RedCoins -= value;
        _users[to].RedCoins += value;
        emit transferInfo(_sender, to, value, 'RedCoin');
    }
}