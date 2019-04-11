pragma solidity >=0.4.21 <0.6.0;
pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract Test is Ownable {
    enum UserMode { Add, Update }

    mapping(address => User) users;
    mapping(address => bool) userIn;
    string allJobs;
    uint contractValue;

    struct User {
        uint funds;
        string userHash;
    }

    modifier fundsCheck(uint value) {
        require(value > 0, 'Must be more be a positive number');
        _;
    }

    modifier onlyUser(address sender) {
        require(userIn[sender], 'Not registered address!');
        _;
    } 

    function _addUser(string memory userHash) private {
        address sender = msg.sender;
        User memory user = User(msg.value, userHash);
        userIn[sender] = true;
        users[sender] = user;
    }

    function updateJobsHash(string memory jobsHash) public 
        // onlyUser(msg.sender) 
    {
        allJobs = jobsHash;

    }

    function userAndJobsHashes(UserMode mode, string memory userHash, string memory jobsHash)
        public
        payable 
        fundsCheck(msg.value)
    {
        address sender = msg.sender;
        if (mode == UserMode.Add) { 
            require(!userIn[sender], 'Not a user address!');
            _addUser(userHash);
        } else {
            require(userIn[sender], 'Already a user!');
            updateUserHash(userHash);
        }
        updateJobsHash(jobsHash);
        addReward();
    }

    function updateForSolutions(string memory userHash, string memory jobsHash, address userJobAddress) 
        public
    {
        updateUserHashForSolutions(userHash, userJobAddress);
        updateJobsHash(jobsHash);
    }

    function updateHasheshAndPaySolution(string memory userHash, string memory jobsHash, address payable userSolution, uint reward) 
        public 
    {
        address sender = msg.sender;
        require(userIn[sender], 'This address is not a user!');
        require(users[sender].funds > reward, 'This address has insuffiecient funds!');
        updateUserHash(userHash);
        updateJobsHash(jobsHash);
        userSolution.transfer(reward);
    }

    function updateUserHashForSolutions(string memory hashIpfs, address userJobAddress) 
        private
    {
        users[userJobAddress].userHash = hashIpfs;
    }

    function addReward() private {
        users[msg.sender].funds += msg.value;
        contractValue += msg.value;
    }

    function getJobsHash() public view returns(string memory){
        return allJobs;
    }

    function updateUserHash(string memory hashIpfs) public {
        users[msg.sender].userHash = hashIpfs;
    }

    function getUser(address user) public view returns(uint funds, string memory userHash) {
        return (users[user].funds, users[user].userHash);
    }

    function getContractValue() public view returns(uint) {
        return address(this).balance;
    }
    
    function isUser(address user) public view returns(bool) {
        return userIn[user];
    }

}