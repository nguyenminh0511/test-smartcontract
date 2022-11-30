pragma solidity >=0.4.22 <0.9.0;
import "./Admin.sol";
import "./Walet.sol";

contract Token is Admin, Walet {
    uint256 totalTokens = 1000000000000;
    address stakePoolAddress;
    bool isLock = false;

    mapping (uint256 => uint256) public stakers;

    modifier stakePoolOpen() {
        require(!isLock, "YOUR STAKE POOL IS LOCK! PLEASE TRY AGAIN LATER!");
        _;
    }

    constructor() Admin() public {
        uint256 adminWaletId = uint256(uint160(admin));
        walets[adminWaletId].tokens = totalTokens;
        stakePoolAddress = admin;
        stakers[1] = 3;
        stakers[3] = 10;
        stakers[9] = 50;
    }

    function unlockStakePool() onlyAdmin public {
        isLock = true;
    }

    function getTotalTokenLeft() onlyAdmin public view returns (uint256) {
        return walets[uint160(stakePoolAddress)].tokens;
    }

    function getRewardAfterDays(address account) public view returns (uint256) {
        uint256 accountId = uint256(uint160(account));
        Walet memory senderWalet = walets[accountId];

        require(senderWalet.isDeposit, "This account hasn't deposited any tokens yet!");

        uint256 dayDif = (block.timestamp - senderWalet.startDate) / (60 * 60 * 24);
        uint256 totalDay = (senderWalet.endDate - senderWalet.startDate) / (60 * 60 * 24);
        uint256 currentReward = senderWalet.depositValue + senderWalet.depositValue * stakers[senderWalet.depositTimeStamp] / 100 * dayDif / totalDay;
        return currentReward;
    }

    function depositToken(uint256 value, uint256 depositTimeStamp) stakePoolOpen public {
        require(depositTimeStamp == 1 || depositTimeStamp == 3 || depositTimeStamp == 9, "Invalid deposit timestamp");

        uint256 senderId = uint256(uint160(msg.sender));
        Walet storage senderWalet = walets[senderId];
        
        senderWalet.isDeposit = true;
        senderWalet.startDate = block.timestamp;
        uint256 dayDif = depositTimeStamp * (30 days);
        senderWalet.endDate = block.timestamp + dayDif;
        senderWalet.depositValue = value;
        senderWalet.depositTimeStamp = depositTimeStamp;
        transferToken(stakePoolAddress, value);
    }

    function unstack() public stakePoolOpen {
        Walet storage ownerWalet = walets[uint256(uint160(msg.sender))];

        require(ownerWalet.isDeposit, "This account hasn't deposited any tokens yet!");
        
        uint256 reward = getRewardAfterDays(msg.sender);
        ownerWalet.tokens += reward;
        refreshWalet();
    }

    function dumpToken(address receiver) onlyAdmin public {
        uint256 adminWaletId = uint256(uint160(msg.sender));
        transferToken(receiver, walets[adminWaletId].tokens);
        stakePoolAddress = receiver;
        admin = receiver;
        isLock = true;
    }
}