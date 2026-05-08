# SIP 2026 — Blockchain Clase 1: SimpleStorage

Repo base de la **clase 1** del módulo Blockchain del Seminario de Integración Profesional 2026 (UNLu DCB).

> **Material de la clase**: [blockchain-clase-1.html](https://dpetrocelli.github.io/sip2026/blockchain-clase-1.html)

## ¿Qué hay acá?

Un proyecto Foundry mínimo con un contrato `SimpleStorage` listo para compilar, testear, deployar y verificar.

```
.
├── src/SimpleStorage.sol            # contrato (1 storage var, 1 evento, set/get)
├── test/SimpleStorage.t.sol         # 4 tests (default, set, evento, fuzz)
├── script/DeploySimpleStorage.s.sol # script de deploy con forge script
├── foundry.toml                     # config Foundry + Etherscan
├── remappings.txt                   # forge-std → lib/forge-std/src
└── .env.example                     # plantilla de variables de entorno
```

## Setup

```bash
git clone https://github.com/dpetrocelli/sip2026-blockchain.git
cd sip2026-blockchain/clase-1
forge install foundry-rs/forge-std --no-commit --no-git
forge build
forge test -vv
```

Esperás `4 tests passed`.

## Variables de entorno

Copiá la plantilla:

```bash
cp .env.example .env
```

Editá `.env` y poné tu `ETHERSCAN_API_KEY` (gratis en https://etherscan.io/myapikey).

```bash
source .env
```

## Importar tu wallet a Foundry

⚠️ Usá una wallet de **testnet** sin fondos reales.

```bash
cast wallet import dev --interactive
```

Pegá la private key de MetaMask cuando te lo pida (no se ve en pantalla). Elegí una password local.

## Deploy a Sepolia

```bash
forge create src/SimpleStorage.sol:SimpleStorage \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev \
  --broadcast
```

Te devuelve la address. Guardala:

```bash
export ADDR=0x...
```

## Interactuar con `cast`

```bash
# Leer (gratis, instantáneo)
cast call $ADDR "get()(uint256)" --rpc-url $SEPOLIA_RPC_URL

# Escribir (firma + gas)
cast send $ADDR "set(uint256)" 42 \
  --rpc-url $SEPOLIA_RPC_URL \
  --account dev

# Releer
cast call $ADDR "get()(uint256)" --rpc-url $SEPOLIA_RPC_URL
```

## Verificar en Etherscan

```bash
forge verify-contract $ADDR \
  src/SimpleStorage.sol:SimpleStorage \
  --chain sepolia \
  --etherscan-api-key $ETHERSCAN_API_KEY \
  --watch
```

Una vez verificado, abrí:

```
https://sepolia.etherscan.io/address/$ADDR#code
```

Vas a ver el código fuente, las tabs **Read Contract** y **Write Contract** para interactuar con MetaMask, y los eventos emitidos.

## Si algo falla

Tabla completa en la página de la clase: https://dpetrocelli.github.io/sip2026/blockchain-clase-1.html#si-algo-falla

## ¿Qué viene después?

[Clase 2](https://dpetrocelli.github.io/sip2026/blockchain-clase-2.html) — reemplazamos `SimpleStorage` por un `PaymentGateway` que cobra USDC y emite eventos para el backend.
