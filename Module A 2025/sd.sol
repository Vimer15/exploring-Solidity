// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {Governor} from "@openzeppelin/contracts/governance/Governor.sol";

contract MyGovernor is Governor {
    constructor() Governor("MyGovernor") {}

    function votingDelay() public pure override returns (uint256) {
        return 1 days;
    }

    function votingPeriod() public pure override returns (uint256) {
        return 1 weeks;
    }

    function quorum(uint256) public pure override returns (uint256) {
        // Простая реализация кворума - возвращаем фиксированное значение
        return 1000;
    }

    // Обязательная реализация функции подсчета голосов
    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight,
        bytes memory params
    ) internal override {
        // Базовая реализация подсчета голосов
        _proposalVotes[proposalId][support] += weight;
    }
}