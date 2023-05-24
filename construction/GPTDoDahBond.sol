// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


/**
 * 
           .-..-.    .-.;;;;;;'                                                                 
    .;;.`-'  (_) )-.(_)  .;          .'                .'        .;                             
   ;; (_;      .:   \    :      .-..'  .-.        .-..'  .-.     ;;-.    .-.   .-.  . ,';.,';.  
  ;;          .:'    ) .:'`;;;.:   ;  ;   ;'`;;;.:   ;  ;   :   ;;  ;.-.;     ;   ;';;  ;;  ;;  
 ;;    `;;' .-:. `--'.-:._     `:::'`.`;;'       `:::'`.`:::'-'.;`  ``-'`;;;;'`;;' ';  ;;  ';   
 `;.___.'  (_/      (_/  `-                                .-.                    _;        `-' 
        .;.       .-.                  .'                 (_) )-.                     .' 
          `;     ;'   .-.     .;.::..-..'  .-.  . ,';.      .: __)   .-.  . ,';. .-..'   
           ;;    ;   ;   :    .;   :   ; .;.-'  ;;  ;;     .:'   `. ;   ;';;  ;;:   ;    
          ;;  ;  ;;  `:::'-'.;'    `:::'`.`:::'';  ;;      :'      )`;;' ';  ;; `:::'`.  
          `;.' `.;'                            ;    `.  (_/  `----'      ;    `.         
                ~~~~~~~~~~~~~   GPT-do-dah.com Warden Bond    ~~~~~~~~~~~~~~~~

 * @title GPTDoDahExchange
 * @author Jeremiah O. Nolet <contracts@gpt-do-dah.com>
 * @notice The initial token launch exchange for the GPTDoDah ecosystem
 *  - https://gptdodah.com
 */
contract GPTDoDahBond is ERC1155, ERC1155Burnable, ERC1155Pausable, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant WARDEN_ADMIN_ROLE = keccak256("WARDEN_ADMIN_ROLE");
    Counters.Counter private _bondIdCounter;

    constructor() ERC1155("https://gptdodao.com/ipfs/") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(WARDEN_ADMIN_ROLE, msg.sender);
    }

    function createWardenBond(address to, uint256 amount) public onlyRole(WARDEN_ADMIN_ROLE) returns (uint256 _bondId) {
        uint256 bondId = _bondIdCounter.current();
        _bondIdCounter.increment();
        _mint(to, bondId, amount, "");
        return bondId;
    }

    function burnWardenBond(address account, uint256 bondId, uint256 amount) public onlyRole(WARDEN_ADMIN_ROLE) {
        _burn(account, bondId, amount);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address operator, 
        address from,
        address to, 
        uint256[] memory ids, 
        uint256[] memory amounts, 
        bytes memory data)
            internal
            whenNotPaused
            override(ERC1155, ERC1155Pausable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
