// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankingSystem {
    
    struct Profile {
        string name;
        uint id;
        string login;
        string password;
        uint balance;
        bool exists;
        uint registrationDate;
    }
    
    struct Deposit {
        address userAddress;
        uint amount;
        uint depositDate;
        bool isActive;
    }
    
    mapping(address => Profile) public profiles;
    mapping(address => Deposit[]) public userDeposits;
    mapping(string => bool) public loginExists;
    
    address[] public registeredAddresses;
    uint private nextUserId = 1;
    address public owner;
    
    // событие для работы банка
    
    event UserRegistered(address indexed userAddress, uint userId, string name);
    event DepositMade(address indexed userAddress, uint amount, uint depositId);
    event WithdrawalMade(address indexed userAddress, uint amount, uint depositId);
    event BalanceUpdated(address indexed userAddress, uint newBalance);
    
    // Модификаторы для пользователей
    
    modifier onlyOwner() {
        require(msg.sender == owner, unicode"Только владелец может вызвать эту функцию");
        _;
    }
    
    modifier onlyRegistered() {
        require(profiles[msg.sender].exists, unicode"Пользователь не зарегистрирован");
        _;
    }
    
    modifier validAmount(uint amount) {
        require(amount > 0, unicode"Сумма должна быть больше 0");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    // ------------------------------Регистрация-------------------------------------
    
    function registerUser(
        string memory _name,
        string memory _login,
        string memory _password
    ) public returns (uint) {

        // Проверки
        require(!profiles[msg.sender].exists, unicode"Пользователь уже зарегистрирован");
        require(!loginExists[_login], unicode"Вход в систему уже выполнен");
        require(bytes(_name).length > 0, unicode"Имя должно быть заполненно");
        require(bytes(_login).length > 0, unicode"Логин не может быть пустым");
        require(bytes(_password).length >= 4, unicode"Слишком короткий пароль");
        
        // Создание профиля
        profiles[msg.sender] = Profile({
            name: _name,
            id: nextUserId,
            login: _login,
            password: _password,
            balance: 0,
            exists: true,
            registrationDate: block.timestamp
        });
        
        // Обновление системных данных
        loginExists[_login] = true;
        registeredAddresses.push(msg.sender);
        uint userId = nextUserId;
        nextUserId++;
        
        emit UserRegistered(msg.sender, userId, _name);
        return userId;
    }
    
    // ----------------------Просмотр профиля-----------------------
    
    function getMyProfile() public view onlyRegistered returns (
        string memory name,
        uint id,
        string memory login,
        uint balance,
        uint registrationDate,
        uint depositCount
    ) {
        Profile memory user = profiles[msg.sender];
        return (
            user.name,
            user.id,
            user.login,
            user.balance,
            user.registrationDate,
            userDeposits[msg.sender].length
        );
    }
    
    function getProfileByAddress(address userAddress) public view onlyOwner returns (
        string memory name,
        uint id,
        string memory login,
        uint balance,
        uint registrationDate
    ) {
        require(profiles[userAddress].exists, unicode"Пользователь не найден");
        Profile memory user = profiles[userAddress];
        return (
            user.name,
            user.id,
            user.login,
            user.balance,
            user.registrationDate
        );
    }
    
    // ----------------Логика работы с вкладами------------------
    
    function makeDeposit() public payable onlyRegistered validAmount(msg.value) returns (uint) {
        Profile storage user = profiles[msg.sender];
        
        // Создание вклада
        uint depositId = userDeposits[msg.sender].length;
        userDeposits[msg.sender].push(Deposit({
            userAddress: msg.sender,
            amount: msg.value,
            depositDate: block.timestamp,
            isActive: true
        }));
        
        // Обновление баланса
        user.balance += msg.value;
        
        emit DepositMade(msg.sender, msg.value, depositId);
        emit BalanceUpdated(msg.sender, user.balance);
        
        return depositId;
    }
    
    function withdrawFromDeposit(uint depositIndex, uint amount) public onlyRegistered validAmount(amount) {
        require(depositIndex < userDeposits[msg.sender].length, unicode"Не верный id для депозита");
        
        Profile storage user = profiles[msg.sender];
        Deposit storage deposit = userDeposits[msg.sender][depositIndex];
        
        // Проверки
        require(deposit.isActive, unicode"Депозит не активен");
        require(deposit.amount >= amount, unicode"Недостаточно средств на депозите");
        require(user.balance >= amount, unicode"Недостаточный общий баланс");
        
        // Обновление данных
        deposit.amount -= amount;
        user.balance -= amount;
        
        // Если вклад опустел - то делаем его не активным
        if (deposit.amount == 0) {
            deposit.isActive = false;
        }
        
        // Перевод средств
        payable(msg.sender).transfer(amount);
        
        emit WithdrawalMade(msg.sender, amount, depositIndex);
        emit BalanceUpdated(msg.sender, user.balance);
    }
    
    function withdrawAll() public onlyRegistered {
        Profile storage user = profiles[msg.sender];
        uint totalAmount = user.balance;
        
        require(totalAmount > 0, unicode"Нет средств для вывода");
        
        // Обнуляем баланс
        user.balance = 0;
        
        // Деактивируем все вклады
        for (uint i = 0; i < userDeposits[msg.sender].length; i++) {
            if (userDeposits[msg.sender][i].isActive) {
                userDeposits[msg.sender][i].isActive = false;
                userDeposits[msg.sender][i].amount = 0;
            }
        }
        
        // Перевод средств
        payable(msg.sender).transfer(totalAmount);
        
        emit WithdrawalMade(msg.sender, totalAmount, 999);
        emit BalanceUpdated(msg.sender, 0);
    }
    
    // ----------------Просматриваем вклады----------------------
    
    function getMyDeposits() public view onlyRegistered returns (Deposit[] memory) {
        return userDeposits[msg.sender];
    }
    
    function getDepositInfo(uint depositIndex) public view onlyRegistered returns (
        uint amount,
        uint depositDate,
        bool isActive
    ) {
        require(depositIndex < userDeposits[msg.sender].length, unicode"Неверный индекс депозита");
        Deposit memory deposit = userDeposits[msg.sender][depositIndex];
        return (
            deposit.amount,
            deposit.depositDate,
            deposit.isActive
        );
    }
    
    function getActiveDepositsCount() public view onlyRegistered returns (uint) {
        uint count = 0;
        for (uint i = 0; i < userDeposits[msg.sender].length; i++) {
            if (userDeposits[msg.sender][i].isActive) {
                count++;
            }
        }
        return count;
    }
    
    // -------Функции для просмотра, получение информации------
    
    function checkRegistration() public view returns (bool) {
        return profiles[msg.sender].exists;
    }
    
    function getUserBalance() public view onlyRegistered returns (uint) {
        return profiles[msg.sender].balance;
    }
    
    function getTotalSystemBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }
    
    function getRegisteredUsersCount() public view returns (uint) {
        return registeredAddresses.length;
    }
    
    function verifyCredentials(string memory _login, string memory _password) public view returns (bool) {
        return profiles[msg.sender].exists && 
               keccak256(abi.encodePacked(profiles[msg.sender].login)) == keccak256(abi.encodePacked(_login)) &&
               keccak256(abi.encodePacked(profiles[msg.sender].password)) == keccak256(abi.encodePacked(_password));
    }
    
    // Функция для получения контрактом средств
    receive() external payable {
        
    }
    
    // Функция для владельца для вывода средств из системы
    function withdrawSystemFunds(uint amount) public onlyOwner {
        require(amount <= address(this).balance, unicode"Недостаточный баланс по контракту");
        payable(owner).transfer(amount);
    }
}