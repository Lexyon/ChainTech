pragma solidity ^0.4.11;

// Standard contract for a presidential election procedure

import "../standardProcedure.sol";
import "../standardOrgan.sol";

contract exclusionProcedure is Procedure{

    // 1: Presidential Election
    // 2: Membership addition
    // 3: Constitutionnal reform
    // 4: Norm promulgation
    // 5: Moderators election
    // 6: Simple nomination
    // 7: Cooptation
    // 8: Exclusion
    int public procedureTypeNumber = 8;
    // address public affectedOrganContract;
    address public authorizedNominatersOrgan;

    // Time to execute an exclusion
    uint exclusionVoteTime;

    struct Exclusion {

        address memberToExcludeAddress;
        address targetOrgan;
        // Proposal details
        string name;
        bytes32 ipfsHash; // ID of proposal on IPFS
        uint8 hash_function;
        uint8 size;
        // Number of votes
        uint exclusionVote;
        // Time variable
        uint startDate;
        // Has nominator voted?
        mapping(address => bool) hasUserVoted;
        // State variable
        bool isFinished;
        bool wasEnacted;
    }

    Exclusion[] public exclusions;

    // Mapping each exclusion to the user creating it
    mapping (address => uint[]) public exclusionToNominator;    

    // Mapping each proposition to the user who participated
    mapping (address => uint[]) public exclusionToVoter;

    event votedToExcludeAMember(address _nominator, address _member);
    event excludedAMember(address _excludedMember, address _organAddress);

    function proposeExclusion(address _targetOrgan, address _memberToRemove, string _name, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size) public returns (uint exclusionNumber) {
        // Checking if caller is an admin
        Organ authorizedNominatorsInstance = Organ(authorizedNominatersOrgan);
        require(authorizedNominatorsInstance.isNorm(msg.sender));
        delete authorizedNominatorsInstance;

        // Check that the member to remove is indeed in the member registry 
        Organ targetOrganInstance = Organ(_targetOrgan);
        require(targetOrganInstance.isNorm(_memberToRemove));

        // Check that the current procedure can indeed remove members
        bool canAdd;
        bool canDelete;
        (canAdd, canDelete) = targetOrganInstance.isAdmin(address(this));
        require(canDelete);
        delete targetOrganInstance;


        // Creating exclusion object

        Exclusion memory newExclusion;
        newExclusion.memberToExcludeAddress = _memberToRemove;
        newExclusion.targetOrgan = _targetOrgan;
        newExclusion.name = _name;
        newExclusion.ipfsHash = _ipfsHash;
        newExclusion.hash_function = _hash_function;
        newExclusion.size = _size;
        newExclusion.startDate = now;
        newExclusion.isFinished = false;
        newExclusion.wasEnacted = false;
        newExclusion.exclusionVote = 0;

        exclusionNumber = exclusions.push(newExclusion);

        // Logging that the nominater wishes to ban the member
        exclusions[exclusionNumber].hasUserVoted[msg.sender] = true;

        // Logging how many votes the member has against him
        exclusions[exclusionNumber].exclusionVote += 1; 
        // Event
        votedToExcludeAMember(msg.sender, _memberToRemove);

        return(exclusionNumber);

    }
    
    function voteForExclusion(uint _exclusionNumber) public {

        // Checking if caller is an admin
        Organ authorizedNominatorsInstance = Organ(authorizedNominatersOrgan);
        require(authorizedNominatorsInstance.isNorm(msg.sender));
        delete authorizedNominatorsInstance;

        // Logging that the nominater wishes to ban the member
        exclusions[_exclusionNumber].hasUserVoted[msg.sender] = true;

        // Logging how many votes the member has against him
        exclusions[_exclusionNumber].exclusionVote += 1; 

        // Event
        votedToExcludeAMember(msg.sender, exclusions[_exclusionNumber].memberToExcludeAddress);



        // Checking that the nomination procedure is an admin to the target organ

    }

    function executeExclusion(uint _exclusionNumber) public {
        // Checking if caller is an admin
        Organ authorizedNominatorsInstance = Organ(authorizedNominatersOrgan);
        require(authorizedNominatorsInstance.isNorm(msg.sender));

        // Retrieving nominator number
        uint nominatorNumber = authorizedNominatorsInstance.getActiveNormNumber();
        delete authorizedNominatorsInstance;
        // Check if there is enough vote to ban member
        if (exclusions[_exclusionNumber].exclusionVote >= nominatorNumber){
            Organ targetOrganInstance = Organ(exclusions[_exclusionNumber].targetOrgan);
            targetOrganInstance.remNorm(targetOrganInstance.getAddressPositionInNorm(exclusions[_exclusionNumber].memberToExcludeAddress));
            excludedAMember( exclusions[_exclusionNumber].memberToExcludeAddress, exclusions[_exclusionNumber].targetOrgan);
        }
    }


}