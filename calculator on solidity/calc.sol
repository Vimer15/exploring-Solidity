// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Calculater{
    int public num1;
    int public num2;
    int public resultAddition;
    int public resultSubtractions;
    int public resultMultiplication;
    int public resultDivision;

    function addition(int a, int b) public
    {
        num1 = a;
        num2 = b;
        resultAddition = num1 + num2;
        
    }
    function subtractions(int a, int b) public 
    {
        num1 = a;
        num2 = b;
        resultSubtractions = num1 - num2;
    }
    function multiplication(int a, int b) public 
    {
        num1 = a;
        num2 = b;
        resultMultiplication = num1 * num2;
    }
    function division(int a, int b) public 
    {
        num1 = a;
        num2 = b;
        if(num2 == 0)
        {
            resultDivision = 0;
        }
        else{
            resultDivision = num1 / num2;
        }
    }

}