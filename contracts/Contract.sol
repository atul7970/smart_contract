// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract HabitTracker {
    address public creator;
    uint256 public deadline;
    uint256 public taskStake;
    bool public taskCompleted;
    bool public consensusReached;
    mapping(address => bool) public confirmations;

    event TaskCompleted();
    event ConsensusReached();
    event FundsReturned();
    event FundsBurned();

    constructor(uint256 _duration, uint256 _stake) {
        creator = msg.sender;
        deadline = block.timestamp + _duration;
        taskStake = _stake;
    }

    function confirmTaskCompleted() public {
        require(block.timestamp <= deadline, "The deadline has passed.");
        require(!confirmations[msg.sender], "You've already confirmed.");
        confirmations[msg.sender] = true;
        if (checkConsensus()) {
            taskCompleted = true;
            emit TaskCompleted();
        }
    }

    function checkConsensus() internal returns (bool) {
        uint256 consensusCount = 0;
        for (uint256 i = 0; i < 3; i++) {
            if (confirmations[msg.sender]) {
                consensusCount++;
            }
        }
        if (consensusCount >= 3) {
            consensusReached = true;
            emit ConsensusReached();
            return true;
        }
        return false;
    }

    function returnFunds() public {
        require(block.timestamp > deadline, "The deadline hasn't passed.");
        require(taskCompleted, "Task not completed.");
        require(msg.sender == creator, "Only the creator can return funds.");
        payable(creator).transfer(taskStake);
        emit FundsReturned();
    }

    function burnFunds() public {
        require(block.timestamp > deadline, "The deadline hasn't passed.");
        require(!taskCompleted, "Task was completed.");
        require(!consensusReached, "Consensus reached.");
        selfdestruct(payable(address(0))); // Burn the funds.
        emit FundsBurned();
    }
}
