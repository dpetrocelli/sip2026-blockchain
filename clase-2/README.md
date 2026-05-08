# Clase 2 — PaymentGateway + ProjectToken

> **Material**: https://dpetrocelli.github.io/sip2026/blockchain-clase-2.html

## Contratos

- `src/PaymentGateway.sol` — Recibe USDC vía `pay(amount, action)`, emite evento `Paid`, protegido contra reentrancy con `nonReentrant`. Hook `_onPaid` para que las subclases extiendan en clase 4.
- `src/ProjectToken.sol` — ERC-20 simple Ownable (mint solo por owner). Personalizable por equipo (`$VBK`, `$DPF`, `$RNW`, `$IDEA`).

## Setup

```bash
cd clase-2
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts --no-commit --no-git
forge build
forge test
```

Esperás 5 tests pasando (incluye fuzz).

## Variables de entorno

```bash
cp .env.example .env
# Completar:
#  SEPOLIA_RPC_URL
#  ETHERSCAN_API_KEY
#  USDC_SEPOLIA = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238
#  TREASURY     = tu address de MetaMask
source .env
```

## Deploy

### PaymentGateway

```bash
forge script script/DeployPaymentGateway.s.sol \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev \
  --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

### ProjectToken (cada equipo cambia los strings)

```bash
forge create src/ProjectToken.sol:ProjectToken \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev \
  --constructor-args "VibeCheck Token" "VBK" $TREASURY \
  --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

## Probar el flow completo (cast)

```bash
export GATEWAY=0x...
# 50 USDC con 6 decimales
cast send $USDC_SEPOLIA "approve(address,uint256)" $GATEWAY 50000000 \
  --rpc-url $SEPOLIA_RPC_URL --account dev

cast send $GATEWAY "pay(uint256,bytes32)" 50000000 \
  0x$(echo -n "primera-prueba" | xxd -p) \
  --rpc-url $SEPOLIA_RPC_URL --account dev

cast call $USDC_SEPOLIA "balanceOf(address)(uint256)" $TREASURY \
  --rpc-url $SEPOLIA_RPC_URL
# 50000000  → 50 USDC
```

Verificá los eventos `Paid` en Etherscan: `https://sepolia.etherscan.io/address/$GATEWAY` → tab Events.
