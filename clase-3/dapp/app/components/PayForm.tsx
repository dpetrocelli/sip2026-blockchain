'use client';
import { useState } from 'react';
import {
  useAccount,
  useReadContract,
  useWriteContract,
  useWaitForTransactionReceipt,
} from 'wagmi';
import { parseUnits, keccak256, toHex } from 'viem';
import { PAYGW_ABI, ERC20_ABI } from '@/lib/abis';

const PAYGW = process.env.NEXT_PUBLIC_PAYGW_ADDRESS as `0x${string}` | undefined;
const USDC = process.env.NEXT_PUBLIC_USDC_ADDRESS as `0x${string}` | undefined;

export function PayForm() {
  const { address } = useAccount();
  const [amount, setAmount] = useState('1');
  const [action, setAction] = useState('VIBE_TICKET');

  const amountWei = parseUnits(amount || '0', 6);
  const actionBytes = keccak256(toHex(action));

  const { data: balance } = useReadContract({
    address: USDC,
    abi: ERC20_ABI,
    functionName: 'balanceOf',
    args: address ? [address] : undefined,
    query: { enabled: !!address && !!USDC },
  });

  const { data: allowance } = useReadContract({
    address: USDC,
    abi: ERC20_ABI,
    functionName: 'allowance',
    args: address && PAYGW ? [address, PAYGW] : undefined,
    query: { enabled: !!address && !!USDC && !!PAYGW },
  });

  const needsApprove = (allowance ?? 0n) < amountWei;

  const {
    writeContract: writeApprove,
    data: approveHash,
    isPending: approvePending,
  } = useWriteContract();
  const {
    writeContract: writePay,
    data: payHash,
    isPending: payPending,
  } = useWriteContract();

  const { isLoading: approveConfirming } = useWaitForTransactionReceipt({ hash: approveHash });
  const { isLoading: payConfirming, isSuccess: payDone } = useWaitForTransactionReceipt({
    hash: payHash,
  });

  function handleApprove() {
    if (!USDC || !PAYGW) return;
    writeApprove({
      address: USDC,
      abi: ERC20_ABI,
      functionName: 'approve',
      args: [PAYGW, amountWei],
    });
  }

  function handlePay() {
    if (!PAYGW) return;
    writePay({
      address: PAYGW,
      abi: PAYGW_ABI,
      functionName: 'pay',
      args: [amountWei, actionBytes],
    });
  }

  if (!PAYGW || !USDC) {
    return (
      <div className="border rounded-lg p-4 mt-6 bg-red-50">
        Falta configurar <code>NEXT_PUBLIC_PAYGW_ADDRESS</code> /{' '}
        <code>NEXT_PUBLIC_USDC_ADDRESS</code> en <code>.env.local</code>.
      </div>
    );
  }

  return (
    <div className="border rounded-lg p-4 mt-6 space-y-3">
      <h2 className="text-xl font-semibold">Pagar con USDC</h2>
      <p className="text-sm">Balance: {balance ? Number(balance) / 1e6 : 0} USDC</p>

      <input
        className="border p-2 w-full rounded"
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="USDC a pagar"
      />
      <input
        className="border p-2 w-full rounded"
        value={action}
        onChange={(e) => setAction(e.target.value)}
        placeholder="action (ej. VIBE_TICKET)"
      />

      {needsApprove ? (
        <button
          onClick={handleApprove}
          disabled={approvePending || approveConfirming}
          className="bg-blue-600 disabled:bg-blue-400 text-white px-4 py-2 rounded w-full"
        >
          {approvePending
            ? 'Confirmá en wallet…'
            : approveConfirming
              ? 'Esperando bloque…'
              : `1) Approve ${amount} USDC`}
        </button>
      ) : (
        <button
          onClick={handlePay}
          disabled={payPending || payConfirming}
          className="bg-green-600 disabled:bg-green-400 text-white px-4 py-2 rounded w-full"
        >
          {payPending
            ? 'Confirmá en wallet…'
            : payConfirming
              ? 'Esperando bloque…'
              : `2) Pay ${amount} USDC`}
        </button>
      )}

      {approveHash && (
        <p className="text-xs">
          approve tx:{' '}
          <a
            className="underline"
            target="_blank"
            rel="noreferrer"
            href={`https://sepolia.etherscan.io/tx/${approveHash}`}
          >
            {approveHash.slice(0, 10)}…
          </a>
        </p>
      )}
      {payHash && (
        <p className="text-xs">
          pay tx:{' '}
          <a
            className="underline"
            target="_blank"
            rel="noreferrer"
            href={`https://sepolia.etherscan.io/tx/${payHash}`}
          >
            {payHash.slice(0, 10)}…
          </a>
        </p>
      )}
      {payDone && <p className="text-green-700">✅ Pago confirmado</p>}
    </div>
  );
}
