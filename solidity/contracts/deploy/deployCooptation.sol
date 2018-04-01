pragma solidity ^0.4.11;

// Standard contract for a presidential election procedure

import "../standardProcedure.sol";
import "../standardOrgan.sol";
import "../procedures/cooptationProcedure.sol";




contract deployCooptation is cooptationProcedure {

    function deployCooptation (address _membersOrganContract, address _membersWithVetoOrganContract, address _finalPromulgatorsOrganContract) public {

    membersOrganContract = _membersOrganContract;
    membersWithVetoOrganContract = _membersWithVetoOrganContract;
    finalPromulgatorsOrganContract = _finalPromulgatorsOrganContract; 

    quorumSize = 40;
    // votingPeriodDuration = 3 minutes;
    // promulgationPeriodDuration = 3 minutes;

    votingPeriodDuration = 10 seconds;
    promulgationPeriodDuration = 10 seconds;

    isAnOrgan = false;
    isAProcedure = true;
    kelsenVersionNumber = 1;

    }
}
