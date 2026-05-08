'use client';
import { useState, useEffect } from 'react';
import { useWriteContract, useWaitForTransactionReceipt } from 'wagmi';
import { parseEther } from 'viem';
import { ONRAMP_ABI } from '@/lib/abis';

const ONRAMP = process.env.NEXT_PUBLIC_ONRAMP_ADDRESS as `0x${string}` | undefined;

export function CardOnramp() {
  const [step, setStep] = useState<'idle' | 'card' | 'tx' | 'done'>('idle');
  const { writeContract, data: hash, isPending } = useWriteContract();
  const { isLoading, isSuccess } = useWaitForTransactionReceipt({ hash });

  useEffect(() => {
    if (isSuccess && step !== 'done') setStep('done');
  }, [isSuccess, step]);

  async function buy50USDC() {
    if (!ONRAMP) return;
    setStep('card');
    await new Promise((r) => setTimeout(r, 1500));
    setStep('tx');
    writeContract({
      address: ONRAMP,
      abi: ONRAMP_ABI,
      functionName: 'buyWithCard',
      value: parseEther('0.05'),
    });
  }

  if (!ONRAMP) return null;

  return (
    <div className="border rounded-lg p-4 mt-6 bg-yellow-50">
      <h2 className="text-xl font-semibold">¿Sin USDC? Comprá con tarjeta</h2>
      <p className="text-sm text-gray-600 mb-2">
        (Simulado — en producción esto sería MoonPay/Lemon)
      </p>
      <button
        onClick={buy50USDC}
        disabled={step !== 'idle' && step !== 'done'}
        className="bg-purple-600 disabled:bg-purple-400 text-white px-4 py-2 rounded w-full"
      >
        {step === 'idle' && '💳 Comprar 50 mUSDC con tarjeta'}
        {step === 'card' && 'Procesando tarjeta…'}
        {step === 'tx' && (isPending ? 'Confirmá en wallet…' : isLoading ? 'Esperando bloque…' : 'Enviando tx…')}
        {step === 'done' && '✅ 50 mUSDC en tu wallet'}
      </button>
      {hash && (
        <p className="text-xs mt-2">
          tx:{' '}
          <a
            className="underline"
            target="_blank"
            rel="noreferrer"
            href={`https://sepolia.etherscan.io/tx/${hash}`}
          >
            {hash.slice(0, 10)}…
          </a>
        </p>
      )}
    </div>
  );
}
