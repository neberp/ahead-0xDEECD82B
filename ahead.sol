pragma solidity >=0.7.0 <0.9.0;


contract ahead {
    address admin;

    event FundingReceived(address addr, uint amount, uint contractBalance);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "401 (Unauthorized)");
        _;
    }

    struct User {
        address payable walletAddress;
        string nickname;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    User[] public users;

    function addUser(address payable walletAddress, string memory nickname, uint releaseTime, uint amount, bool canWithdraw) public onlyAdmin {
        users.push(User(
            walletAddress,
            nickname,
            releaseTime,
            amount,
            canWithdraw
        ));
    }

    function balanceOf() public view returns(uint) {
        return address(this).balance;
    }

    function deposit(address walletAddress) payable public {
        addToUsersBalance(walletAddress);
    }

    function addToUsersBalance(address walletAddress) private {
        for(uint i = 0; i < User.length; i++) {
            if(users[i].walletAddress == walletAddress) {
                users[i].amount += msg.value;
                emit FundingReceived(walletAddress, msg.value, balanceOf());
            }
        }
    }

    function getIndex(address walletAddress) view private returns(uint) {
        for(uint i = 0; i < users.length; i++) {
            if (users[i].walletAddress == walletAddress) {
                return i;
            }
        }
        return 0;
    }

    function withdraw(address payable walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require(msg.sender == users[i].walletAddress, "Wallet address does not match user");
        require(users[i].canWithdraw == true, "You are not able to withdraw at this time");
        users[i].walletAddress.transfer(users[i].amount);
    }

}