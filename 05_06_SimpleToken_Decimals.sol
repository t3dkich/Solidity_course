pragma solidity >=0.4.22 <0.6.0;

contract SimpleToken {
    string public _name;
    string public _symbol;
    address _owner;
    
    struct Token {
        uint amount;
        string representation;
    }
    
    event transferInfo(address from, address to, uint amount, string representation);
    
    mapping(address => Token) private _holders;
    
    constructor(string memory name, string memory symbol, uint totalSupply) 
        public 
    {
        _name = name;
        _symbol = symbol;
        _holders[msg.sender] = Token(totalSupply, _tokenRepresentation(totalSupply));
    }
    
    modifier validAmount(uint amount) {
        require(_holders[msg.sender].amount >= amount, 'Do not have enough amount in this address');
        _;
    }
    
    function sendTokens(address to, uint amount)
        public 
        payable 
        validAmount(amount)
    {
        address sender = msg.sender;
        _holders[sender].amount -= amount;
        _holders[sender].representation = _tokenRepresentation(_holders[sender].amount);
        _holders[to].amount += amount;
        _holders[to].representation = _tokenRepresentation(_holders[to].amount);
        emit transferInfo(sender, to, amount, _tokenRepresentation(amount));
    }
    
    function checkAddress(address holder)
        public
        view
        returns(string memory)
    {
        string memory value = uint2str(_holders[holder].amount);
        return string(abi.encodePacked('Real amount is ', value, '. Representation is ', _holders[holder].representation));
    }
    
    function _tokenRepresentation(uint t) private pure returns(string memory){
        uint a = t / 100;
        uint b = t % 100;
        string memory aa = uint2str(a);
        string memory bb = uint2str(b);
        if (b < 10) {
            bb = string(abi.encodePacked('0', bb));
        }
        return string(abi.encodePacked(aa, ".", bb));
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}