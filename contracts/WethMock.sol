// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WethMock is ERC20 {
    constructor(address additionalAddress) ERC20("Wrapped Ether", "WETH") {
        _mint(msg.sender, 10000000000000000000);
        _mint(additionalAddress, 10000000000000000000);
    }
}
