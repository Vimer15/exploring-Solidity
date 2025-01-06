// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract Test{
    uint public Date;

    function set(uint x) public 
    {
        Date = x;
    }
    function get() public  view  returns (uint) 
    {
            return Date;
    }
}