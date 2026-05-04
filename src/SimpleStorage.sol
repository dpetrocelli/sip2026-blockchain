// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title SimpleStorage
/// @notice Contrato mínimo para clase 1: guarda un número y emite un evento al cambiarlo.
/// @dev Es el "hello world" de Solidity. En clase 2 lo reemplazamos por PaymentGateway.
contract SimpleStorage {
    uint256 private _value;

    event ValueChanged(address indexed by, uint256 newValue);

    function set(uint256 value) external {
        _value = value;
        emit ValueChanged(msg.sender, value);
    }

    function get() external view returns (uint256) {
        return _value;
    }
}
