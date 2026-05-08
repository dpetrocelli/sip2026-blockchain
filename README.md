# SIP 2026 — Módulo Blockchain (UNLu DCB)

Repo público con el **código de las 4 clases** del módulo Blockchain del Seminario de Integración Profesional 2026.

> **Material teórico**: https://dpetrocelli.github.io/sip2026/

## Estructura

```
.
├── clase-1/   SimpleStorage en Foundry (storage + evento + set/get + fuzz test)
├── clase-2/   PaymentGateway (USDC + reentrancy guard) + ProjectToken (ERC-20)
├── clase-3/
│   ├── contracts/   TestnetOnramp.sol + MockUSDC (ETH → USDC simulado)
│   └── dapp/        Next.js + wagmi + RainbowKit (approve + pay + feed eventos)
└── clase-4/   BadgeNFT (ERC-721 Set Bonus) + PaymentGatewayWithBadge (cierra `_onPaid`)
```

Cada carpeta es **autónoma**: tiene su propio `foundry.toml` (o `package.json`), sus deps, sus tests. Cloná el repo y entrá a la carpeta de la clase que estés cursando.

## Prerequisitos

| Tool | Versión mínima | Para qué |
|---|---|---|
| Git | cualquiera | clonar |
| Foundry (`forge`/`cast`/`anvil`) | 1.5+ | clases 1, 2, 3 (contracts), 4 |
| Node.js + npm | 20+ / 9+ | clase 3 (dapp) |
| Slither | 0.10+ | clase 4 (auditoría) |
| Python 3.8+ | — | requisito de Slither |

Setup detallado: ver [prerequisitos en clase-1.html](https://dpetrocelli.github.io/sip2026/blockchain-clase-1.html#warning-prerequisitos--traélo-hecho-antes-del-sábado).

## Quickstart por clase

### Clase 1 — SimpleStorage

```bash
cd clase-1
forge install foundry-rs/forge-std --no-commit --no-git
forge build && forge test
# 4 tests pasando
```

[clase-1/README.md](clase-1/README.md) · [material](https://dpetrocelli.github.io/sip2026/blockchain-clase-1.html)

### Clase 2 — PaymentGateway + ProjectToken

```bash
cd clase-2
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts --no-commit --no-git
forge build && forge test
# 5 tests pasando
```

[clase-2/README.md](clase-2/README.md) · [material](https://dpetrocelli.github.io/sip2026/blockchain-clase-2.html)

### Clase 3 — Frontend dApp + TestnetOnramp

Dos proyectos:

```bash
# Contrato del onramp
cd clase-3/contracts
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts --no-commit --no-git
forge test
# 5 tests pasando

# dApp
cd ../dapp
cp .env.local.example .env.local   # poner las addresses
npm install
npm run dev                          # http://localhost:3000
```

[clase-3/README.md](clase-3/README.md) · [material](https://dpetrocelli.github.io/sip2026/blockchain-clase-3.html)

### Clase 4 — BadgeNFT + Set Bonus + Slither

```bash
cd clase-4
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts --no-commit --no-git
forge build && forge test
# 9 tests pasando

# Auditoría estática (requiere slither instalado)
slither . --foundry-out-directory out
```

[clase-4/README.md](clase-4/README.md) · [material](https://dpetrocelli.github.io/sip2026/blockchain-clase-4.html)

## Deploy a Sepolia

Instrucciones por clase en cada README. En todas necesitás:

```bash
cp .env.example .env
# Completar SEPOLIA_RPC_URL, ETHERSCAN_API_KEY, etc.
source .env
cast wallet import dev --interactive  # solo la primera vez
```

## Si algo falla

Foro de la materia. **Antes del viernes 23:59** si la clase es el sábado.

## License

MIT (ver `LICENSE` cuando se agregue).
