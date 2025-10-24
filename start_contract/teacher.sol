// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HomeWork{
// 1) Объявите переменные: число,строка,булево значение, адрес, массив, структура(4 значения)
    // Объявление переменных
    uint public  number;
    string public  word = "Hello World";
    bool public isFlag;
    uint[] public numbers = [1, 2, 3];

    // Структура данных о пользователе
    struct user_Info{
        string Name_user;
        string Password_user;
        uint256 Age_user;
    }

    // mapping

    mapping (uint => user_Info) public User_info;
    // Заполняем данными нашу структуру
    function setUser(uint _IdUser, string memory _NameUser, string memory _Password, uint _AgeUser) public {
        User_info[_IdUser].Name_user = _NameUser;
        User_info[_IdUser].Password_user = _Password;
        User_info[_IdUser].Age_user = _AgeUser;
    }
    // Вводим _Id пользователя, и получаем информацию о нём
    function getUser(uint _Id) public view returns (user_Info memory){
        return User_info[_Id];
    }

    // Получаем информацию о том, что содержиться в нашей переменной
    function getLine() public view returns (string memory) {
        return word;
    }

    // Добавляем данные в массив (отображение массива по его id)
    function addNumber(uint _number) public{
        numbers.push(_number);
    }
    // Удаляем последний элемент из нашего массива
    function removeNumber() public{
        numbers.pop();
    }



    // Счетчик вызовов для демонстрации
    uint public callCount;
    
    // Событие для отслеживания добавления данных
    event DataAdded(uint[] newData, string loopType);
    // ---------------------------------For---------------------------------------

     function addWithForLoop(uint start, uint count, uint step) public returns (uint[] memory) {
        require(count > 0, unicode"Значение должно быть больше 0");
        require(step > 0, unicode"Шаг должен быть больше 0");
        
        // Создаем временный массив для новых данных
        uint[] memory newData = new uint[](count);
        
        // Добавляем 
        for (uint i = 0; i < count; i++) {
            uint newNumber = start + (i * step);
            numbers.push(newNumber);
            newData[i] = newNumber;
        }
        
        callCount++;
        emit DataAdded(newData, "FOR_LOOP");
        
        return numbers;
    }
    // ---------------------------------While---------------------------------------
     function addWithWhileLoop(uint start, uint count, uint step) public returns (uint[] memory) {
        require(count > 0, unicode"Значение должно быть больше 0");
        require(step > 0, unicode"Шаг должен быть больше 0");
        
        uint[] memory newData = new uint[](count);
        uint i = 0;
        
        // Добавляем данные
        while (i < count) {
            uint newNumber = start + (i * step);
            numbers.push(newNumber);
            newData[i] = newNumber;
            i++;
        }
        
        callCount++;
        emit DataAdded(newData, "WHILE_LOOP");
        
        return numbers;
    }
    // ---------------------------------do-while---------------------------------------
    function addWithDoWhileLoop(uint start, uint count, uint step) public returns (uint[] memory) {
        require(count > 0, "Count must be greater than 0");
        require(step > 0, "Step must be greater than 0");
        
        uint[] memory newData = new uint[](count);
        uint i = 0;
        
        // Добавляем данные
        do {
            uint newNumber = start + (i * step);
            numbers.push(newNumber);
            newData[i] = newNumber;
            i++;
        } while (i < count);
        
        callCount++;
        emit DataAdded(newData, "DO_WHILE_LOOP");
        
        return numbers;
    }

     // Получить весь массив
    function getAllNumbers() public view returns (uint[] memory) {
        return numbers;
    }


    // ---------------------------------------------------------------------------

    // Особенности Reference Types

    // uint[] storage array1;
    // uint[] storage array2 = array1; // Ссылка на те же данные (копируем значение)


    // Значение по умолчанию для address
    address public defaultAddress; // = 0x0000000000000000000000000000000000000000

}

// -----------------------------------Value Types-------------------------------------

// Value Types (Типы-значения)

// Тип	               Описание	                    Размер
// bool	            Логический тип	                1 байт
// int8..int256	    Знаковые целые	                8-256 бит
// uint8..uint256	Беззнаковые целые	            8-256 бит
// address	        Адрес Ethereum	                20 байт
// address payable  Адрес для отправки ETH	        20 байт
// bytes1..bytes32	Фиксированные байтовые массивы	1-32 байта
// enum	                Перечисление	            До 256 бит
// fixed / ufixed	Числа с фиксированной точкой	Различный

// ---------------------------------Reference Types-----------------------------------------

// Reference Types (Типы-ссылки)

// Тип	                    Описание	            Расположение
// array	                Массивы	               memory / storage
// struct	                Структуры	           memory / storage
// mapping	                Отображения	                storage
// string	                Строки	               memory / storage
// bytes	           Динамические байтовые массивы	memory / storage

// ------------------------------------Модификаторы доступа--------------------------------------

// public - Доступно везде, и может вызвать любой участник контракта
// private - Работает только внутри контракта
// external - Используется извне
// internal - Используется внутри контракта
    

