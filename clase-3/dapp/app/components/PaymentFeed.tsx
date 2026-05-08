'use client';
import { useState } from 'react';
import { useWatchContractEvent } from 'wagmi';
import { formatUnits } from 'viem';
import { PAYGW_ABI } from '@/lib/abis';

const PAYGW = process.env.NEXT_PUBLIC_PAYGW_ADDRESS as `0x${string}` | undefined;

type PaidLog = {
  payer: string;
  amount: bigint;
  action: string;
  tx: string;
};

export function PaymentFeed() {
  const [logs, setLogs] = useState<PaidLog[]>([]);

  useWatchContractEvent({
    address: PAYGW,
    abi: PAYGW_ABI,
    eventName: 'Paid',
    enabled: !!PAYGW,
    onLogs(events) {
      const next: PaidLog[] = events.map((e) => {
        const args = (e as { args: { payer: string; amount: bigint; action: string } }).args;
        const tx = (e as { transactionHash: string }).transactionHash;
        return { payer: args.payer, amount: args.amount, action: args.action, tx };
      });
      setLogs((prev) => [...next, ...prev].slice(0, 20));
    },
  });

  return (
    <div className="border rounded-lg p-4 mt-6">
      <h2 className="text-xl font-semibold mb-2">Pagos recientes</h2>
      {logs.length === 0 && <p className="text-sm text-gray-500">Esperando eventos…</p>}
      <ul className="space-y-1">
        {logs.map((l) => (
          <li key={l.tx} className="text-xs font-mono">
            {l.payer.slice(0, 8)}… → {formatUnits(l.amount, 6)} USDC ({l.action.slice(0, 10)}…)
          </li>
        ))}
      </ul>
    </div>
  );
}
