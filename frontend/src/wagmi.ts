import { cookieStorage, createConfig, createStorage, http } from 'wagmi'
import { mainnet, sepolia, anvil, } from 'wagmi/chains'
import { injected } from "wagmi/connectors";

export function getConfig() {
  const chains=[mainnet,sepolia,anvil] as const;
  const metadata = {
      name: "Nextjs Wagmi Quickstart",
      projectId: process.env.NEXT_PUBLIC_PROJECT_ID || "",
    };
  return createConfig({
    
    chains:[anvil],
    storage: createStorage({
      storage: cookieStorage,
    }),
    connectors: [injected()],
    ssr: true,
    transports: {
      [anvil.id]: http('http://127.0.0.1:8545'),
    },
   // multiInjectedProviderDiscovery: false//必须关闭多钱包发现，否则在移动端 MetaMask 会重复触发连接
  })
}

declare module 'wagmi' {
  interface Register {
    config: ReturnType<typeof getConfig>
  }
}
