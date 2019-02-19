pragma solidity >=0.4.22 <0.6.0;

contract ServiceMarketplace {
    
    address payable _owner;
    uint private _lastBoughtTime;
    uint private _lastWithdrawTime;
    
    constructor() 
        public
    {
        _owner = msg.sender;
    }
    
    event servicePaymentmentInfo(address indexed receiver, uint indexed amountSent, uint indexed amountSentBack);
    event withdrawInfo(address indexed contractAddress, address indexed owner, uint indexed amountSent);
    
    modifier oneEtherOrMore {
        require(msg.value >= 1 ether, 'This service cost exactly 1 Ether, if sent more you get rest back!');
        _;
    }
    
    modifier afterTwoMinutes {
        require(now > _lastBoughtTime + 2 minutes, 'Someone bought this in less than 2 minutes. So you have to wait!');
        _;
    }
    
    modifier justOwner {
        require(msg.sender == _owner, 'Only the owner of contract can withdraw!');
        _;
    }
    
    modifier zeroToFiveEthers(uint amount) {
        require(amount > 0 || amount <= 5 ether, 'Amount must be between 0.00000001 and 5 ethers');
        _;
    }
    
    modifier afterOneHour {
        if (_lastWithdrawTime > 0) {
            require(now > _lastWithdrawTime + 1 hours, 'You can withdraw once per hour!');
        }
        _;
    }
    
    function transferOneEther()
        public
        payable
        oneEtherOrMore
        afterTwoMinutes
    {
        uint sendBackValue = _receiveEtherAndGiveBackIfMore();
        emit servicePaymentmentInfo(msg.sender, 1 ether, sendBackValue);
    }
    
    function withdraw(uint amount)
        public
        payable
        justOwner
        zeroToFiveEthers(amount)
        afterOneHour
    {
        _withdraw(amount);
    }
    
    function _receiveEtherAndGiveBackIfMore()
        private
        returns(uint)
    {
        uint sentBackValue = msg.value - 1 ether;
        _lastBoughtTime = now;
        if (sentBackValue > 0) {
            msg.sender.transfer(sentBackValue);
        }
        return sentBackValue;
    }
    
    function _withdraw(uint amount)
        private
    {
        _lastWithdrawTime = now;
        _owner.transfer(amount);
        emit withdrawInfo(address(this), _owner, amount);
    }
}