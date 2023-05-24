// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/utils/Counters.sol";


/**
 * 
           .-..-.    .-.;;;;;;'                                                                 
    .;;.`-'  (_) )-.(_)  .;          .'                .'        .;                             
   ;; (_;      .:   \    :      .-..'  .-.        .-..'  .-.     ;;-.    .-.   .-.  . ,';.,';.  
  ;;          .:'    ) .:'`;;;.:   ;  ;   ;'`;;;.:   ;  ;   :   ;;  ;.-.;     ;   ;';;  ;;  ;;  
 ;;    `;;' .-:. `--'.-:._     `:::'`.`;;'       `:::'`.`:::'-'.;`  ``-'`;;;;'`;;' ';  ;;  ';   
 `;.___.'  (_/      (_/  `-                                                       _;        `-' 
                    .-..-.    .-.;;;;;;'                  .-.              /\                
            .;;.`-'  (_) )-.(_)  .;          .'         (_) )-.       _  / |     .;;.    .- 
           ;; (_;      .:   \    :      .-..'  .-.        .:   \     (  /  |  . ;;  `;`-'   
          ;;          .:'    ) .:'`;;;.:   ;  ;   ;'`;;;..:'    \     `/.__|_.';;    :.     
         ;;    `;;' .-:. `--'.-:._     `:::'`.`;;'     .-:.      ).:' /    |  ;;     ;'     
         `;.___.'  (_/      (_/  `-                   (_/  `----'(__.'     `-'`;.__.'       
            ~~~~~~~~~~~~~   GPT-do-dah.com GPT-do-DAO NFT   ~~~~~~~~~~~~~~~~

 * @title GPTDoDAO
 * @author Jeremiah O. Nolet <contracts@gpt-do-dah.com>
 * @notice The official NFT for the GPT-do-dah DAO
 *  - https://gptdodah.com
 */
contract GPTDoDAO is ERC721, ERC721URIStorage, AccessControl, EIP712, ERC721Votes {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("GPTdoDAO", "GPTDAO") EIP712("GPTdoDAO", "1") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function safeMint(address to, string memory uri) public onlyRole(MINTER_ROLE) returns (uint _tokenId) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        return tokenId;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    // The following functions are overrides required by Solidity.
    function _afterTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Votes)
    {
        super._afterTokenTransfer(from, to, tokenId, batchSize);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://gptdodao.com/ipfs/";
    }
}