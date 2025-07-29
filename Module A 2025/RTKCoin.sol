// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./types/ERC20Bundle.sol";

contract RTKCoin is ERC20, ERC20Permit, ERC20Votes{
    constructor() ERC20("RTKCoin", "RTK") ERC20Permit("RTKCoin") {
        _mint(address(this), 20_000_000 *(10 ** decimals())); //выпуск 20 000 000 токенов 
        //перевод между участниками
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