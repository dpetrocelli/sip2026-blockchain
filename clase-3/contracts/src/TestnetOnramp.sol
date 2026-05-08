// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @notice USDC fake que vive en Sepolia. 6 decimales como el real.
contract MockUSDC is ERC20, Ownable {
    constructor() ERC20("Mock USDC", "mUSDC") Ownable(msg.sender) {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
}

/// @notice Simula un onramp tipo MoonPay: recibe ETH testnet, mintea USDC fake.
///         Tasa fija: 1 ETH testnet = 1000 mUSDC (irreal a propósito,
///         hace que con poca ETH del faucet se compre suficiente para demos).
contract TestnetOnramp is Ownable {
    MockUSDC public immutable usdc;
    uint256 public constant RATE = 1000;

    event Onramped(address indexed buyer, uint256 ethIn, uint256 usdcOut);

    constructor(MockUSDC _usdc) Ownable(msg.sender) {
        usdc = _usdc;
    }

    /// @notice Llamada por el front cuando el usuario "paga con tarjeta".
    ///         En realidad recibe ETH testnet y mintea USDC al sender.
    function buyWithCard() external payable {
        require(msg.value > 0, "no eth");
        uint256 usdcOut = (msg.value * RATE) / 1e12;
        usdc.mint(msg.sender, usdcOut);
        emit Onramped(msg.sender, msg.value, usdcOut);
    }

    /// @notice El owner retira el ETH acumulado (en testnet no importa, pero queda como pattern).
    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}
