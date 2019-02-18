pragma solidity >=0.4.22 <0.6.0;

contract Auction {
    
    address payable _owner;
    uint public _startTime;
    uint public _endTime;
    bool public _canceled;
    
    address _highestBidder;
    uint _highestBid;
    mapping(address => uint) _allBids;
    
    constructor(uint startAfterSeconds, uint duration)
        public
        payable
        validInitialParameters(startAfterSeconds, duration)
    {
        _startTime = now + startAfterSeconds;
        _endTime = now + startAfterSeconds + duration;
        _owner = msg.sender;
        _canceled = false;
        emit createOwner(msg.sender);
    }
    
    event createOwner(address indexed owner);
    event cancel(string indexed phrase, bool indexed closed);
    event bidInfo(address indexed bidder, uint indexed value);
    event withdraw(address indexed selfAddress, address indexed receiver, uint indexed value);
    
    modifier validInitialParameters(uint startAfterSeconds, uint duration) {
        require(startAfterSeconds > 0, 'Seconds must be a positive number!');
        require(duration > 0, 'Duration must be positive number!');
        _;
    }
    
    modifier active {
        require(now > _startTime && now < _endTime, 'Contract is not active!');
        _;
    }
    
    modifier justOwner {
        require(msg.sender == _owner, 'This address does not belong to the owner!');
        _;
    }
    
    modifier notOwner {
        require(msg.sender != _owner, 'Closed service for owner of the contract!');
        _;
    }
    
    modifier notCanceled {
        require(_canceled == false, 'Contract is canceled!');
        _;
    }
    
    modifier notExpired {
        require(now < _endTime, 'Contract is expired!');
        _;
    }
    
    modifier expiredOrCanceled {
        require(now > _endTime || true == _canceled, 'Contract is not expired or canceled');
        _;
    }
    
    modifier existingBidder {
        require(_allBids[msg.sender] > 0, 'This address has no bids on auction');
        _;
    }
    
    modifier notWinner {
        require(msg.sender != _highestBidder, 'This address won the auction');
        _;
    }
    
    function placeBid()
        public 
        payable
        active
        notOwner 
        notCanceled
        notExpired
    {
        uint currBid = msg.value + _allBids[msg.sender];
        require(currBid > _highestBid, 'Bid must be higher than the highest one!');
        _placeBid();
        _changeHighest(currBid);
    }
    
    function checkHighestBidder()
        public
        notCanceled
        returns (address)
    {
        emit bidInfo(_highestBidder, _highestBid);
        return _highestBidder;
    }
    
    function cancelAuction() 
        public
        justOwner
        notCanceled
        notExpired
    {
        _cancelAuchtion();
    }
    
    function withdrawFunds() 
        public  
        expiredOrCanceled
    {
        if (_canceled) {
            _withdrawOnCanceled();
        } else {
            _withdrawOnExpired();
        }
    }
    
    function _changeHighest(uint currBid)
        internal
    {
        _highestBid = currBid;
        _highestBidder = msg.sender;
        emit bidInfo(_highestBidder, _highestBid);
    }
    
    function _cancelAuchtion() 
        internal 
    {
        _canceled = true;
        emit cancel('Auction is canceled!', _canceled);
    }
    
    function _placeBid() 
        internal 
    {
        _allBids[msg.sender] += msg.value;
        emit bidInfo(msg.sender, _allBids[msg.sender]);
    }
    
    function _withdrawOnCanceled() 
        internal
        existingBidder
        notOwner
    {
        msg.sender.transfer(_allBids[msg.sender]);
        emit withdraw(address(0), msg.sender, _allBids[msg.sender]);
        _allBids[msg.sender] = 0;
    }
    
    function _withdrawOnExpired()
        internal
    {
        if (msg.sender != _owner) {
            _payTheBidder();
        } else {
            _payTheOwner();
        }
    }
    
    function _payTheBidder()
        internal
        existingBidder
        notWinner
    {
        msg.sender.transfer(_allBids[msg.sender]);
        emit withdraw(address(0), msg.sender, _allBids[msg.sender]);
        _allBids[msg.sender] = 0;
    }
    
    function _payTheOwner() 
        internal
        justOwner
    {
        _owner.transfer(_highestBid);
        emit withdraw(address(0), msg.sender, _allBids[_highestBidder]);
        _allBids[_highestBidder] = 0;
    }
    
}