# Clase 3 — Frontend dApp + TestnetOnramp

> **Material**: https://dpetrocelli.github.io/sip2026/blockchain-clase-3.html

Dos proyectos independientes:

```
clase-3/
├── contracts/   Foundry: TestnetOnramp.sol + MockUSDC
└── dapp/        Next.js + wagmi + RainbowKit
```

## contracts/ — Onramp simulado

`TestnetOnramp.sol` recibe ETH testnet y mintea `MockUSDC` (6 decimales como el real). Tasa fija: 1 ETH = 1000 mUSDC.

```bash
cd clase-3/contracts
forge install foundry-rs/forge-std OpenZeppelin/openzeppelin-contracts --no-commit --no-git
forge test
# 5 tests pasando
```

### Deploy

```bash
cp ../../clase-2/.env.example .env
source .env
forge script script/DeployOnramp.s.sol \
  --rpc-url $SEPOLIA_RPC_URL --account dev \
  --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY
```

Anotá las dos addresses (`MockUSDC` y `TestnetOnramp`) — las vas a meter en `.env.local` de la dApp.

> **Recomendación**: redeployá el `PaymentGateway` de clase 2 apuntando a `MockUSDC` (en lugar del USDC oficial de Circle). Así el ciclo "comprar con tarjeta → pagar" cierra sin pedir al usuario un faucet externo.

## dapp/ — Next.js 16 + wagmi + RainbowKit

```bash
cd clase-3/dapp
cp .env.local.example .env.local
# Completar:
#   NEXT_PUBLIC_WC_PROJECT_ID  (https://cloud.reown.com)
#   NEXT_PUBLIC_PAYGW_ADDRESS
#   NEXT_PUBLIC_USDC_ADDRESS   (MockUSDC del onramp)
#   NEXT_PUBLIC_ONRAMP_ADDRESS

npm install
npm run dev   # http://localhost:3000
```

### Componentes

- `app/components/CardOnramp.tsx` — Botón "comprar 50 mUSDC con tarjeta" → llama `buyWithCard()` del onramp con 0.05 ETH.
- `app/components/PayForm.tsx` — Flow `approve` + `pay` con feedback de tx.
- `app/components/PaymentFeed.tsx` — Eventos `Paid` en vivo via `useWatchContractEvent`.

### Validar el build

```bash
npm run build
# ✓ Compiled successfully
```

## Deploy a Vercel

```bash
git init && git add . && git commit -m "feat: paygw dapp"
gh repo create paygw-dapp --public --source=. --push
```

En Vercel: Import Git Repository → seleccionar repo → cargar las 4 env vars → Deploy.

URL pública sale en `https://paygw-dapp-xxx.vercel.app`.
