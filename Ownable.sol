pragma solidity >=0.4.22 <0.6.0;

contract Ownership {
    address private _owner;
    address private _proposedOwner;
    uint256 private _acceptOwnerTime;
    
    constructor() public {
        _owner = msg.sender;
        emit changeOwnership(address(0), msg.sender);
    }
    
    event changeOwnership(address indexed oldOwner, address indexed newOwner);
    event fallback(address indexed sender, uint256 indexed value);
    
    modifier onlyOwner() {
        require(_owner == msg.sender, 'You are not the owner of the contract!');
        _;
    }
    
    modifier proposedOwner() {
        require(_proposedOwner == msg.sender, 'You are not the proposed owner of the contract!');
        _;
    }
    
    modifier lessThan30seconds() {
        require(_acceptOwnerTime >= now, 'More than 30 seconds had past since offering!');
        _;
    }
    
    function changeOwner(address newOwner) public onlyOwner {
        _changeOwner(newOwner);
        _acceptOwnerTime = now + 30 seconds;
    }
    
    function _changeOwner(address newOwner) internal {
        emit changeOwnership(_owner, newOwner);
        _proposedOwner = newOwner;
    }
    
    function acceptOwnership() public
        proposedOwner
        lessThan30seconds {
            _acceptOwnership();
    }
    
    function _acceptOwnership() internal {
        _owner = _proposedOwner;
    }
    
    function() external payable {
        emit fallback(msg.sender, msg.value);
    }
}