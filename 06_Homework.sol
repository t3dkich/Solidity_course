pragma solidity >=0.4.22 <0.6.0;

library MathOperations {
    function add(uint a, uint b) 
        public
        pure
        returns(uint)
    {
        uint result = a + b;
        assert(result - a == b);
        return result;
    }
    
    function subtract(uint a, uint b) 
        public
        pure
        returns(uint)
    {
        uint result = a - b;
        assert(result + a == b);
        return result;
    }
    
    function multiply(uint a, uint b) 
        public
        pure
        returns(uint)
    {
        uint result = a * b;
        assert(result / a == b);
        return result;
    }
    
    function divide(uint a, uint b) 
        public
        pure
        returns(uint)
    {
        uint result = a / b;
        assert(result * b == a);
        return result;
    }
}

contract Maths {
    using MathOperations for uint;
    
    function add(uint a, uint b) public pure returns(uint result) {
        result = a.add(b);
    }
    
    function subtract(uint a, uint b) public pure returns(uint result) {
        result = a.subtract(b);
    }
    
    function multiply(uint a, uint b) public pure returns(uint result) {
        result = a.multiply(b);
    }
    
    function divide(uint a, uint b) public pure returns(uint result) {
        result = a.divide(b);
    }
}

library MemberOperations {
    
    struct Member {
        uint fullAmount;
        uint lastDonationTimestamp;
        uint lastAmount;
    }
    
    struct MembersData {
        mapping(address => bool) _isMemberArr;
        mapping(address => Member) _members;
        mapping(uint => mapping(address => bool)) _voteRoundList;
    }
    
    struct CurrentVote {
        address user;
        bool isOpen;
    }
    
    struct HelperValues {
        uint voteCount;
        uint currentRound;
        uint allMembers;
    }
    
    function setMember(MembersData storage data, address user) 
        public
    {
        data._isMemberArr[user] = true;
        Member memory member;
        data._members[user] = member;
    }
    
    function removeMember(MembersData storage data, address user, HelperValues storage helperValues) 
        public 
    {
        data._isMemberArr[user] = false;
        helperValues.allMembers -= 1;
    }
    
    function addMemberForVote(CurrentVote storage currentVote, address user)
        public
    {
        currentVote.user = user;
        currentVote.isOpen = false;
    }
    
    event help(string neshto);
    
    function voteForCurrentMember(MembersData storage members, HelperValues storage helperValues, CurrentVote storage currentVote) 
        public
    {
        if (helperValues.voteCount * 2 > helperValues.allMembers) {
            voteComplete(members, helperValues, currentVote);
        } else {
            if (!members._voteRoundList[helperValues.currentRound][msg.sender]) {
                members._voteRoundList[helperValues.currentRound][msg.sender] = true;
                helperValues.voteCount++;
                emit help('parviq If');
            } else if (members._voteRoundList[helperValues.currentRound][msg.sender]) {
                require(false, 'This address has already voted!');
                emit help('vtoriq If');
            }
            if (helperValues.voteCount * 2 > helperValues.allMembers) {
                    voteComplete(members, helperValues, currentVote);
                }
        }
    }
    
    function donate(MembersData storage members ,address sender, uint value)
        public
    {
        members._members[sender].fullAmount += value;
        members._members[sender].lastDonationTimestamp = now;
        members._members[sender].lastAmount = value;
    }
    
    function voteComplete(MembersData storage members, HelperValues storage helperValues, CurrentVote storage currentVote) 
        private 
    {
        setMember(members, currentVote.user);
        nextRound(helperValues, currentVote);
    }
    
    function nextRound(HelperValues storage helperValues, CurrentVote storage currentVote) 
        private
    {
        helperValues.currentRound++;
        helperValues.voteCount = 0;
        helperValues.allMembers++;
        currentVote.user = address(0);
        currentVote.isOpen = true;
    }
}

contract Voting is Maths {
    using MemberOperations for MemberOperations.MembersData;
    using MemberOperations for MemberOperations.CurrentVote;
    using MemberOperations for MemberOperations.HelperValues;
    
    MemberOperations.MembersData members;
    MemberOperations.CurrentVote currentVote;
    MemberOperations.HelperValues helperValues;
    
    address payable _owner;
    
    constructor()
        public
    {
        _owner = msg.sender;
        members.setMember(_owner);
        currentVote.isOpen = true;
        helperValues.allMembers++;
    }
    
    modifier justOwner {
        assert(msg.sender == _owner);
        _;
    }
    
    modifier notMember(address user) {
        require(members._isMemberArr[user] == false, 'This address is already a member!');
        _;
    }
    
    modifier justMembers(address user) {
        require(members._isMemberArr[user], 'This address is not a member!');
        _;
    }
    
    modifier openAddingMember {
        require(currentVote.isOpen, 'Voting is closed currently!');
        _;
    }
    
    modifier openVoting {
        require(!currentVote.isOpen, 'Voting is open currently!');
        _;
    }
    
    modifier validAmount(uint value) {
        require(value > 0, 'Must be positive number!');
        _;
    }
    
    modifier oneHourRule(address user) {
        if (members._members[user].lastDonationTimestamp > 0) {
            require(members._members[user].lastDonationTimestamp + 1 hours < now, 'Before remove member must past one hour since last donation!');
        }
        _;
    }
    
    function addMember(address userAddress) 
        public
        justMembers(msg.sender)
        notMember(userAddress)
        openAddingMember
    {
        currentVote.addMemberForVote(userAddress);
    }
    
    function voteForCurrentMember() 
        public
        justMembers(msg.sender)
        openVoting
    {
        members.voteForCurrentMember(helperValues, currentVote);
    }
    
    function removeMember(address userAddress)
        public
        justOwner
        justMembers(userAddress)
        oneHourRule(userAddress)
    {
        members.removeMember(userAddress, helperValues);
    }
    
    function donate() 
        public
        payable
        justMembers(msg.sender)
        validAmount(msg.value)
    {
        members.donate(msg.sender, msg.value);
    }
        
    function destroy() 
        public
        justOwner
    {
        selfdestruct(_owner);
    }
}