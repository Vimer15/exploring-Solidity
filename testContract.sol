// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Test{
     function receiveFunds() public  payable 
   {
        //Здесь ничего не записываем, дениги будут зачисленны на счет контракта
   }

    // Событие для отслеживания отправки средств
    event Sent(address from, address to, uint amount);


    // Функция для отправки средств с баланса контракта
    function sendFunds(address payable receiver, uint amount) public {
        require(amount <= address(this).balance, "Insufficient balance in contract");
        receiver.transfer(amount);
        emit Sent(address(this), receiver, amount);
    }

    // Функция для получения баланса контракта
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}