pragma solidity >=0.4.22 <0.9.0;

contract Walet {
    struct Walet {
        uint256 tokens;
        bool isDeposit;
        uint256 startDate;
        uint256 endDate;
        uint256 depositValue;
        uint256 depositTimeStamp; 
        
    }

    mapping (uint256 => Walet) public walets;

    function transferToken(address receiver, uint256 value) public {

        uint256 senderId = uint256(uint160(msg.sender));
        uint256 receiverId = uint256(uint160(receiver));

        require(walets[senderId].tokens >= value, "transfer value must be less-than or equal to your tokens");

        walets[senderId].tokens -= value;
        walets[receiverId].tokens += value;
    }

    function refreshWalet() public {
        Walet storage senderWalet = walets[uint256(uint160(msg.sender))];
        senderWalet.isDeposit = false;
        senderWalet.startDate = 0;
        senderWalet.endDate = 0;
        senderWalet.depositValue = 0;
        senderWalet.depositTimeStamp = 0;
    }

    //test only
    function setStartDate(address account, uint256 numberOfDays) public {
        Walet storage settedWalet = walets[uint256(uint160(account))];
        require(settedWalet.isDeposit, "Haven't deposit yet!");
        settedWalet.startDate -= (numberOfDays * 60 * 60 * 24);
    }
}