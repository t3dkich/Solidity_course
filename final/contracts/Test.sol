pragma solidity >=0.4.21 <0.6.0;
// pragma experimental ABIEncoderV2;

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

    event JobPayment(address sender, address userSolutionAddress, uint reward);
    event NewUser(address sender, uint value);

    modifier fundsCheck(uint value) {
        require(value > 0, 'Must be more be a positive number');
        _;
    }

    modifier paymentValidation(address sender, uint reward) {
        require(userIn[sender], 'This address is not a user!');
        require(users[sender].funds >= reward, 'This address has insuffiecient funds!');
        _;
    }

    function updateJobsHash(string memory jobsHash) public  
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
            require(!userIn[sender], 'Already a user!');
            _addUser(userHash);
            addReward(UserMode.Add);
        } else {
            require(userIn[sender], 'Not a user address!');
            _updateUserHash(userHash);
            addReward(UserMode.Update);
        }
        updateJobsHash(jobsHash);
        
    }

    function updateForSolutions(string memory userHash, string memory jobsHash, address userJobAddress) 
        public
    {
        _updateUserHashForSolutions(userHash, userJobAddress);
        updateJobsHash(jobsHash);
    }

    function updateHasheshAndPaySolution(string memory userHash, string memory jobsHash, address payable userSolutionAddress, uint reward) 
        public
        paymentValidation(msg.sender, reward) 
    {
        address sender = msg.sender;   
        _updateUserHash(userHash);
        updateJobsHash(jobsHash);
        users[sender].funds -= reward;
        userSolutionAddress.transfer(reward);
        emit JobPayment(sender, userSolutionAddress, reward);
    }

    function _addUser(string memory userHash) private {
        address sender = msg.sender;
        uint value = msg.value;
        User memory user = User(value, userHash);
        userIn[sender] = true;
        users[sender] = user;
        emit NewUser(sender, value);
    }

    function _updateUserHash(string memory hashIpfs) private {
        users[msg.sender].userHash = hashIpfs;
    }

    function _updateUserHashForSolutions(string memory hashIpfs, address userJobAddress) 
        private
    {
        users[userJobAddress].userHash = hashIpfs;
    }

    function addReward(UserMode mode) private {
        if (mode == UserMode.Update) {
            users[msg.sender].funds += msg.value;
        }
        contractValue += msg.value;       
    }

    function getJobsHash() public view returns(string memory){
        return allJobs;
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