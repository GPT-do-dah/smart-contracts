// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorTimelockControl.sol";


/**
 * 
           .-..-.    .-.;;;;;;'                                                                 
    .;;.`-'  (_) )-.(_)  .;          .'                .'        .;                             
   ;; (_;      .:   \    :      .-..'  .-.        .-..'  .-.     ;;-.    .-.   .-.  . ,';.,';.  
  ;;          .:'    ) .:'`;;;.:   ;  ;   ;'`;;;.:   ;  ;   :   ;;  ;.-.;     ;   ;';;  ;;  ;;  
 ;;    `;;' .-:. `--'.-:._     `:::'`.`;;'       `:::'`.`:::'-'.;`  ``-'`;;;;'`;;' ';  ;;  ';   
 `;.___.'  (_/      (_/  `-                                                       _;        `-' 

       .-.              /\                          .-.                                         
      (_) )-.       _  / |     .;;.    .-    .;;.`-'          .-.                               
        .:   \     (  /  |  . ;;  `;`-'     ;; (_;   .-. _.;  :  .-.   .;.::.. ,';. .-.  .;.::. 
       .:'    \     `/.__|_.';;    :.      ;;       ;   ;';   ;.;.-'   .;    ;;  ;;;   ;'.;     
     .-:.      ).:' /    |  ;;     ;'     ;;    `;;'`;;'  `._.' `:::'.;'    ';  ;; `;;'.;'      
    (_/  `----'(__.'     `-'`;.__.'       `;.___.'                          ;    `.             
                ~~~~~~~~~~~~~   GPT-do-dah.com DAO Governor   ~~~~~~~~~~~~~~~~

 * @title GPTDoDAOGovernor
 * @author Jeremiah O. Nolet <contracts@gpt-do-dah.com>
 * @notice The official Governor contract for the GPT-do-dah DAO
 *  - https://gptdodah.com
 */
contract GPTDoDAOGovernor is Governor, 
    GovernorSettings, 
    GovernorCountingSimple, 
    GovernorVotes, 
    GovernorVotesQuorumFraction, 
    GovernorTimelockControl {
    constructor(IVotes _token, TimelockController _timelock)
        Governor("GPTdoDAOGovernor")
        GovernorSettings(50 /* 50 block */, 50400 /* 1 week */, 100)
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
        GovernorTimelockControl(_timelock) 
        {
        }

    function propose(
        address[] memory targets, 
        uint256[] memory values, 
        bytes[] memory calldatas, 
        string memory description
    )
        public
        override(Governor, IGovernor)
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    // The following functions are overrides required by Solidity.
    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(Governor, GovernorTimelockControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _execute(
        uint256 proposalId, 
        address[] memory targets, 
        uint256[] memory values, 
        bytes[] memory calldatas, 
        bytes32 descriptionHash
    )
        internal
        override(Governor, GovernorTimelockControl)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets, 
        uint256[] memory values, 
        bytes[] memory calldatas, 
        bytes32 descriptionHash
    )
        internal
        override(Governor, GovernorTimelockControl)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(Governor, GovernorTimelockControl)
        returns (address)
    {
        return super._executor();
    }

}
