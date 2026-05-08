# Clase 4 — BadgeNFT (Set Bonus) + integración con PaymentGateway + Slither

> **Material**: https://dpetrocelli.github.io/sip2026/blockchain-clase-4.html

## Contratos

- `src/BadgeNFT.sol` — ERC-721 con piezas tipo "figuritas" (slot 0..11 + rareza Common/Rare/Epic/Legendary). Pseudo-randomness con `keccak256` sobre entropy (apto testnet, **no producción**).
- `src/PaymentGateway.sol` — Re-export del contrato base de clase 2 (mismo código).
- `src/PaymentGatewayWithBadge.sol` — Extiende `PaymentGateway` y mintea una pieza random al payer en cada `pay()`.

## Setup

```bash
cd clase-4
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts --no-commit --no-git
forge build
forge test
```

Esperás 9 tests pasando (BadgeNFT + integration con gateway).

## Deploy

```bash
cp .env.example .env
# Completar USDC_SEPOLIA, TREASURY, BADGE_NAME, BADGE_SYMBOL.
source .env

forge script script/DeployBadgeAndGateway.s.sol \
  --rpc-url $SEPOLIA_RPC_URL --account dev \
  --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

El script:
1. Deploya `BadgeNFT` (owner = deployer).
2. Deploya `PaymentGatewayWithBadge` apuntando a USDC + treasury + badge.
3. Transfiere ownership del badge al gateway (para que pueda mintear).

## Análisis estático con Slither

```bash
pip install slither-analyzer solc-select
solc-select install 0.8.24 && solc-select use 0.8.24
slither . --foundry-out-directory out
```

Documentar findings aceptados en `SECURITY.md` (template en el material de la clase). Objetivo: 0 HIGH, MEDIUM justificados.

## Tokenomics — esqueletos por proyecto

El `_onPaid` de `PaymentGatewayWithBadge` es la integración mínima (mintea pieza). Cada equipo lo extiende según su proyecto. Ver tabla de mapeo en [el material](https://dpetrocelli.github.io/sip2026/blockchain-clase-4.html#parte-5--cómo-plugar-el-stack-a-tu-proyecto):

- **VibeCheck**: ticket NFT + cashback `$VBK` + pieza.
- **DepFund**: shares `$DPF` proporcionales + pieza.
- **RNW**: tokens `$RNW` + perfil de riesgo + pieza.
- **IDEAFY**: sub-token del proyecto (`$IDEA-CERV`, etc.) + pieza.

## ⚠️ Riesgos conocidos (acepted-risk en testnet)

- **Pseudo-randomness**: usar Chainlink VRF en producción.
- **Burn 1%/tx en ProjectToken** (si lo activás): genera slippage en DEXs — whitelist necesaria para listings públicos.
