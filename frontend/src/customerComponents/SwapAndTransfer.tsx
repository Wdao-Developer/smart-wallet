import * as React from 'react'
import { useState } from 'react'
import { 
type BaseError,
  useWaitForTransactionReceipt, 
  useWriteContract ,
  useConnection,
  useConfig
} from 'wagmi' 
import { parseEther } from 'viem' 

import { Button } from "@/components/ui/button"
import {
  Field,
  FieldDescription,
  FieldGroup,
  FieldLabel,
  FieldLegend,
  FieldSeparator,
  FieldSet,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input";
import proxyWalletAbiJson from "abi/ProxyWallet.json" with { type: 'json' };
import { Old_Standard_TT } from 'next/font/google'
import { getAddress } from 'viem'


interface PoolState {
  currency0:   string ;
  currency1:   string ;
  fee: BigInt;
  tickSpacing: BigInt;
  hooks:string;
}

function SwapAndTransfer() {
     const { 
       data: hash,
        error,
        isPending, 
        writeContract 
    } = useWriteContract();
    const { chainId,status } = useConnection();
    const config = useConfig()
   
    const [poolState, setPoolState] = useState<PoolState>({
            currency0: '',
            currency1: '',
            fee: BigInt(3000),
            tickSpacing: BigInt(60) ,
            hooks: '0x0000000000000000000000000000000000000000'
        });
    async function submit(e: React.FormEvent<HTMLFormElement>) { 
        e.preventDefault() 
        const formData = new FormData(e.target as HTMLFormElement) 
        const amount = Number(formData.get('amount')) ;
        const addressProxyWallet = getAddress(formData.get('addressProxyWallet') as `0x${string}`);
        const addresToken = getAddress(formData.get('addresToken') as `0x${string}`);
        const addresTo = getAddress(formData.get('addresTo') as `0x${string}`);
        const {abi} = proxyWalletAbiJson;
       
       const checkPoolState = {...poolState,
        token0:getAddress(poolState.currency0),
        token1:getAddress(poolState.currency1),
       }
        writeContract({
            address:addressProxyWallet,
            abi,
            functionName: 'swapAndTransfer',
            args: [checkPoolState,addresToken,addresTo,BigInt(amount)],
        })
    } 
   const { isLoading: isConfirming, isSuccess: isConfirmed } = 
        useWaitForTransactionReceipt({ 
        hash, 
    })
    return (
        <div className='mx-auto my-4'>
            <form onSubmit={submit} className='w-full my-4'>
                <FieldGroup>
                    <FieldSet>
                        <FieldLegend>SetUp The Pool</FieldLegend>
                        <FieldDescription>
                            set the poolkey before swap
                        </FieldDescription>
                        <FieldGroup>
                            <Field>
                                <FieldLabel >
                                    Currey0 Address:
                                </FieldLabel>
                                <Input
                                    name="addressCurrey0" placeholder="0xA0Cf…251e" 
                                    onChange={(e:any)=>{
                                        setPoolState((old:any)=>{
                                            return {
                                                ...old,
                                                currency0:e.target.value==""?null:e.target.value
                                            }
                                        })
                                        
                                    }}
                                    required
                                />
                                <FieldDescription>
                                    Enter your Currey0 before swap  
                                </FieldDescription>
                            </Field>
                             <Field>
                                <FieldLabel >
                                    Currey1 Address:
                                </FieldLabel>
                                <Input
                                    name="addressCurrey1" placeholder="0xA0Cf…251e" 
                                     onChange={(e:any)=>{
                                        setPoolState((old:any)=>{
                                            return {
                                                ...old,
                                                currency1:e.target.value==""?null:e.target.value
                                            }
                                        })
                                        
                                    }}
                                    required
                                />
                                <FieldDescription>
                                    Enter your Currey1 before swap  
                                </FieldDescription>
                            </Field>
                        </FieldGroup>
                    </FieldSet>
                </FieldGroup>
                <FieldGroup>
                    <FieldSet>
                        <FieldLegend>Swap And Transfer</FieldLegend>
                        <FieldDescription>
                            All transactions are secure and encrypted
                        </FieldDescription>
                        <FieldGroup>
                        <Field>
                            <FieldLabel >
                                Contranct Address:
                            </FieldLabel>
                            <Input
                                name="addressProxyWallet" placeholder="0xA0Cf…251e" 
                                required
                            />
                            <FieldDescription>
                                Enter your address of proxyWallet contract   
                            </FieldDescription>
                        </Field>
                        <Field>
                            <FieldLabel >
                                ERC20 Token Address :
                            </FieldLabel>
                            <Input
                                name="addresToken" placeholder="0xA0Cf…251e" 
                                required
                            />
                            <FieldDescription>
                                Enter ERC20 Token Address where Transfer to a Account   
                            </FieldDescription>
                        </Field>
                        <Field>
                            <FieldLabel >
                                Account :
                            </FieldLabel>
                            <Input
                                name="addresTo" placeholder="0xA0Cf…251e" 
                                required
                            />
                            <FieldDescription>
                                Enter Account address where to Transfer   
                            </FieldDescription>
                        </Field>
                        <Field>
                            <FieldLabel htmlFor="checkout-7j9-card-number-uw1">
                                Amount
                            </FieldLabel>
                            <Input
                                name="amount" placeholder="0.05" required
                            />
                            <FieldDescription>
                                Enter your Amount to tranform
                            </FieldDescription>
                        </Field>
                        </FieldGroup>
                    </FieldSet>
                    <Field orientation="horizontal">
                            <Button type="submit"  disabled={isPending}>
                                {isPending ? 'Confirming...' : 'Send'} 
                            </Button>
                        {hash && <div className='text-[#2563eb]'>Transaction Hash: {hash}</div>} 
                        {isConfirming && <FieldDescription className='text-[#f97316]'>Waiting for confirmation...</FieldDescription>} 
                        {isConfirmed && <FieldDescription className='text-[#16a34a]'>Transaction confirmed.</FieldDescription>} 
                        {error && ( 
                            <FieldDescription className='text-[#ef4444]'>Error: { error.message}</FieldDescription> 
                        )} 
                    </Field>
                </FieldGroup>
            </form>
            </div>
        ) 
    }

export { SwapAndTransfer }