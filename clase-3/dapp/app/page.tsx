'use client';
import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount } from 'wagmi';
import { PayForm } from './components/PayForm';
import { PaymentFeed } from './components/PaymentFeed';
import { CardOnramp } from './components/CardOnramp';

export default function Home() {
  const { address, isConnected } = useAccount();

  return (
    <main className="p-8 max-w-2xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">PayGW · Pasarela de pago</h1>
      <ConnectButton />
      {isConnected && (
        <>
          <p className="mt-4 text-sm text-gray-600">Conectado como {address}</p>
          <CardOnramp />
          <PayForm />
          <PaymentFeed />
        </>
      )}
    </main>
  );
}
