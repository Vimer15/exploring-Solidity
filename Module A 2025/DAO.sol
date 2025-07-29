// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";
import {GovernorCountingSimple} from "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import {GovernorVotes} from "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import {GovernorVotesQuorumFraction} from "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

contract MyGovernor is Governor, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {

    struct User {
        string username; //имя пользователя
        bool statusDAOMember; //статус участника голосования
    }

    enum StatusPropose { //статус предложения 
        propose, // предложено
        accept, // принято
        notAccept, //не принято
        deleted //удален
    }

    enum TypePropose {
        A,
        B,//
        C,
        D
    }

    struct Propose { //структура предложения
    uint id;// id
    StatusPropose status;// статус после завершения
    TypePropose category; //категория 
    address owner; //кто предложил
    }

    Propose[] public HistoryProposes; //история предложений

    mapping(address => User) public user; //структура пользователя

    
    constructor(IVotes _token)
        Governor("MyGovernor")
        GovernorVotes(_token)
        GovernorVotesQuorumFraction(4)
    {
        //назначение пользователей
        user[0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] = User("Tom", true);
        user[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2] = User("Ben", true);
        user[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db] = User("Rick", true);
        user[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB] = User("Jack", false);


    }

    function addPropose(TypePropose _type) public { //добавить предложения
        HistoryProposes.push(Propose(HistoryProposes.length, StatusPropose.propose, _type,msg.sender));
    }

    function getAllProposes() public view returns(Propose[] memory) { //получить все предложения
        return HistoryProposes;
    }

    function deletePropose(uint id) public { //удаление предложения
        require(address(msg.sender) == HistoryProposes[id].owner,"You cannot delete this propose");//проверка владелец ли отправмитель
        HistoryProposes[id].status = StatusPropose.deleted; //делаем статус удаленный
    }

    function votingDelay() public pure override returns (uint256) {
        return 1 days;
    }

    function votingPeriod() public pure override returns (uint256) {
        return 1 weeks;
    }

    // The following functions are overrides required by Solidity.

    function quorum(uint256 blockNumber)
        public
        view
        override(Governor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }
}