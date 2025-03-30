// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleDAO {
    // Хранит балансы участников
    mapping(address => uint) public balances; // 3 участника
    
    // Хранит голоса: proposalId => voter => voted
    mapping(uint => mapping(address => bool)) public votes;
    
    // Счетчик предложений
    uint public nextProposalId;
    
    // Структура предложения
    struct Proposal {
        address recipient;
        uint amount;
        string description;
        uint voteCount;
        bool executed;
    }
    
    // Все предложения
    mapping(uint => Proposal) public proposals;
    
    // Условия: минимальные 60% голосов "за" для исполнения
    uint public constant MIN_VOTES_PERCENT = 60;
    
    // Внести депозит и получить права голоса
    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }
    
    // Создать предложение о переводе средств
    function createProposal(address _recipient, uint _amount, string memory _description) external {
        require(balances[msg.sender] > 0, "Not a member");
        proposals[nextProposalId] = Proposal({
            recipient: _recipient,
            amount: _amount,
            description: _description,
            voteCount: 0,
            executed: false
        });
        nextProposalId++;
    }
    
    // Проголосовать за предложение
    function vote(uint proposalId) external {
        require(balances[msg.sender] > 0, "Not a member");
        require(!votes[proposalId][msg.sender], "Already voted");
        
        votes[proposalId][msg.sender] = true;
        proposals[proposalId].voteCount += balances[msg.sender];
    }
    
    // Исполнить предложение (если набрало достаточно голосов)
    function executeProposal(uint proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        
        uint totalVotes = 0;
        // В реальном DAO это было бы неэффективно, здесь для простоты
        for(uint i = 0; i < nextProposalId; i++) {
            totalVotes += proposals[i].voteCount;
        }
        
        uint votePercentage = (proposal.voteCount * 100) / totalVotes;
        require(votePercentage >= MIN_VOTES_PERCENT, "Not enough votes");
        
        (bool success, ) = proposal.recipient.call{value: proposal.amount}("");
        require(success, "Transfer failed");
        
        proposal.executed = true;
    }
    
    // Проверить баланс контракта
    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
}