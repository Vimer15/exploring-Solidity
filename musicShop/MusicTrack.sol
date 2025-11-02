// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MusicTrack {
    string public name;
    string public description;
    string public author;
    address public owner;
    uint256 public price;
    //время
    uint256 public duration; 

    constructor(
        string memory _name,
        string memory _description,
        string memory _author,
        uint256 _price,
        uint256 _duration
    ) {
        name = _name;
        description = _description;
        author = _author;
        owner = msg.sender;
        price = _price;
        duration = _duration;
    }

    // Получение всей информации о треке
    function getTrackInfo() external view returns (
        string memory,
        string memory,
        string memory,
        address,
        uint256,
        uint256
    ) {
        return (name, description, author, owner, price, duration);
    }

    // Смена владельца
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Only owner can transfer");
        owner = newOwner;
    }

    // Изменение цены
    function setPrice(uint256 newPrice) external {
        require(msg.sender == owner, "Only owner can set price");
        price = newPrice;
    }
}