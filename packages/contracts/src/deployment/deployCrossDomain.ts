import { ethers, Contract, Signer, Wallet } from "ethers";
import {
  ZERO_ADDRESS,
  getLogger,
  add0x,
  deploy,
} from "@eth-optimism/core-utils";
import { deployAndRegister } from "./contract-deploy";

import { getL1DeploymentSigner } from "./config";
import {
  getContractFactory,
  getContractInterface,
  getContractDefinition,
} from "../contract-imports";

import { Environment } from "./environment";
import { deployContract } from "ethereum-waffle";
import { GAS_LIMIT } from "@eth-optimism/rollup-core";

const log = getLogger("cross-domain-deploy");

const addressResolverAddr = process.env.L1_ADDRESS_RESOLVER_CONTRACT_ADDRESS;

if (!addressResolverAddr) {
  throw new Error("Missing L1_ADDRESS_RESOLVER_CONTRACT_ADDRESS env variable");
}

const signer: Signer = getL1DeploymentSigner();

const l2Provider = new ethers.providers.JsonRpcProvider(
  "http://localhost:8545"
);

const l2Signer = new Wallet(
  add0x(Environment.l1ContractDeploymentPrivateKey()),
  l2Provider
);

const l1AddressResolver = new Contract(
  addressResolverAddr,
  getContractInterface("AddressResolver"),
  signer
);

const getL2AddressResolver = async (addressResolverContractAddress: string) => {
  if (!addressResolverContractAddress) {
    log.debug(`No deployed AddressResolver found. Deploying...`);
    const addressResolver = await await deployContract(
      l2Signer,
      getContractDefinition("AddressResolver"),
      [],
      { gasLimit: GAS_LIMIT, gasPrice: 0 }
    );
    log.info(`Deployed L2 AddressResolver to ${addressResolver.address}`);
    return addressResolver;
  }

  log.info(
    `Using deployed L2 AddressResolver at address ${addressResolverContractAddress}`
  );
  return new Contract(
    addressResolverContractAddress,
    getContractInterface("AddressResolver"),
    l2Signer
  );
};

const deployCrossDomainMessengers = async () => {
  let l1CrossDomainMessenger;

  const L1_CDM = "L1CrossDomainMessenger"; // 0xD72B6c1623Ef875bB69f9693ebFD23909243460E
  const L2_CDM = "L2CrossDomainMessenger"; // 0xbedb5Bf62874e4109aFCD3718cd97d1911A64cdD

  let deployedAddress = await l1AddressResolver.getAddress(L1_CDM);

  const config = {
    signer,
    factory: getContractFactory(L1_CDM),
    params: [addressResolverAddr],
  };

  if (!!deployedAddress && deployedAddress !== ZERO_ADDRESS) {
    log.info(
      `Using existing deployed and registered contract for ${L1_CDM} at address ${deployedAddress}`
    );
    l1CrossDomainMessenger = new Contract(
      deployedAddress,
      config.factory.interface,
      config.signer
    );
  } else {
    l1CrossDomainMessenger = await deployAndRegister(
      l1AddressResolver,
      L1_CDM,
      config
    );
  }

  const l2AddressResolver = await getL2AddressResolver(
    process.env.L2_ADDRESS_RESOLVER_CONTRACT_ADDRESS
  );

  const l2Config = {
    signer: l2Signer,
    factory: getContractFactory(L2_CDM),
    params: [
      "0x4200000000000000000000000000000000000001",
      "0x4200000000000000000000000000000000000000",
    ],
  };

  let l2CrossDomainMessenger;
  deployedAddress = await l2AddressResolver.getAddress(L2_CDM);

  if (!!deployedAddress && deployedAddress !== ZERO_ADDRESS) {
    log.info(
      `Using existing deployed and registered contract for ${L2_CDM} at address ${deployedAddress}`
    );
    l2CrossDomainMessenger = new Contract(
      deployedAddress,
      getContractFactory(L2_CDM).interface,
      l2Signer
    );
  } else {
    log.debug(`Deploying ${L2_CDM} with params: [${[...l2Config.params]}]...`);

    l2CrossDomainMessenger = await deployContract(
      l2Signer,
      getContractDefinition(L2_CDM),
      [
        "0x4200000000000000000000000000000000000001",
        "0x4200000000000000000000000000000000000000",
      ],
      { gasLimit: GAS_LIMIT, gasPrice: 0 }
    );

    log.info(
      `Deployed ${L2_CDM} at address ${l2CrossDomainMessenger.address}.`
    );

    await l2AddressResolver.setAddress(L2_CDM, l2CrossDomainMessenger.address);
  }

  log.debug(`Wiring ${L2_CDM} and ${L1_CDM} together...`);
  await l2CrossDomainMessenger.setTargetMessengerAddress(
    l1CrossDomainMessenger.address
  );

  await l1CrossDomainMessenger.setTargetMessengerAddress(
    l2CrossDomainMessenger.address
  );
};

export { deployCrossDomainMessengers };
