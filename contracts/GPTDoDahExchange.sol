// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@uniswap/v2-periphery/contracts/libraries/UniswapV2OracleLibrary.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./GPTDoCoin.sol";
import "./GPTDoDahTreasury.sol";


/**
 * 
           .-..-.    .-.;;;;;;'                                                                 
    .;;.`-'  (_) )-.(_)  .;          .'                .'        .;                             
   ;; (_;      .:   \    :      .-..'  .-.        .-..'  .-.     ;;-.    .-.   .-.  . ,';.,';.  
  ;;          .:'    ) .:'`;;;.:   ;  ;   ;'`;;;.:   ;  ;   :   ;;  ;.-.;     ;   ;';;  ;;  ;;  
 ;;    `;;' .-:. `--'.-:._     `:::'`.`;;'       `:::'`.`:::'-'.;`  ``-'`;;;;'`;;' ';  ;;  ';   
 `;.___.'  (_/      (_/  `-                                                       _;        `-' 
 
 .-.;;;;;;' .:                            .-                                                
(_)  .;     ::                    .;;;.`-'.;.    _           .;                             
     : .-.  ;;.-.  .-.  . ,';.   ;;  (_)     `.,' '   .-.    ;;-. .-.    . ,';.  ,:.,' .-.  
   .:';   ;';; .'.;.-'  ;;  ;;   .;;; .-.    ,'`.    ;      ;;  ;;   :   ;;  ;; :   ;.;.-'  
 .-:._`;;'_.'`  `.`:::'';  ;;   ;;  .;  ;  -'    `._.`;;;;'.;`  ``:::'-'';  ;;   `-:' `:::' 
(_/  `-                ;    `.  `;.___.'                                ;    `.-._:'        
            ~~~~~~~~~~~~~   GPT-do-dah.com Token Exchange    ~~~~~~~~~~~~~~~~

 * @title GPTDoDahExchange
 * @author Jeremiah O. Nolet <contracts@gpt-do-dah.com>
 * @notice The initial token launch exchange for the GPTDoDah ecosystem
 *  - https://gptdodah.com
 */
contract GPTDoDahExchange is AccessControl, ReentrancyGuard {

    GPTDoDahTreasury public gptDoDahTreasury;
    GPTDoCoin public gptDoCoin;

    IUniswapV2Router02 public uniswapRouter;
    address public gptDoDahPool;

    uint256 public constant MINIMUM_PURCHASE = 1 * 10 ** 17; // 0.1 WETH
    uint256 public constant TOKEN_RATIO = 180; // %0.0055555 :: 1/180
    
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    bool public uniswapPoolCreated;

    event TokenPurchase(address indexed buyer, uint256 amount);
    event Withdrawal(uint256 amount, uint256 timestamp);

    constructor(
        address _gptDoDahToken,
        address _uniswapRouter,
        address payable _gptDoDahTreasury
    ) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        gptDoCoin = GPTDoCoin(_gptDoDahToken);
        gptDoDahTreasury = GPTDoDahTreasury(_gptDoDahTreasury);
    }
    
    /**
     * @dev Modifier to check if trading is enabled.
     */
    modifier tradingEnabled {
        require(uniswapPoolCreated, "Trading not yet enabled!");
        _;
    }

    /**
     * @dev Creates a new Uniswap Trading Pool for the GPTD/WETH pair
     * @notice can only be called once during contract setup by ADMIN_ROLE
     */
    function createUniswapPool() external payable onlyRole(ADMIN_ROLE) returns (address) {
        require(!uniswapPoolCreated, "Uniswap pool already created");
        require(gptDoCoin.balanceOf(address(this)) > 0, "No tokens provided!");
         
        // Create a uniswap pair for this new token
        gptDoDahPool = IUniswapV2Factory(uniswapRouter.factory())
            .createPair(address(gptDoCoin), uniswapRouter.WETH());

        uniswapPoolCreated = true;
        return gptDoDahPool;
    }

    /**
    * @dev Buys GPTDoDah tokens with ETH sent along with the transaction.
    * @return A boolean indicating whether the tokens were successfully purchased.
    */
    function buyTokens() public payable returns(bool) {
        require(msg.value >= MINIMUM_PURCHASE, "Purchase amount below minimum");
        uint256 wethAmount = msg.value;
        return _buyTokens(wethAmount);
    }

    /**
     * @dev Withdraws the accumulated WETH to the treasury contract.
     * @return A boolean indicating whether the withdrawal was successful.
     */
    function withdraw() public onlyRole(ADMIN_ROLE) returns(bool) {
        
        uint256 ethBalance = address(this).balance;
        
        // Transfer ETH to Treasury
        require(gptDoDahTreasury.depositEth{value: ethBalance}(), "Unable to deposit.");
        emit Withdrawal(ethBalance, block.timestamp);

        return true;
    }

    receive() external payable {}

    /**
    * @dev Internal function to buy GPTDoDah tokens with a specified amount of WETH.
    * @param wethAmount The amount of WETH to be used for the purchase.
    * @return A boolean indicating whether the tokens were successfully purchased.
    */
    function _buyTokens(uint256 wethAmount) nonReentrant private returns (bool) {

        uint256 tokenAmount = wethAmount * TOKEN_RATIO; // 1/180 :: 1 token = %0.0055555 of 1 ETH
        uint256 poolAmount = wethAmount / 2;

        // Add liquidity to the pool with %5 of tokens
       require( _addLiquidity(tokenAmount / 20, poolAmount), "Failed to add liquidity!");

        // Transfer purchased tokens to buyer
        gptDoCoin.transfer(msg.sender, tokenAmount);
        emit TokenPurchase(msg.sender, tokenAmount);
        return true;
    }

     function _addLiquidity(uint256 tokenAmount, uint256 wethAmount) private tradingEnabled returns(bool) {

        gptDoCoin.approve(address(uniswapRouter), tokenAmount);
        uniswapRouter.addLiquidityETH{value: wethAmount}(
            address(gptDoCoin),
            1,
            0,
            0,
            address(gptDoDahTreasury),
            block.timestamp
        );
        return true;
    }
}

