// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import "./types/ERC20Bundle.sol";

contract MyToken is ERC20, ERC20Permit, ERC20Votes {
    constructor() ERC20("Professional", "PROFI") ERC20Permit("MyToken") {
        _mint(address(this), 100000 *(10 ** decimals())); //выпуск 100 000 токенов 
        //перевод между участниками
        _transfer(address(this), 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4, 25000 * 10 ** decimals()); //tom
        _transfer(address(this), 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 25000 * 10 ** decimals()); //ben
        _transfer(address(this), 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 25000 * 10 ** decimals()); //rick
        _transfer(address(this), 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB, 25000 * 10 ** decimals());//jack

    }

    // The following functions are overrides required by Solidity.

    function decimals() public pure override returns(uint8) {
        return 12;
    }
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}