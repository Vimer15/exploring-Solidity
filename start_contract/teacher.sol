// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//Маппинг

contract Mapping_Teacher{
    mapping(address => uint256) public teacherBalance;

    function AddBalance(address _address, uint256 _balance) public  {
        teacherBalance[_address] =  _balance;
    }

    function getBalance(address _addressUser) public view returns (uint256){
        return teacherBalance[_addressUser];
    }

    function deposit() public payable {
        teacherBalance[msg.sender] = msg.value;
    }
}


// Структура

contract Struct_Teacher{
    struct userInfo{
        string Name_user;
        string Password_user;
        uint256 Age_user;
    }

    userInfo public me;

    function the_first_method() public {
        me = userInfo("Ruslan", "qwerty123", 20);
    }
    function the_second_method(string memory _name, string memory _password, uint256 _age) public {
        me = userInfo(_name, _password, _age);
    }
    function the_free_method() public {
        me.Name_user = "Ruslan";
    }

}

// Операции с числами

contract Number_teacher{
    int public summer = 0;
    int public number_1 = -223;
    int public number_2 = 123;


    function subtraction_number() public returns (int){
        summer = number_1 - number_2;
        return summer;
    }
    function result_test() public returns(int){
        if(number_1 < 0)
        {
            number_1 *= -1;
            return number_1;
        }
        else{
            return number_1;
        }

    }
}


// Счетчик голосов

contract counter
{

    mapping (address => uint256) public counter_balance;
    int public count = 0;
    
    function addition() public  {
        counter_balance[msg.sender] += 1;
    }
    function subtraction() public  {
        counter_balance[msg.sender] -= 1;
    }
    function getBalance(address _addressUser) public view returns (uint256){
        return counter_balance[_addressUser];
    }
}