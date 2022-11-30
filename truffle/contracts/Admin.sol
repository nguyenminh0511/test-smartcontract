pragma solidity >=0.4.22 <0.9.0;

contract Admin {
    address admin;

    constructor() public {
        admin = msg.sender;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "ADMIN PERMISSION REQUIRE");
        _;
    }
}