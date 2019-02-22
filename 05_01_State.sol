pragma solidity >=0.4.22 <0.6.0;

contract State {
    
    address private _owner;
    
    enum StateValue { Locked, Unlocked, Restricted }
    
    struct LastUserInfo {
        uint counter;
        uint timestamp;
        address user;
    }
    
    StateValue public _state;
    LastUserInfo private _info;
    
    event incrementInfo(uint counter, uint timestamp, address user);
    
    constructor(StateValue state)
        public
        validStateVariable(state)
    {
        _owner = msg.sender;
        _state = state;
    }
    
    modifier validStateVariable(StateValue state) {
        require(_isValidState(state), 'State variable must be between 0 and 2!');
        _;
    }
    
    modifier justOwner {
        require(_owner == msg.sender, 'Not owner address!');
        _;
    }
    
    modifier notLocked {
        require(uint8(_state) != 0, 'Contract is locked!');
        _;
    }
    
    modifier notResctricted {
        if (_owner != msg.sender) {
            require(uint8(_state) != 2, 'Contract is restricted!');
        }
        _;
    }
    
    function justOwnerChangeState(StateValue state) 
        public
        justOwner
        validStateVariable(state)
    {
        _state = state;
    }
    
    function userIncrement() 
        public
        notLocked
        notResctricted
    {
        _info = LastUserInfo(++_info.counter, now, msg.sender);
        emit incrementInfo(_info.counter, _info.timestamp, _info.user);
    }
    
    function _isValidState(StateValue state)
        private
        pure
        returns(bool)
    {
        uint8 temp = uint8(state);
        return temp >= 0 && temp <= 2;
    }
    
}