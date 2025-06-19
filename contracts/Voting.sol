// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Voting is ReentrancyGuard {
    
    address public owner; // Address of the contract owner
    enum VotingState { Inactive, Active } // Possible states of the voting process
    VotingState public votingState; // Current state of the voting process

    mapping(string => uint256) public votes; // Maps candidate names to their vote counts
    string[] public candidates; // List of candidate names
    mapping(address => bool) public hasVoted; // Tracks if an address has voted

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Initializes the contract with a non-empty list of candidate names
    constructor(string[] memory candidateNames) {
        require(candidateNames.length > 0, "At least one candidate is required");
        owner = msg.sender;
        votingState = VotingState.Inactive;
        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(candidateNames[i]);
            votes[candidateNames[i]] = 0;
        }
    }

    // Starts the voting process, only callable by the owner
    function startVoting() external onlyOwner {
        require(votingState == VotingState.Inactive, "Voting is already active");
        votingState = VotingState.Active;
    }

    // Ends the voting process, only callable by the owner
    function endVoting() external onlyOwner {
        require(votingState == VotingState.Active, "Voting is not active");
        votingState = VotingState.Inactive;
    }

    // Allows a user to vote for a candidate, protected against reentrancy
    function vote(string memory candidateName) external nonReentrant {
        require(votingState == VotingState.Active, "Voting is not active");
        require(votes[candidateName] != type(uint256).max, "Candidate does not exist");
        require(!hasVoted[msg.sender], "You have already voted");
        require(votes[candidateName] < type(uint256).max, "Vote count overflow");
        votes[candidateName]++;
        hasVoted[msg.sender] = true;
    }

    // Returns the number of votes for a specific candidate
    function getVotes(string memory candidateName) external view returns (uint256) {
        return votes[candidateName];
    }

    // Returns the list of all candidates
    function getCandidates() external view returns (string[] memory) {
        return candidates;
    }

    // Returns the winner and their vote count after voting ends
    function getWinner() external view returns (string memory winner, uint256 maxVotes) {
        require(votingState == VotingState.Inactive, "Voting is still active");
        for (uint256 i = 0; i < candidates.length; i++) {
            if (votes[candidates[i]] > maxVotes) {
                maxVotes = votes[candidates[i]];
                winner = candidates[i];
            }
        }
    }
}