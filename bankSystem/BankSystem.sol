// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Это мой первый банковский контракт, надеюсь все правильно
contract BankingSystem {
    
    // Структура для профиля пользователя
    struct Profile {
        string name;     
        uint id;              
        string login;         
        string password;       
        uint balance;         
        bool exists;           
        uint registrationDate; 
    }
    
    // Структура для вклада
    struct Deposit {
        address userAddress;  
        uint amount;           
        uint depositDate;      
        bool isActive;        
    }
    
    // Хранилища данных
    mapping(address => Profile) public profiles;           // Профили по адресу
    mapping(address => Deposit[]) public userDeposits;     // Вклады пользователей
    mapping(string => bool) public loginExists;            // Существующие логины
    
    // Списки и счетчики
    address[] public registeredAddresses;  // Все зарегистрированные адреса
    uint private nextUserId = 1;           // Следующий ID пользователя
    address public owner;                  // Владелец контракта
    
    event UserRegistered(address indexed userAddress, uint userId, string name);
    event DepositMade(address indexed userAddress, uint amount, uint depositId);
    event WithdrawalMade(address indexed userAddress, uint amount, uint depositId);
    event BalanceUpdated(address indexed userAddress, uint newBalance);
    
    // Модификаторы
    modifier onlyOwner() {
        require(msg.sender == owner, unicode"Только владелец может вызвать эту функцию");
        _;
    }
    
    modifier onlyRegistered() {
        require(profiles[msg.sender].exists, unicode"Пользователь не найден");
        _;
    }
    
    modifier validAmount(uint amount) {
        require(amount > 0, unicode"Сумма должна быть больше нуля");
        _;
    }
    
    // Конструктор - для иницилизации вдадельца контракта
    constructor() {
        owner = msg.sender;
    }
    
    // ------------регистрация---------------
    
    function registerUser(
        string memory _name,
        string memory _login,
        string memory _password
    ) public returns (uint) {
        // Проверяем что пользователь еще не зарегистрирован
        require(!profiles[msg.sender].exists, unicode"Пользователь уже зарегистрирован");
        
        // Проверяем что логин свободен
        require(!loginExists[_login], unicode"Пользователь уже зарегистрирован");
        
        // Проверяем что имя не пустое
        require(bytes(_name).length > 0, unicode"не корректное имя");
        
        // Проверяем что логин не пустой
        require(bytes(_login).length > 0, unicode"Не корректный логин");
        
        // Проверяем длину пароля
        require(bytes(_password).length >= 4, unicode"Не корректный пароль");
        
        // Создаем новый профиль
        profiles[msg.sender] = Profile({
            name: _name,
            id: nextUserId,
            login: _login,
            password: _password,
            balance: 0,
            exists: true,
            registrationDate: block.timestamp
        });
        
        // Отмечаем что логин занят
        loginExists[_login] = true;
        
        // Добавляем адрес в список зарегистрированных
        registeredAddresses.push(msg.sender);
        
        // Запоминаем ID для возврата и увеличиваем счетчик
        uint currentUserId = nextUserId;
        nextUserId++;
        
        // Вызываем событие
        emit UserRegistered(msg.sender, currentUserId, _name);
        
        return currentUserId;
    }
    
    // -------Просмотр профиля-----------
    
    function getMyProfile() public view onlyRegistered returns (
        string memory name,
        uint id,
        string memory login,
        uint balance,
        uint registrationDate,
        uint depositCount
    ) {
        // Получаем профиль текущего пользователя
        Profile memory user = profiles[msg.sender];
        
        // Возвращаем данные
        return (
            user.name,
            user.id,
            user.login,
            user.balance,
            user.registrationDate,
            userDeposits[msg.sender].length
        );
    }
    
    // Просмотр профилей
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
    
    // ---------Работа с вкладами------------
    
    // Функция для создания вклада
    function makeDeposit() public payable onlyRegistered validAmount(msg.value) returns (uint) {
        Profile storage user = profiles[msg.sender];
        
        // Создаем новый вклад
        uint newDepositId = userDeposits[msg.sender].length;
        userDeposits[msg.sender].push(Deposit({
            userAddress: msg.sender,
            amount: msg.value,
            depositDate: block.timestamp,
            isActive: true
        }));
        
        // Увеличиваем баланс пользователя
        user.balance += msg.value;
        
        // Вызываем события
        emit DepositMade(msg.sender, msg.value, newDepositId);
        emit BalanceUpdated(msg.sender, user.balance);
        
        return newDepositId;
    }
    
    // Функция для снятия с конкретного вклада
    function withdrawFromDeposit(uint depositIndex, uint amount) public onlyRegistered validAmount(amount) {
        // Проверяем что индекс правильный
        require(depositIndex < userDeposits[msg.sender].length, unicode"Не верно указан номер депозита");
        
        Profile storage user = profiles[msg.sender];
        Deposit storage deposit = userDeposits[msg.sender][depositIndex];
        
        // Проверяем что вклад активен
        require(deposit.isActive, unicode"Депозит не активен");
        
        // Проверяем что на вкладе достаточно средств
        require(deposit.amount >= amount, unicode"Недостаточно средств на депозите");
        
        // Проверяем что общий баланс достаточный
        require(user.balance >= amount, unicode"Недостаточный общий баланс");
        
        // Уменьшаем сумму вклада
        deposit.amount -= amount;
        
        // Уменьшаем общий баланс
        user.balance -= amount;
        
        // Если вклад опустел, делаем его неактивным
        if (deposit.amount == 0) {
            deposit.isActive = false;
        }
        
        // Переводим средства пользователю
        payable(msg.sender).transfer(amount);
        
        // Вызываем события
        emit WithdrawalMade(msg.sender, amount, depositIndex);
        emit BalanceUpdated(msg.sender, user.balance);
    }
    
    // Функция для снятия всех средств
    function withdrawAll() public onlyRegistered {
        Profile storage user = profiles[msg.sender];
        uint totalToWithdraw = user.balance;
        
        // Проверяем что есть что снимать c депозитов
        require(totalToWithdraw > 0, unicode"Нет средств");
        
        // Обнуляем баланс
        user.balance = 0;
        
        // Делаем все вклады неактивными
        for (uint i = 0; i < userDeposits[msg.sender].length; i++) {
            if (userDeposits[msg.sender][i].isActive) {
                userDeposits[msg.sender][i].isActive = false;
                userDeposits[msg.sender][i].amount = 0;
            }
        }
        
        // Переводим все средства
        payable(msg.sender).transfer(totalToWithdraw);
        
        // Вызываем события
        emit WithdrawalMade(msg.sender, totalToWithdraw, 999); // 999 значит "все вклады"
        emit BalanceUpdated(msg.sender, 0);
    }
    
    // ------Просмотр вкладов--------
    
    // Получить все мои вклады
    function getMyDeposits() public view onlyRegistered returns (Deposit[] memory) {
        return userDeposits[msg.sender];
    }
    
    // Получить информацию о конкретном вкладе
    function getDepositInfo(uint depositIndex) public view onlyRegistered returns (
        uint amount,
        uint depositDate,
        bool isActive
    ) {
        require(depositIndex < userDeposits[msg.sender].length, unicode"не верно указан номер депозита");
        Deposit memory deposit = userDeposits[msg.sender][depositIndex];
        return (
            deposit.amount,
            deposit.depositDate,
            deposit.isActive
        );
    }
    
    // Посчитать активные вклады
    function getActiveDepositsCount() public view onlyRegistered returns (uint) {
        uint activeCount = 0;
        for (uint i = 0; i < userDeposits[msg.sender].length; i++) {
            if (userDeposits[msg.sender][i].isActive) {
                activeCount++;
            }
        }
        return activeCount;
    }
    
    // Проверить зарегистрирован ли я
    function checkRegistration() public view returns (bool) {
        return profiles[msg.sender].exists;
    }
    
    // Получить мой баланс
    function getUserBalance() public view onlyRegistered returns (uint) {
        return profiles[msg.sender].balance;
    }
    
    // Получить общий баланс системы (владелец)
    function getTotalSystemBalance() public view onlyOwner returns (uint) {
        return address(this).balance;
    }
    
    // Получить количество зарегистрированных пользователей
    function getRegisteredUsersCount() public view returns (uint) {
        return registeredAddresses.length;
    }
    
    // Проверить логин и пароль
    function verifyCredentials(string memory _login, string memory _password) public view returns (bool) {
        if (!profiles[msg.sender].exists) {
            return false;
        }
        
        // Сравниваем логин
        bool loginMatch = keccak256(abi.encodePacked(profiles[msg.sender].login)) == 
                         keccak256(abi.encodePacked(_login));
        
        // Сравниваем пароль
        bool passwordMatch = keccak256(abi.encodePacked(profiles[msg.sender].password)) == 
                           keccak256(abi.encodePacked(_password));
        
        return loginMatch && passwordMatch;
    }
    
    // Функция для получения ether контрактом
    receive() external payable {
        // Просто принимаем ether
    }
    
    // Функция для владельца чтобы выводить средства из контракта
    function withdrawSystemFunds(uint amount) public onlyOwner {
        require(amount <= address(this).balance, "Not enough contract balance");
        payable(owner).transfer(amount);
    }
}