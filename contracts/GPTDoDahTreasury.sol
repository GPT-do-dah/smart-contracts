// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";


/**
 * 
           .-..-.    .-.;;;;;;'                                                                 
    .;;.`-'  (_) )-.(_)  .;          .'                .'        .;                             
   ;; (_;      .:   \    :      .-..'  .-.        .-..'  .-.     ;;-.    .-.   .-.  . ,';.,';.  
  ;;          .:'    ) .:'`;;;.:   ;  ;   ;'`;;;.:   ;  ;   :   ;;  ;.-.;     ;   ;';;  ;;  ;;  
 ;;    `;;' .-:. `--'.-:._     `:::'`.`;;'       `:::'`.`:::'-'.;`  ``-'`;;;;'`;;' ';  ;;  ';   
 `;.___.'  (_/      (_/  `-                                                       _;        `-' 
             .-.;;;;;;'                                             
            (_)  .;                                                 
                 :  .;.::..-.  .-.       .   ,  :    .;.::..    .-. 
               .:'  .;  .;.-' ;   :    .';  ;   ;    .;     `:  ;   
             .-:._.;'    `:::'`:::'-'.' .'.'`..:;._.;'       `.'    
            (_/  `-                 '                     -.;'      
            ~~~~~~~~~~~~~   GPT-do-dah.com GPT-do-dah Treasury    ~~~~~~~~~~~~~~~~
            
 * @title GPTDoDahTreasury
 * @author Jeremiah O. Nolet <contracts@gpt-do-dah.com>
 * @notice The Team Treasury contract for the GPTDoDah bootstrap token launch.
 */
contract GPTDoDahTreasury is AccessControl {
    address public chamberlain;

    bytes32 public constant EXCHEQUER_ROLE = keccak256("EXCHEQUER_ROLE");

    /**
     * @dev Contract constructor.
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EXCHEQUER_ROLE, msg.sender);
        chamberlain = msg.sender;
    }

    /**
     * @dev Allows the deposit of Ether.
     */
    function depositEth() external payable returns(bool) {
        return true;
    }

    /**
     * @dev Allows the release of Ether by assigned Role.
     */
    function releaseEth() external onlyRole(EXCHEQUER_ROLE) returns(bool) {
        
        require(address(this).balance > 0, "Insufficient balance");
        payable(chamberlain).transfer(address(this).balance);
        return true;
    }

    /**
     * @dev Allows the receiving of Ether.
     */
    receive() external payable {}
}