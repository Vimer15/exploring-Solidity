// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyToken_1 is ERC20 {
    constructor() ERC20("Vimer", "V") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

contract MyToken_2 is ERC20 {
    constructor() ERC20("BarS", "BS") {
        _mint(msg.sender, 1 * 10 ** decimals());
    }
}

contract MyToken_3 is ERC20 {
    constructor() ERC20("TokenC", "C") {
        _mint(msg.sender, 500000 * 10 ** decimals());
    }
}

contract MyToken_4 is ERC20 {
    constructor() ERC20("TokenD", "D") {
        _mint(msg.sender, 200000 * 10 ** decimals());
    }
}

contract TokenSwap {
    ERC20[4] public tokens; // Массив из четырёх токенов
    address public owner;
    mapping(uint8 => mapping(uint8 => uint256)) public exchangeRates; // Курсы обмена между токенами

    constructor(
        address _token1,
        address _token2,
        address _token3,
        address _token4
    ) {
        tokens[0] = ERC20(_token1);
        tokens[1] = ERC20(_token2);
        tokens[2] = ERC20(_token3);
        tokens[3] = ERC20(_token4);
        owner = msg.sender;
    }

    // Устанавливаем курс обмена между токенами
    function setExchangeRate(uint8 tokenAIndex, uint8 tokenBIndex, uint256 rate) public {
        require(msg.sender == owner, "Only owner can set exchange rates");
        require(rate > 0, "Exchange rate must be greater than 0");
        exchangeRates[tokenAIndex][tokenBIndex] = rate;
    }

    // Функция обмена токенов
    function swap(uint8 fromTokenIndex, uint8 toTokenIndex, uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");

        // Проверяем, что пользователь одобрил перевод токенов
        require(
            tokens[fromTokenIndex].allowance(msg.sender, address(this)) >= amount,
            "Insufficient allowance"
        );

        // Рассчитываем количество токенов для отправки
        uint256 amountToReceive = amount * exchangeRates[fromTokenIndex][toTokenIndex];

        // Проверяем, что контракт имеет достаточно токенов для обмена
        require(
            tokens[toTokenIndex].balanceOf(address(this)) >= amountToReceive,
            "Not enough tokens in contract"
        );

        // Переводим токены от пользователя в контракт
        tokens[fromTokenIndex].transferFrom(msg.sender, address(this), amount);

        // Отправляем токены пользователю
        tokens[toTokenIndex].transfer(msg.sender, amountToReceive);
    }

    // Функция для пополнения контракта токенами
    function deposit(uint8 tokenIndex, uint256 amount) public {
        require(msg.sender == owner, "Only owner can deposit tokens");
        tokens[tokenIndex].transferFrom(msg.sender, address(this), amount);
    }

    // Функции для проверки балансов токенов
    function getTokenBalance(address account, uint8 tokenIndex) public view returns (uint256) {
        return tokens[tokenIndex].balanceOf(account);
    }

    function getContractTokenBalance(uint8 tokenIndex) public view returns (uint256) {
        return tokens[tokenIndex].balanceOf(address(this));
    }
}
