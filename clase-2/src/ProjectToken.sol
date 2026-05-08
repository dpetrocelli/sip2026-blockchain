// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title ProjectToken
/// @notice ERC-20 del equipo. Personalizar nombre/símbolo según proyecto.
contract ProjectToken is ERC20, Ownable {
    constructor(string memory name_, string memory symbol_, address owner_)
        ERC20(name_, symbol_)
        Ownable(owner_)
    {}

    /// @notice Emitir tokens. Solo el owner.
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}
