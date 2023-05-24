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
       .-.              /\                 .-.;;;;;;'                                             
      (_) )-.       _  / |     .;;.    .- (_)  .;                                                 
        .:   \     (  /  |  . ;;  `;`-'        :  .;.::..-.  .-.       .   ,  :    .;.::..    .-. 
       .:'    \     `/.__|_.';;    :.        .:'  .;  .;.-' ;   :    .';  ;   ;    .;     `:  ;   
     .-:.      ).:' /    |  ;;     ;'      .-:._.;'    `:::'`:::'-'.' .'.'`..:;._.;'       `.'    
    (_/  `----'(__.'     `-'`;.__.'       (_/  `-                 '                     -.;'      
                ~~~~~~~~~~~~~   GPT-do-dah.com DAO Treasury   ~~~~~~~~~~~~~~~~
            
 * @title GPTDoDahTreasury
 * @author Jeremiah O. Nolet <contracts@gpt-do-dah.com>
 * @notice The Team Treasury contract for the GPTDoDah bootstrap token launch.
 */
contract GPTDoDAOTreasury is AccessControl {
    address public chamberlain;
    uint256 public balance;

    bytes32 public constant EXCHEQUER_ROLE = keccak256("EXCHEQUER_ROLE");
    bytes32 public constant GALLERY_ADMIN_ROLE = keccak256("GALLERY_ADMIN_ROLE");

    mapping(address => mapping(address => uint256)) public depositedERC20;  // Token => Depositor => Amount
    mapping(address => mapping(uint256 => address)) public depositedERC721;  // Token => TokenId => Depositor
    
    mapping(address => 
        mapping(uint256 => 
            mapping(address => uint256))) public depositedERC1155;  // Token => TokenId => Depositor => Amount

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(EXCHEQUER_ROLE, msg.sender);
        _grantRole(GALLERY_ADMIN_ROLE, msg.sender);
        chamberlain = msg.sender;
    }

    function depositEth() external payable {
        balance += msg.value;
    }

    function releaseEth(uint256 amount) external onlyRole(EXCHEQUER_ROLE) {
        require(amount <= balance, "Insufficient balance");
        balance -= amount;
        payable(chamberlain).transfer(amount);
    }

    function depositERC20(address token, uint256 amount) external {
        require(token != address(0), "Invalid token address");

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        depositedERC20[token][msg.sender] += amount;
    }

    function releaseERC20(address token, uint256 amount) external onlyRole(EXCHEQUER_ROLE) {
        require(token != address(0), "Invalid token address");
        require(amount <= depositedERC20[token][msg.sender], "Insufficient deposited balance");

        depositedERC20[token][msg.sender] -= amount;
        IERC20(token).transfer(chamberlain, amount);
    }

    function depositERC721(address token, uint256 tokenId) external {
        require(token != address(0), "Invalid token address");

        IERC721(token).safeTransferFrom(msg.sender, address(this), tokenId);
        depositedERC721[token][tokenId] = msg.sender;
    }

    function releaseERC721(address token, uint256 tokenId) external onlyRole(GALLERY_ADMIN_ROLE) {
        require(token != address(0), "Invalid token address");
        require(depositedERC721[token][tokenId] == msg.sender, "Invalid token deposit");

        depositedERC721[token][tokenId] = address(0);
        IERC721(token).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function depositERC1155(address token, uint256 tokenId, uint256 amount) external {
        require(token != address(0), "Invalid token address");

        IERC1155(token).safeTransferFrom(msg.sender, address(this), tokenId, amount, "");
        depositedERC1155[token][tokenId][msg.sender] += amount;
    }

    function releaseERC1155(address token, uint256 tokenId, uint256 amount) external onlyRole(GALLERY_ADMIN_ROLE) {
        require(token != address(0), "Invalid token address");
        require(amount <= depositedERC1155[token][tokenId][msg.sender], "Insufficient deposited balance");

        depositedERC1155[token][tokenId][msg.sender] -= amount;
        IERC1155(token).safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
    }
    
    receive() external payable {}
}