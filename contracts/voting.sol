// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EVoting {
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 vote; // index of the candidate in the candidates array
    }

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public electionCommission;
    mapping(address => Voter) public voters;
    Candidate[] public candidates;
    bool public electionStarted;

    event VoterRegistered(address voter);
    event ElectionStarted();
    event ElectionEnded();
    event VoteCasted(address voter, uint256 candidateIndex);

    modifier onlyElectionCommission() {
        require(msg.sender == electionCommission, "Only election commission can execute this");
        _;
    }

    modifier onlyDuringElection() {
        require(electionStarted == true, "Election is not currently active");
        _;
    }

    constructor() {
        electionCommission = msg.sender;
        electionStarted = false;
    }

    // Function to register a candidate
    function registerCandidate(string memory _name) public onlyElectionCommission {
        candidates.push(Candidate(_name, 0));
    }

    // Function to register a voter
    function registerVoter(address _voter) public onlyElectionCommission {
        require(!voters[_voter].isRegistered, "Voter is already registered");
        voters[_voter] = Voter(true, false, 0);
        emit VoterRegistered(_voter);
    }

    // Function to start the election
    function startElection() public onlyElectionCommission {
        require(!electionStarted, "Election has already started");
        require(candidates.length > 0, "No candidates registered");
        electionStarted = true;
        emit ElectionStarted();
    }

    // Function to end the election
    function endElection() public onlyElectionCommission onlyDuringElection {
        electionStarted = false;
        emit ElectionEnded();
    }

    // Function to cast a vote
    function vote(uint256 candidateIndex) public onlyDuringElection {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "You are not registered to vote");
        require(!sender.hasVoted, "You have already voted");
        require(candidateIndex < candidates.length, "Invalid candidate index");

        sender.hasVoted = true;
        sender.vote = candidateIndex;

        // Increment the vote count of the candidate
        candidates[candidateIndex].voteCount += 1;

        emit VoteCasted(msg.sender, candidateIndex);
    }

    // Function to get the vote count of a candidate
    function getCandidateVoteCount(uint256 candidateIndex) public view returns (uint256) {
        require(candidateIndex < candidates.length, "Invalid candidate index");
        return candidates[candidateIndex].voteCount;
    }

    // Function to get the total number of candidates
    function getCandidateCount() public view returns (uint256) {
        return candidates.length;
    }

    // Function to get the winner candidate
    function getWinner() public view returns (string memory winnerName) {
        require(!electionStarted, "Election is still ongoing");

        uint256 winningVoteCount = 0;
        uint256 winningCandidateIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningCandidateIndex = i;
            }
        }

        winnerName = candidates[winningCandidateIndex].name;
    }
}
