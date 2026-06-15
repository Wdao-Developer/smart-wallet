'use client'

import { useConnect, useConnection, useConnectors, useDisconnect } from 'wagmi'
import { ConnectButton,WalletButton  } from '@rainbow-me/rainbowkit';
import {SwapAndTransfer} from "@/customerComponents/SwapAndTransfer";
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
function App() {
  const connection = useConnection()
  const { connect, status, error } = useConnect()
  const connectors = useConnectors()
  const { disconnect } = useDisconnect()

  return (
    <>
    
     <div className='w-1/2 mx-auto'>
      <Card className="w-full max-w-full">
        {connection.status === 'connected'?
        <CardHeader className='flex flex-col justify-center items-center'>
          <CardTitle>Connection</CardTitle>
          <CardDescription >
            That's your Wallet account Infi:
          </CardDescription>
          <CardAction className='flex-col flex justify-center items-center w-full'>
            <ul className='flex-col flex justify-center items-center w-full gap-2'>
              <li className='w-full'>Wallet status: {connection.status}</li>
              <li className='w-full'>Wallet addresses: {JSON.stringify(connection.addresses)}</li>
              <li className='w-full'>chainId: {connection.chainId}</li>
            </ul>
          </CardAction>
        </CardHeader>
        :
        <CardHeader className='flex flex-col justify-center items-center'>
            <CardTitle>no Connection</CardTitle>
            <CardDescription >
              please press the button to Connectting wallet!
            </CardDescription>
            <CardAction className='flex-col flex justify-center items-center w-full'>
              
            </CardAction>
        </CardHeader>
        }
        <CardFooter className="flex-col gap-2">
            {connection.status === 'connected' ? 
            <>
            <button className='bg-red-600 text-[#f9fafb] cursor-pointer px-2 py-1 rounded-md' type="button" onClick={() => disconnect()} >
              Disconnect
            </button>
            
            </>
            :
            <ConnectButton accountStatus="avatar" />
          }
        </CardFooter>
      </Card>
     
    </div> 
    {connection.status === 'connected'?
      <div className='w-1/3 mx-auto '>
          <SwapAndTransfer/>
      </div>
    :
        <></>  
    }
    </>
  )
}

export default App
