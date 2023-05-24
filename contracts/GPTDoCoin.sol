// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
           .-..-.    .-.;;;;;;'                                                                 
    .;;.`-'  (_) )-.(_)  .;          .'                .'        .;                             
   ;; (_;      .:   \    :      .-..'  .-.        .-..'  .-.     ;;-.    .-.   .-.  . ,';.,';.  
  ;;          .:'    ) .:      :   ;  ;   ;      :   ;  ;   :   ;;  ;.-.;     ;   ;';;  ;;  ;;  
 ;;    `;;' .-:. `--'.-:._     `:::'`.`;;'       `:::'`.`:::'-'.;`  ``-'`;;;;'`;;' ';  ;;  ';   
 `;.___.'  (_/      (_/  `-                                                       _;        `-' 

                       .-..-.    .-.;;;;;;                   .-._   .-._.            
                .;;.`-'  (_) )-.(_)  .;          .'        .: (_)`-'      .-.        
               ;; (_;      .:   \    :      .-..'  .-.     ::      .-.    `-' . ,';. 
              ;;          .:'    ) .:'     :   ;  ;   ;'   ::   _ ;   ;' ;'   ;;  ;; 
             ;;    `;;' .-:. `--'.-:._     `:::'`.`;;'     `: .; )`;;'_.;:._.';  ;;  
             `;.___.'  (_/      (_/  `-                      `--'            ;    `. 
                ~~~~~~~~~~~~~   GPT-do-dah.com GPT-do Coin   ~~~~~~~~~~~~~~~~
 * @title GPTDoCoin
 * @author Jeremiah O. Nolet <contracts@gpt-do-dah.com>
 * @notice The ERC20 token for the GPTDoDah ecosystem
 *  - https://gptdodah.com
 */

contract GPTDoCoin is ERC20 {
    constructor() ERC20("GPTDoDahToken", "GPTD") {
        _mint(msg.sender, 21000000 * 10 ** decimals());
    }
}
