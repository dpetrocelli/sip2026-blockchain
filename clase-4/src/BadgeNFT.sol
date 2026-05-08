// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title BadgeNFT (Set Bonus)
 * @notice ERC-721 con piezas tipo "figuritas" que combinan en sets.
 *         Cada pieza tiene un slot (0..SLOTS-1) y una rareza.
 *         La randomness es pseudo (keccak256 sobre block.prevrandao + sender).
 *         Aceptable en testnet — para producción usar Chainlink VRF.
 */
contract BadgeNFT is ERC721, Ownable {
    enum Rarity {
        Common,
        Rare,
        Epic,
        Legendary
    }

    struct Piece {
        uint8 slot;
        Rarity rarity;
    }

    uint8 public constant SLOTS = 12;

    mapping(uint256 => Piece) public pieces;
    uint256 private _nextId;

    event PieceMinted(address indexed to, uint256 indexed tokenId, uint8 slot, Rarity rarity);

    constructor(string memory name_, string memory symbol_, address owner_) ERC721(name_, symbol_) Ownable(owner_) {}

    /// @notice Llamado por el PaymentGateway (o quien sea owner) cuando alguien paga.
    function mintRandom(address to, bytes32 entropy) external onlyOwner returns (uint256) {
        uint256 id = ++_nextId;
        uint8 slot = uint8(uint256(entropy) % SLOTS);
        Rarity rarity = _rollRarity(entropy);

        pieces[id] = Piece(slot, rarity);
        _mint(to, id);
        emit PieceMinted(to, id, slot, rarity);
        return id;
    }

    function _rollRarity(bytes32 entropy) private pure returns (Rarity) {
        uint256 r = uint256(keccak256(abi.encode(entropy, "rarity"))) % 100;
        if (r < 60) return Rarity.Common;
        if (r < 85) return Rarity.Rare;
        if (r < 97) return Rarity.Epic;
        return Rarity.Legendary;
    }

    /// @notice Cuántos slots únicos posee `holder` entre los `ids` provistos.
    /// @dev El llamador pasa los token IDs que cree del holder; revierte si alguno no es del holder.
    function uniqueSlotsOf(address holder, uint256[] calldata ids) external view returns (uint8) {
        uint16 mask;
        for (uint256 i = 0; i < ids.length; i++) {
            require(ownerOf(ids[i]) == holder, "not owner");
            mask |= uint16(1) << pieces[ids[i]].slot;
        }
        uint8 count;
        while (mask != 0) {
            count += uint8(mask & 1);
            mask >>= 1;
        }
        return count;
    }
}
