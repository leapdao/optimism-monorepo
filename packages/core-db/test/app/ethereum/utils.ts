/* External Imports */
import { getLogger, sleep, objectsEqual } from '@eth-optimism/core-utils'

import * as assert from 'assert'
import { ethers } from 'ethers'

/* Internal Imports */
import { EthereumListener } from '../../../src/types/ethereum'

const log = getLogger('ethereum-test-utils', true)

export class TestListener<T> implements EthereumListener<T> {
  private received: T[]
  private syncCompleted: boolean

  public constructor(private readonly sleepMillis = 50) {
    this.syncCompleted = false
    this.received = []
  }

  public async onSyncCompleted(): Promise<void> {
    this.syncCompleted = true
  }

  public async handle(t: T): Promise<void> {
    log.debug(`Received ${JSON.stringify(t)}`)
    if (this.received.length === 0) {
      this.received.push(t)
    } else if (this.received.filter((x) => objectsEqual(x, t)).length === 0) {
      this.received.push(t)
    }
  }

  public getReceived(): T[] {
    return this.received.splice(0)
  }

  public async waitForReceive(
    num: number = 1,
    timeoutMillis: number = -1
  ): Promise<T[]> {
    const startTime = new Date().getTime()
    while (
      this.received.length < num &&
      (timeoutMillis < 0 || new Date().getTime() - startTime < timeoutMillis)
    ) {
      await sleep(this.sleepMillis)
    }
    return this.getReceived()
  }

  public async waitForSyncToComplete(): Promise<T[]> {
    while (!this.syncCompleted) {
      await sleep(this.sleepMillis)
    }
    return this.getReceived()
  }

  public async assertNotReceivedAfter(millis: number): Promise<void> {
    await sleep(millis)
    assert(this.getReceived().length === 0, 'Should not have received but did!')
  }
}

const TestToken = require('./contracts/build/TestToken.json')

export const deployTokenContract = async (
  ownerWallet: ethers.Wallet,
  initialSupply: number
): Promise<ethers.Contract> => {
  const factory = new ethers.ContractFactory(
    TestToken.abi,
    TestToken.bytecode,
    ownerWallet
  )

  // Notice we pass in "Hello World" as the parameter to the constructor
  const tokenContract = await factory.deploy(initialSupply)

  return tokenContract.deployed()
}
