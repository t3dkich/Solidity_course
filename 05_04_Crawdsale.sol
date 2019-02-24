pragma solidity >=0.4.22 <0.6.0;

contract Crawdsale {
    enum State { Crawdsale, Exchange }
    
    struct Buyer {
        uint amount;
        bool hasHeld;
    }
    
    address payable _owner;
    uint public _bornOn;
    
    State public _state;
    
    mapping(address => Buyer) private _allUsers;
    
    event depositEther(address investor, uint amount);
    event ownerWithdraw(address owner, uint amount);
    
    constructor() public {
        _owner = msg.sender;
        _state = State.Crawdsale; 
        _bornOn = now;
    }
    
    modifier justOwner {
        require(_owner == msg.sender, 'Not owner of the contract!');
        _;
    }
    
    modifier exactEth(uint value) {
        require(value % 1000000000000000000 == 0, 'Amount must be exact Ether or more (1 eth, 2 eth, .... eth');
        _;
    }
    
    modifier exact(uint value) {
        require(value % 1 == 0, 'Must be real number!');
        _;
    }
    
    modifier setState {
        if (uint(_state) == 0) {
            if (now > _bornOn + 5 minutes) {
                _state = State.Exchange;
            }
        }
        _;
    }
    
    modifier justExchangeMode {
        require(uint(_state) == 1, 'You must wait to enter in Exchange stage!');
        _;
    }
    
    modifier oneYearAfterBorn {
        require(now > _bornOn + 365 days, 'Can withdraw one year after conctract creation!');
        _;
    }
    
    modifier validAmount(uint amount) {
        require(_allUsers[msg.sender].amount >= amount, 'You do not have enough tokens!');
        _;
    }
    
    modifier validUser {
        require(_allUsers[msg.sender].hasHeld == true, 'Unknown address!');
        _;
    }
    
    function receiveEther() 
        payable
        public
        exactEth(msg.value)
        setState
    {
        if (uint(_state) == 0) {
            crawdsaleOffer();
        } else {
            exchangeOffer();
        }
        emit depositEther(msg.sender, msg.value);
    }
    
    function transferTokensInContract(address reciever, uint amount)
        public  
        payable
        validUser
        justExchangeMode
        exact(amount)
        validAmount(amount)
        setState
    {
        if (!_allUsers[reciever].hasHeld) {
            _allUsers[reciever].hasHeld = true;
        }
        _allUsers[msg.sender].amount -= amount;
        _allUsers[reciever].amount += amount;
    }
    
    function withraw(uint amount) 
        public 
        payable
        justOwner
        oneYearAfterBorn
    {
        _owner.transfer(amount);
        emit ownerWithdraw(_owner, amount);
    }
    
    function exchangeOffer() private {
        address tempUser = msg.sender;
        _allUsers[tempUser].amount += msg.value / 1000000000000000000;
        if (!_allUsers[tempUser].hasHeld) {
            _allUsers[tempUser].hasHeld = true;
        }
    }
    
    function crawdsaleOffer() private {
        address tempUser = msg.sender;
        _allUsers[tempUser].amount += (msg.value / 1000000000000000000) * 5;
        if (!_allUsers[tempUser].hasHeld) {
            _allUsers[tempUser].hasHeld = true;
        }
    }
    
    function checkTokens(address addresss) public view returns(uint) {
        return _allUsers[addresss].amount;
    }
    
}