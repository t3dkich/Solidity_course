pragma solidity >=0.4.22 <0.6.0;

contract Auction {
    
    address payable _owner;
    uint public _startTime;
    uint public _endTime;
    bool public _canceled;
    
    address _highestBidder;
    uint _highestBid;
    uint _bidDifference;
    mapping(address => uint) _allBids;
    mapping(address => uint) _biddersLatestBid;
    
    constructor(uint startAfterSeconds, uint duration, uint bidDifference)
        public
        payable
        validInitialParameters(startAfterSeconds, duration, bidDifference)
    {
        _startTime = now + startAfterSeconds;
        _endTime = now + startAfterSeconds + duration;
        _owner = msg.sender;
        _canceled = false;
        _bidDifference = bidDifference;
        emit createOwner(msg.sender);
    }
    
    event createOwner(address indexed owner);
    event cancel(string indexed phrase, bool indexed closed);
    event bidInfo(address indexed bidder, uint indexed value, uint indexed blockTime);
    event withdraw(address indexed selfAddress, address indexed receiver, uint indexed value);
    
    modifier validInitialParameters(uint startAfterSeconds, uint duration, uint bidDifference) {
        require(startAfterSeconds > 0, 'Seconds must be positive number!');
        require(duration > 0, 'Duration must be positive number!');
        require(bidDifference > 0, 'Bid difference must be positive number!');
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
	
	modifier higherBid(uint currBid) {
	    if (_highestBid > 0) {
	        require(currBid >= _highestBid + _bidDifference, 'Bid is too low to be accepted!');
	    }
		_;
	}
	
	modifier after1hour {
	    if (_biddersLatestBid[msg.sender] > 0) {
	        require(now > _biddersLatestBid[msg.sender] + 1 hours, 'You have to wait 1 hour before placing new bid!');   
	    }
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
		higherBid(msg.value + _allBids[msg.sender])
		after1hour
    {
        _placeBid();
        _changeHighest(_allBids[msg.sender]);
    }
    
    function checkHighestBidder()
        public
        notCanceled
    {
        emit bidInfo(_highestBidder, _highestBid, _biddersLatestBid[msg.sender]);
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
        _biddersLatestBid[msg.sender] = now;
        emit bidInfo(msg.sender, _allBids[msg.sender], _biddersLatestBid[msg.sender]);
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