import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { sepolia } from 'wagmi/chains';

export const config = getDefaultConfig({
  appName: 'PayGW SIP',
  projectId: process.env.NEXT_PUBLIC_WC_PROJECT_ID ?? 'demo-project-id',
  chains: [sepolia],
  ssr: true,
});
