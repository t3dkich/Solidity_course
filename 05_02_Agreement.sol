pragma solidity >=0.4.22 <0.6.0;

contract Agreement {
    
    address[] private _owners;
    uint _nextVoter;
    bool _isActiveProposal;
    
    struct Proposed {
        address payable proposed;
        uint value;
        uint timestamp;
    }
    
    Proposed private proposed;
    
    constructor(address[] memory owners) 
        public
    {
        _owners = owners;
        _isActiveProposal = false;
    }
    
    modifier justOwners {
        bool isIn = false;
        for (uint i = 0; i < _owners.length; i++) {
            if (_owners[i] == msg.sender) {
                _;
                isIn = true;
                break;
            }
        }
        if (!isIn) {
            require(false, 'Not owner address');
        }
    }
    
    modifier notActiveProposal {
        require(_isActiveProposal == false, 'There is proposed address now!');
        _;
    }
    
    modifier activeProposal {
        require(_isActiveProposal == true, 'Proposal not active!');
        _;
    }
    
    modifier lessThan5minutes {
        require(now <= proposed.timestamp + 5 minutes, '5 minutes has past initial proposal!');
        _;
    }
    
    modifier nextVoter {
        require(_owners[_nextVoter] == msg.sender, 'Its not your turn to vote!');
        _;
    }
    
    modifier isEnoughtEth(uint value) {
        require(address(this).balance >= value, 'There is not enought Ethers in here!');
        _;
    }
    
    function propose(address payable proposeAddress, uint value) 
        public 
        justOwners
        notActiveProposal
        isEnoughtEth(value)
    {
        proposed = Proposed(proposeAddress, value, now);
        _isActiveProposal = true;
        _nextVoter = 0;
    }
    
    function vote()
        public
        justOwners
        activeProposal
        lessThan5minutes
        nextVoter
    {
        _nextVoter++;
        
        if (_nextVoter >= _owners.length) {
            proposed.proposed.transfer(proposed.value);
            _isActiveProposal = false;
        }
    }
    
    function acceptEth()
        public
        payable
    {
        
    }
}

