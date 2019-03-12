pragma solidity >=0.4.22 <0.6.0;

contract Ownable {
    address _owner;
    
    constructor() public {
        _owner = msg.sender;
    }
    
    modifier justOwner {
        require(_owner == msg.sender, 'You are not the owner!');
        _;
    }
}

library MembersVoting {
    struct AllMembers {
        uint fullImportanceScore;
        mapping(address => uint) members;
    }
    
    struct Candidate {
        address user;
        uint importance;
    }
    
    struct TransferProposal {
        bool isClosed;
        bool isAllowedWithdraw;
        address user;
        uint value;
        uint voteScore;
    }
    
    struct Proposed {
        address user;
        uint value;
    }
    
    struct VoteRound {
        uint round;
        mapping(uint => mapping(address => bool)) isVotedArr;
    }
    
    modifier open(TransferProposal storage proposal) {
        require(!proposal.isClosed, 'There is a proposal already!');
        _;
    }
    
    modifier closed(TransferProposal storage proposal) {
        require(proposal.isClosed, 'There is not a proposal yet!');
        _;
    }
    
    modifier justMembers(address user, AllMembers storage allMembers) {
        require(allMembers.members[user] > 0, 'This address is not a member!');
        _;
    }
    
    modifier notVoted(address member, VoteRound storage voteRound) {
        require(!voteRound.isVotedArr[voteRound.round][member], 'You have already voted for this proposal!');
        voteRound.isVotedArr[voteRound.round][member] = true;
        _;
    }
    
    modifier withdrawFinished(TransferProposal storage proposal) {
        require(!proposal.isAllowedWithdraw, 'Current proposed user needs to withdraw funds first');
        _;
    }
    
    modifier proposedWinner(TransferProposal storage proposal, address user) {
        require(proposal.user == user, 'This address is not eligable for withdraw!');
        require(proposal.isAllowedWithdraw == true, 'Not allowed to withdraw yet!');
        _;
    }
    
    function addMember(AllMembers storage allMembers, Candidate storage candidate)
        public
    {
        allMembers.members[candidate.user] = candidate.importance;
        allMembers.fullImportanceScore += candidate.importance;
    }
    
    function fundsTransferProposal(TransferProposal storage proposal, Proposed storage proposed) 
        public
        open(proposal)
        withdrawFinished(proposal)
    {
        proposal.isClosed = true;
        proposal.isAllowedWithdraw = false;
        proposal.user = proposed.user;
        proposal.value = proposed.value;
        proposal.voteScore = 0;
    }
    
    function vote(TransferProposal storage proposal, AllMembers storage allMembers, address member, VoteRound storage voteRound) 
        public 
        justMembers(member, allMembers)
        closed(proposal)
        notVoted(member, voteRound)
    {
        proposal.voteScore += allMembers.members[member];
        bool areVotesOverHalf = proposal.voteScore * 2 > allMembers.fullImportanceScore;
        
        if (areVotesOverHalf) {
            allowToWithdraw(proposal);
        } 
    }
    
    function withdrawFunds(TransferProposal storage proposal, address user)
        public
        proposedWinner(proposal, user)
    {
        proposal.isClosed = false;
        proposal.isAllowedWithdraw = false;
    }
    
    function allowToWithdraw(TransferProposal storage proposal)
        private
    {
        proposal.isAllowedWithdraw = true;
        proposal.isClosed = true;
    }
}

contract FundDistribution is Ownable {
    using MembersVoting for MembersVoting.AllMembers;
    using MembersVoting for MembersVoting.TransferProposal;
    
    MembersVoting.AllMembers private allMembers;
    MembersVoting.Candidate private candidate;
    
    MembersVoting.TransferProposal proposal;
    MembersVoting.Proposed proposed;
    
    MembersVoting.VoteRound voteRound;
    
    uint public donations;
    
    constructor() public {
        init();
    }
    
    function donate() public payable { 
        require(msg.value > 0, 'Must be positive value!');
        donations += msg.value;
    }
    
    function fundsTransferProposal(address user, uint value) 
        public 
        justOwner
    {
        require(value >= donations, 'Not enought funds!');
        proposed = MembersVoting.Proposed(user, value);
        proposal.fundsTransferProposal(proposed);
    }
    
    function vote() 
        public
    {
        proposal.vote(allMembers, msg.sender, voteRound);
    }
    
    function withdrawFunds()
        public
    {
        proposal.withdrawFunds(msg.sender);
        voteRound.round++;
        donations -= proposal.value;
        msg.sender.transfer(proposal.value);
    }
    
    function init() 
        private
    {
        candidate = MembersVoting.Candidate(0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C, 2);
        allMembers.addMember(candidate);
        
        candidate = MembersVoting.Candidate(0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB, 3);
        allMembers.addMember(candidate);
        
        candidate = MembersVoting.Candidate(0x583031D1113aD414F02576BD6afaBfb302140225, 2);
        allMembers.addMember(candidate);
    }
}
