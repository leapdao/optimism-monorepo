pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/**
 * @title DataTypes
 * @notice Main data structures which to be used in rollup smart contracts.
 */
library DataTypes {
    struct L2ToL1Message {
        address ovmSender;
        bytes callData;
    }

    struct Transaction {
        address ovmEntrypoint;
        bytes ovmCalldata;
    }

    struct StorageElement {
        address ovmContractAddress;
        bytes32 ovmStorageSlot;
        bytes32 ovmStorageValue;
    }

    struct ExecutionContext {
        bool inStaticContext;
        uint chainId;
        uint timestamp;
        uint blockNumber;
        uint queueOrigin;
        address ovmActiveContract;
        address ovmMsgSender;
        address ovmTxOrigin;
        address l1MessageSender;
        uint ovmTxGasLimit;
    }

    struct L2MessageInclusionProof1 {
        bytes32 stateRoot;
        uint256 stateRootIndex;
        bytes stateTrieWitness;
        bytes storageTrieWitness;
    }

    struct GasMeterConfig {
        uint OvmTxBaseGasFee; // The flat gas overhead imposed on all transactions
        uint OvmTxMaxGas; // Max gas a single transaction is allowed
        uint GasRateLimitEpochSeconds; // The frequency with which we reset the gas rate limit, expressed in same units as ETH timestamp
        uint MaxSequencedGasPerEpoch; // The max gas which sequenced tansactions consume per rate limit epoch
        uint MaxQueuedGasPerEpoch; // The max gas which queued tansactions consume per rate limit epoch
    }

    struct TxElementInclusionProof {
       uint batchIndex;
       TxChainBatchHeader batchHeader;
       uint indexInBatch;
       bytes32[] siblings;
    }

    struct StateElementInclusionProof {
       uint batchIndex;
       StateChainBatchHeader batchHeader;
       uint indexInBatch;
       bytes32[] siblings;
    }

    struct StateChainBatchHeader {
       bytes32 elementsMerkleRoot;
       uint numElementsInBatch;
       uint cumulativePrevElements;
    }

    struct TxChainBatchHeader {
       uint timestamp;
       uint blockNumber;
       bool isL1ToL2Tx;
       bytes32 elementsMerkleRoot;
       uint numElementsInBatch;
       uint cumulativePrevElements;
    }

    struct TimestampedHash {
       bytes32 txHash;
       uint timestamp;
       uint blockNumber;
    }

    struct AccountState {
        uint256 nonce;
        uint256 balance;
        bytes32 storageRoot;
        bytes32 codeHash;
    }

    struct ProofMatrix {
        bool checkNonce;
        bool checkBalance;
        bool checkStorageRoot;
        bool checkCodeHash;
    }

    struct OVMTransactionData {
        uint256 timestamp;
        uint256 blockNumber;
        uint256 queueOrigin;
        address ovmEntrypoint;
        bytes callBytes;
        address fromAddress;
        address l1MsgSenderAddress;
        uint256 gasLimit;
        bool allowRevert;
    }
}
