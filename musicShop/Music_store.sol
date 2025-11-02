// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MyToken_1.sol";
import "./MusicTrack.sol";

contract MusicStore {
    MyToken_1 public token;
    address public owner;
    
    // Массив всех треков в магазине
    MusicTrack[] public tracks;
    
    // События для отслеживания действий
    event TrackAdded(uint256 trackId, string name, address creator);
    event TrackPurchased(uint256 trackId, address buyer, uint256 price);
    event TrackAddedViaNew(address trackAddress, string name);

    constructor(address _tokenAddress) {
        token = MyToken_1(_tokenAddress);
        owner = msg.sender;
    }

    // Продажа треков 
    function sellTrack(
        string memory name,
        string memory description, 
        string memory author,
        uint256 price,
        uint256 duration
    ) external {
        _addNewTrack(name, description, author, price, duration);
    }

    // Добавление существующего трека в магазин
    function addExistingTrack(address trackAddress) external {
        MusicTrack track = MusicTrack(trackAddress);
        require(track.owner() == msg.sender, "You don't own this track");
        tracks.push(track);
        emit TrackAdded(tracks.length - 1, track.name(), msg.sender);
    }

    // Добавление нового трека
    function _addNewTrack(
        string memory name,
        string memory description,
        string memory author,
        uint256 price,
        uint256 duration
    ) internal {
        MusicTrack newTrack = new MusicTrack(
            name,
            description,
            author,
            price,
            duration
        );
        tracks.push(newTrack);
        emit TrackAddedViaNew(address(newTrack), name);
        emit TrackAdded(tracks.length - 1, name, msg.sender);
    }

    // Публичная версия для прямого добавления
    function addNewTrack(
        string memory name,
        string memory description,
        string memory author,
        uint256 price,
        uint256 duration
    ) external {
        _addNewTrack(name, description, author, price, duration);
    }

    // Покупка трека за токены
    function purchaseTrack(uint256 trackId) external {
        require(trackId < tracks.length, "Track does not exist");
        
        MusicTrack track = tracks[trackId];
        uint256 trackPrice = track.price();
        address trackOwner = track.owner();
        
        require(trackOwner != msg.sender, "You already own this track");
        require(token.balanceOf(msg.sender) >= trackPrice, "Insufficient token balance");

        // Переводим токены от покупателя к владельцу трека
        bool success = token.transferFrom(msg.sender, trackOwner, trackPrice);
        require(success, "Token transfer failed");

        // Передаем право собственности на трек
        track.transferOwnership(msg.sender);

        emit TrackPurchased(trackId, msg.sender, trackPrice);
    }

    // Просмотр всех треков в магазине
    function getAllTracks() external view returns (MusicTrack[] memory) {
        return tracks;
    }

    // Получение количества треков
    function getTracksCount() external view returns (uint256) {
        return tracks.length;
    }

    // Получение информации о конкретном треке
    function getTrackInfo(uint256 trackId) external view returns (
        string memory name,
        string memory description,
        string memory author,
        address trackOwner,
        uint256 price,
        uint256 duration
    ) {
        require(trackId < tracks.length, "Track does not exist");
        MusicTrack track = tracks[trackId];
        return track.getTrackInfo();
    }
}