// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {PaymentGateway} from "./PaymentGateway.sol";
import {BadgeNFT} from "./BadgeNFT.sol";

/**
 * @title PaymentGatewayWithBadge
 * @notice Cierre del módulo: cada pago mintea una pieza Set Bonus al payer.
 *         El gateway debe ser owner del BadgeNFT para poder mintear.
 */
contract PaymentGatewayWithBadge is PaymentGateway {
    BadgeNFT public immutable badge;

    constructor(IERC20 _usdc, address _treasury, BadgeNFT _badge) PaymentGateway(_usdc, _treasury) {
        badge = _badge;
    }

    function _onPaid(address payer, uint256 amount, bytes32 action) internal override {
        bytes32 entropy = keccak256(abi.encode(payer, amount, block.prevrandao, action, block.number));
        badge.mintRandom(payer, entropy);
    }
}
