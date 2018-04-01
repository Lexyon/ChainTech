// Organs
var deployOrgan = artifacts.require("deployOrgan")
var Organ = artifacts.require("Organ")

// Cooptation procedure
var deployCooptation = artifacts.require("deploy/deployCooptation")
var cooptationProcedure = artifacts.require("procedures/cooptationProcedure")

// Vote On Norms (exclusion of member + replacement of bureau)
var deployVoteOnNorms = artifacts.require("deploy/deployVoteOnNorms")
var voteOnNormsProcedure = artifacts.require("procedures/voteOnNormsProcedure")

// Vote on admins (Constitutionnal reform)
var deployVoteOnAdmins = artifacts.require("deploy/deployVoteOnAdmins")
var voteOnAdminsProcedure = artifacts.require("procedures/voteOnAdminsProcedure")


module.exports = function(deployer, network, accounts) {
  console.log("-------------------------------------")
  console.log("Available accounts : ")
  accounts.forEach((account, i) => console.log("-", account))
  console.log("-------------------------------------")
  console.log("-------------------------------------")
  console.log("Deploying Organs")
  console.log("-------------------------------------")
  // Creating Bureau organ
  deployer.deploy(deployOrgan, "Bureau", {from: accounts[0]}).then(() => {
  const bureauOrgan = Organ.at(deployOrgan.address)

  // Creating Members organ
  deployer.deploy(deployOrgan, "Membres", {from: accounts[0]}).then(() => {
  const membersOrgan = Organ.at(deployOrgan.address)
    console.log("-------------------------------------")
    console.log("Deploying Procedures")
    console.log("-------------------------------------")
    const threeMinutes = 60*3
    const twoDays = 60*60*24*2
    const twoWeeks = 60*60*24*7*2
    // Cooptation procedure (adding members)
    deployer.deploy(deployCooptation, membersOrgan.address, bureauOrgan.address, bureauOrgan.address, 40, threeMinutes, threeMinutes, {from: accounts[0]}).then(() => {
    const cooptation = cooptationProcedure.at(deployCooptation.address)

    // Vote On norms (excluding members)
    deployer.deploy(deployVoteOnNorms, membersOrgan.address, bureauOrgan.address, 0x0000, 0x0000, 100, twoDays, 0, {from: accounts[0]}).then(() => {
    const memberExclusion = voteOnNormsProcedure.at(deployVoteOnNorms.address)

    // Vote on norms (replacing bureau)
    deployer.deploy(deployVoteOnNorms, bureauOrgan.address, bureauOrgan.address, 0x0000, 0x0000, 65, twoDays, 0, {from: accounts[0]}).then(() => {
    const bureauReplacement = voteOnNormsProcedure.at(deployVoteOnNorms.address)

    // Vote on admins (modify DAO architecture)
    deployer.deploy(deployVoteOnAdmins, membersOrgan.address, bureauOrgan.address, 0x0000, 60, twoWeeks, 0, {from: accounts[0]}).then(() => {
    const constitutionnalReform = voteOnAdminsProcedure.at(deployVoteOnAdmins.address)
      console.log("-------------------------------------")
      console.log("Set Admins")
      console.log("-------------------------------------")
      membersOrgan.addAdmin(cooptation.address, true, false, false, false, "Cooptation procedure", {from: accounts[0]}).then(() => {
      membersOrgan.addAdmin(memberExclusion.address, false, true, false, false , "Member exclusion",  {from: accounts[0]}).then(() => {
      bureauOrgan.addAdmin(bureauReplacement.address, true, true, false, false, "Bureau replacement", {from: accounts[0]}).then(() => {
        console.log("-------------------------------------")
        console.log("Set Masters")
        console.log("-------------------------------------")
        bureauOrgan.addMaster(constitutionnalReform.address, true, true, "Constitutionnal Reform", {from: accounts[0]}).then(() => {
        membersOrgan.addMaster(constitutionnalReform.address, true, true, "Constitutionnal Reform", {from: accounts[0]}).then(() => {
          console.log("-------------------------------------")
          console.log("Set temp Admin")
          console.log("-------------------------------------")
          membersOrgan.addAdmin(accounts[0], true, true, false, false , "Temp admin",  {from: accounts[0]}).then(() => {
          bureauOrgan.addAdmin(accounts[0], true, true, false, false, "Temp admin", {from: accounts[0]}).then(() => {
            console.log("-------------------------------------")
            console.log("Populate Bureau")
            console.log("-------------------------------------")
            // bureauOrgan.addNorm(address, name, ipfsHash, hash_Function, size, {from: accounts[0]}).then(() => {
              console.log("-------------------------------------")
              console.log("Populate members list")
              console.log("-------------------------------------")
              // membersOrgan.addNorm(address, name, ipfsHash, hash_Function, size, {from: accounts[0]}).then(() => {
                console.log("-------------------------------------")
                console.log("Remove temp Admins")
                console.log("-------------------------------------")
                membersOrgan.remAdmin(accounts[0],  {from: accounts[0]}).then(() => {
                bureauOrgan.remAdmin(accounts[0], {from: accounts[0]}).then(() => {
                  console.log("-------------------------------------")
                  console.log("Remove temp Master")
                  console.log("-------------------------------------")
                    membersOrgan.remMaster(accounts[0],  {from: accounts[0]}).then(() => {
                    bureauOrgan.remMaster(accounts[0], {from: accounts[0]}).then(() => {

                    console.log("-------------------------------------")
                    console.log("System has been deployed.")
                    console.log("Organs are:")
                    console.log("    \""+membersOrgan.address+"\",  // (Members organ)")
                    console.log("    \""+bureauOrgan.address+"\",  // (Bureau organ)")
                    console.log("Procedures are:")
                    console.log("    \""+cooptation.address+"\",  // (Cooptation procedure)")
                    console.log("    \""+memberExclusion.address+"\",  // (Member Exclusion procedure)")
                    console.log("    \""+bureauReplacement.address+"\",  // (Bureau replacement procedure)")
                    console.log("    \""+constitutionnalReform.address+"\",  // (Constitutionnal reform procedure)")

              })
            })
          })
           })
            })
          })


              })
            })
          })
           })
            })
          })

              })
            })
          })
              })
            })
          

}
