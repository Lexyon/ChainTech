pragma solidity ^0.4.11;

// Standard contract for promulgation of a norm

import "../standardProcedure.sol";
import "../standardOrgan.sol";


contract promulgationProcedure is Procedure{
    // 1: Presidential Election
    // 2: Membership addition
    // 3: Constitutionnal reform
    // 4: Norm promulgation
    // 5: Moderators election
    // 6: Simple nomination
    // 7: Cooptation
    int public procedureTypeNumber = 7;

    // Which organ will be affected
    address public membersOrganContract;

    // Organ in which the voters with veto power are registered
    address public membersWithVetoOrganContract;

    // Organ in which final promulgators are listed
    address public finalPromulgatorsOrganContract;

    // ############## Variable to set up when declaring the procedure
    // ####### Vote creation process

    // ####### Voting process
    // Time for participant to vote
    uint public votingPeriodDuration;

    // Time for the final promulgators to promulgate
    uint public promulgationPeriodDuration;

    // ####### Resolution process
    // Minimum participation to validate election
    uint public quorumSize;

    // Variable of the procedure to keep track of propositions
    uint public totalPropositionNumber;

    // Proposition structure
    struct Proposition {
        // **** Voting variables
        // Mapping to track user votes
        mapping(address => bool) hasUserVoted;
        // Time of proposition creation
        uint startDate;
        // Was the proposition accepted?
        bool wasAccepted;
        // Was the proposition counted?
        bool wasCounted;
        // Was the proposition acted upon?
        bool wasEnacted;
        // How many people voted YES?
        uint voteFor;
        // How many people voted?
        uint totalVoteCount;
        // Was the proposition vetoed by the Vetoing members?
        uint vetoCount;
        // Was the proposition validated by the Vetoing members?
        uint notVetoCount;
        // How many members need to vote to enact proposition?
        uint requiredQuorum;
        // Proposition details
        address candidateAddress;
        string name;
        bytes32 ipfsHash; // ID of proposal on IPFS
        uint8 hash_function;
        uint8 size;
    }


    // A dynamically-sized array of `Proposition` structs.
    Proposition[] propositions;

    // Dynamic size array of status of propositions
    bool[] public propositionsWaitingEndOfVote;
    bool[] public propositionsWaitingPromulgation;

    // Mapping each proposition to the user creating it
    mapping (address => uint[]) public propositionToUser;    

    // Mapping each proposition to the user who participated
    mapping (address => uint[]) public propositionToVoter;

    // Mapping each proposition to the user vetoing it
    mapping (address => uint[]) public propositionToVetoer;

    // Mapping each proposition to the user promulgating it
    mapping (address => uint[]) public propositionToPromulgator;

    

    // Events
    event createPropositionEvent(address _candidateAddress, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size);
    event voteOnProposition(address _from, uint _propositionNumber);
    event vetoProposition(address _from, uint _propositionNumber, bool _decision);
    event countVotes(address _from, uint _propositionNumber);
    event promulgatePropositionEvent(address _from, uint _propositionNumber);

    /// Create a new ballot to choose one of `proposalNames`.
    function createProposition(string _name, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size) public returns (uint propositionNumber){

            // Checking that the proposition is not made on an existing member
            Organ membersOrgan = Organ(membersOrganContract);
            require(!membersOrgan.isNorm(msg.sender));

            // Creating new proposition 
            Proposition memory newProposition;
            
            // Calculating required quorum
            newProposition.requiredQuorum = membersOrgan.getActiveNormNumber()*quorumSize/100;
            if (newProposition.requiredQuorum == 0){
                newProposition.requiredQuorum = 1;
            }
            delete membersOrgan;

            
            newProposition.candidateAddress = msg.sender;
            newProposition.ipfsHash = _ipfsHash;
            newProposition.hash_function = _hash_function;
            newProposition.size = _size;
            newProposition.name = _name;

            // Instanciating proposition

            newProposition.startDate = now;
            newProposition.wasEnacted = false;
            newProposition.wasCounted = false;
            newProposition.wasAccepted = false;
            newProposition.totalVoteCount = 0;
            newProposition.voteFor = 0;
            newProposition.vetoCount = 0;
            newProposition.notVetoCount = 0;

            // newProposition.voteAgainst = 0;
            propositions.push(newProposition);
            delete newProposition;

            propositionNumber = propositions.length - 1;

            // Tracking propositions being deposed
            totalPropositionNumber += 1;
            propositionToUser[msg.sender].push(propositionNumber);
            propositionsWaitingEndOfVote.push(true);
            propositionsWaitingPromulgation.push(false);

            // proposition creation event
            createPropositionEvent(msg.sender, _ipfsHash, _hash_function, _size);

    }

    // Vote for a proposition
    function vote(uint _propositionNumber, bool _acceptProposition) public {

        // Check the voter is able to vote on a proposition
        Organ membersOrgan = Organ(membersOrganContract);
        require(membersOrgan.isNorm(msg.sender));
        delete membersOrgan;
        
        // Check if voter already voted
        require(!propositions[_propositionNumber].hasUserVoted[msg.sender]);

        // Check if vote is still active
        require(!propositions[_propositionNumber].wasCounted);

        // Adding vote
        if(_acceptProposition == true)
        {propositions[_propositionNumber].voteFor += 1;}

        // Log that user voted
        propositions[_propositionNumber].hasUserVoted[msg.sender] = true;
        
        // Adding vote count
        propositions[_propositionNumber].totalVoteCount += 1;

        // Log that user voted on this proposition
        propositionToVoter[msg.sender].push(_propositionNumber);

        // create vote event
        voteOnProposition(msg.sender, _propositionNumber);
    }

        /// Veto a candidate
    function veto(uint _propositionNumber, bool _acceptProposition) public {

        // Check if voter already voted
        require(!propositions[_propositionNumber].hasUserVoted[msg.sender]);

        // Check the voter is able to veto the proposition
        Organ membersWithVetoOrgan = Organ(membersWithVetoOrganContract);
        require(membersWithVetoOrgan.isNorm(msg.sender));
        delete membersWithVetoOrgan;
        
        // Check if vote is still active
        require(!propositions[_propositionNumber].wasCounted);

        // Log decision
        if (_acceptProposition) {
            propositions[_propositionNumber].notVetoCount += 1;
        }
       else {
            propositions[_propositionNumber].vetoCount += 1;
       }

       // Log that user voted
        propositions[_propositionNumber].hasUserVoted[msg.sender] = true;

        // Log that user vetoed this proposition
        propositionToVetoer[msg.sender].push(_propositionNumber);

        //  Create veto event
        vetoProposition(msg.sender, _propositionNumber, _acceptProposition);

    }

    // The vote is finished and we close it. This does not trigger the outcome of the vote. PromulgateProposition() should be called after
    function endPropositionVote(uint _propositionNumber) public returns (bool hasBeenAccepted) {
        // We check if the vote was already counted
        require(!propositions[_propositionNumber].wasCounted);

        // Checking that the vote can be closed
        require(propositions[_propositionNumber].startDate + votingPeriodDuration < now);

        // Checking that the vote received enough votes to be closed
        require((propositions[_propositionNumber].totalVoteCount >= propositions[_propositionNumber].requiredQuorum));

        // Checking if members with vetoed blocked/forced the proposition
        Organ membersWithVetoOrgan = Organ(membersWithVetoOrganContract);


        delete membersWithVetoOrgan;
        // We check that Quorum was obtained and that a majority of votes were cast in favor of the proposition
        if (propositions[_propositionNumber].vetoCount >= membersWithVetoOrgan.getActiveNormNumber())
            {hasBeenAccepted=false;
                propositions[_propositionNumber].wasEnacted = true;}
        else if ((propositions[_propositionNumber].notVetoCount >= membersWithVetoOrgan.getActiveNormNumber()) || (propositions[_propositionNumber].voteFor*2 > propositions[_propositionNumber].totalVoteCount) )
            {hasBeenAccepted = true;}
        else 
            {hasBeenAccepted=false;
            propositions[_propositionNumber].wasEnacted = true;}


        // ############## Updating ballot values if vote concluded
        propositions[_propositionNumber].wasCounted = true;
        propositions[_propositionNumber].wasAccepted = hasBeenAccepted;
        propositionsWaitingEndOfVote[_propositionNumber] = false;
        propositionsWaitingPromulgation[_propositionNumber] = true;

        countVotes(msg.sender, _propositionNumber);
    }

    function promulgateProposition(uint _propositionNumber) public
    {
        // Checking if ballot was already enforced
        require(!propositions[_propositionNumber].wasEnacted );

        // Checking the ballot was counted
        require(propositions[_propositionNumber].wasCounted);

        // If promulgation is happening before endOfVote + promulgationPeriodDuration, check caller is an official promulgator
        if (now < propositions[_propositionNumber].startDate + votingPeriodDuration + promulgationPeriodDuration)
            {        // Check the voter is able to promulgate the proposition
            Organ promulgatorsOrgan = Organ(finalPromulgatorsOrganContract);
            require(promulgatorsOrgan.isNorm(msg.sender));
            delete promulgatorsOrgan;
            }

        // Checking the ballot was accepted
        require(propositions[_propositionNumber].wasAccepted);

        // We initiate the Organ interface to add a norm

        Organ membersOrgan = Organ(membersOrganContract);
         // Adding a new norm
        membersOrgan.addNorm(propositions[_propositionNumber].candidateAddress, propositions[_propositionNumber].name , propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size );
                
            

        
        propositions[_propositionNumber].wasEnacted = true;
        propositionsWaitingPromulgation[_propositionNumber] = false;
        propositionToPromulgator[msg.sender].push(_propositionNumber);
        // promulgation event
        promulgatePropositionEvent(msg.sender, _propositionNumber);

    }

//         //////////////////////// Functions to communicate with other contracts
//     function getPropositionDetails(uint _propositionNumber) public view returns (address _addressToAdd, address _addressToRemove, bytes32 _ipfsHash, uint8 _hash_function, uint8 _size){
//         return (propositions[_propositionNumber].contractToAdd, propositions[_propositionNumber].contractToRemove, propositions[_propositionNumber].ipfsHash, propositions[_propositionNumber].hash_function, propositions[_propositionNumber].size);
//     }
//     function getPropositionDates(uint _propositionNumber) public view returns (uint _startDate, uint _votingPeriodEndDate, uint _promulgatorWindowEndDate){
//         return (propositions[_propositionNumber].startDate, propositions[_propositionNumber].votingPeriodEndDate, propositions[_propositionNumber].votingPeriodEndDate + promulgationPeriodDuration);
//     }
//     function getPropositionStatus(uint _propositionNumber) public view returns (bool _wasCounted, bool _wasEnacted){
//         return (propositions[_propositionNumber].wasCounted, propositions[_propositionNumber].wasEnacted);
//     }
//     function getVotedPropositionResults(uint _propositionNumber) public view returns (uint _startDate, uint _totalVoteCount, uint _voteFor, bool _wasVetoed, bool _wasAccepted){
//         require(propositions[_propositionNumber].wasCounted);
//         return (propositions[_propositionNumber].startDate, propositions[_propositionNumber].totalVoteCount, propositions[_propositionNumber].voteFor, propositions[_propositionNumber].wasVetoed, propositions[_propositionNumber].wasAccepted);
//         }
//     function getPropositionsCreatedByUser(address _userAddress) public view returns (uint[])
//     {return propositionToUser[_userAddress];}    
//     function getPropositionsVetoedByUser(address _userAddress) public view returns (uint[])
//     {return propositionToVetoer[_userAddress];}  
//     function getPropositionsPromulgatedByUser(address _userAddress) public view returns (uint[])
//     {return propositionToPromulgator[_userAddress];}  
//     function getPropositionsUsedByUser(address _userAddress) public view returns (uint[])
//     {return propositionToVoter[_userAddress];}  
//     function haveIVoted(uint propositionNumber) public view returns (bool IHaveVoted)
//     {return propositions[propositionNumber].hasUserVoted[msg.sender];}

}

