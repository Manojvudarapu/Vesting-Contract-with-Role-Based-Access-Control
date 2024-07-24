// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingContract is Ownable {
    IERC20 public token;
    uint256 public totalAllocatedTokens;
    
    enum Role { User, Partner, Team }
    
    struct VestingSchedule {
        uint256 cliff;
        uint256 duration;
        uint256 amount;
        uint256 start;
        uint256 claimed;
    }

    mapping(address => VestingSchedule) public beneficiaries;
    mapping(address => Role) public roles;

    event VestingStarted(address indexed beneficiary, uint256 start);
    event BeneficiaryAdded(address indexed beneficiary, Role role, uint256 amount);
    event TokensClaimed(address indexed beneficiary, uint256 amount);

    constructor(IERC20 _token, uint256 _totalAllocatedTokens) Ownable(msg.sender) {
        token = _token;
        totalAllocatedTokens = _totalAllocatedTokens;
    }

    function addBeneficiary(address beneficiary, Role role, uint256 start) external onlyOwner {
        require(beneficiaries[beneficiary].amount == 0, "Beneficiary already exists");

        uint256 cliff;
        uint256 duration;
        uint256 amount;
        
        if (role == Role.User) {
            amount = totalAllocatedTokens * 50 / 100;
            cliff = start + 10 * 30 * 24 * 60 * 60; // 10 months in seconds
            duration = start + 2 * 365 * 24 * 60 * 60; // 2 years in seconds
        } else if (role == Role.Partner) {
            amount = totalAllocatedTokens * 25 / 100;
            cliff = start + 2 * 30 * 24 * 60 * 60; // 2 months in seconds
            duration = start + 365 * 24 * 60 * 60; // 1 year in seconds
        } else if (role == Role.Team) {
            amount = totalAllocatedTokens * 25 / 100;
            cliff = start + 2 * 30 * 24 * 60 * 60; // 2 months in seconds
            duration = start + 365 * 24 * 60 * 60; // 1 year in seconds
        }

        beneficiaries[beneficiary] = VestingSchedule(cliff, duration, amount, start, 0);
        roles[beneficiary] = role;
        
        emit BeneficiaryAdded(beneficiary, role, amount);
    }

    function claimTokens() external {
        VestingSchedule storage schedule = beneficiaries[msg.sender];
        require(block.timestamp >= schedule.cliff, "Tokens are not yet vested");
        require(schedule.amount > 0, "No tokens to claim");

        uint256 claimable = _vestedAmount(schedule) - schedule.claimed;
        require(claimable > 0, "No tokens available for claim");

        schedule.claimed += claimable;
        token.transfer(msg.sender, claimable);

        emit TokensClaimed(msg.sender, claimable);
    }

    function _vestedAmount(VestingSchedule memory schedule) internal view returns (uint256) {
        if (block.timestamp < schedule.cliff) {
            return 0;
        } else if (block.timestamp >= schedule.duration) {
            return schedule.amount;
        } else {
            return schedule.amount * (block.timestamp - schedule.start) / (schedule.duration - schedule.start);
        }
    }
}
