// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken_1 is ERC20 {
    address public owner;
    uint8 private _decimals;

    constructor() ERC20("Vimer", "V") {
        owner = msg.sender;
        _decimals = 18;
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    // Создание произвольного количества токенов
    function mint(address to, uint256 amount) external {
        require(msg.sender == owner, "Only owner can mint");
        _mint(to, amount);
    }

    // Покупка токенов
    function buyTokens() external payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        uint256 tokensToSend = msg.value * 100; 
        _mint(msg.sender, tokensToSend);
    }

    // Получение количества знаков после запятой
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    // Получение названия токена
    function getTokenName() external pure returns (string memory) {
        return "Vimer";
    }

    // Получение символа токена
    function getTokenSymbol() external pure returns (string memory) {
        return "V";
    }
}