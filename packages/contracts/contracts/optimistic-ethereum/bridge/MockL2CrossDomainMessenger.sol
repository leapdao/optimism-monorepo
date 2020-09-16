pragma solidity ^0.5.0;

/* Interface Imports */
import { IL1CrossDomainMessenger } from "./L1CrossDomainMessenger.interface.sol";

/* Library Imports */
import { DataTypes } from "../utils/libraries/DataTypes.sol";

/* Contract Imports */
import { BaseMockCrossDomainMessenger } from "./BaseMockCrossDomainMessenger.sol";
import { L2CrossDomainMessenger } from "./L2CrossDomainMessenger.sol";

/**
 * @title MockL2CrossDomainMessenger
 */
contract MockL2CrossDomainMessenger is BaseMockCrossDomainMessenger, L2CrossDomainMessenger {
    
    constructor(
        address _l1MessageSenderPrecompileAddress,
        address _l2ToL1MessagePasserPrecompileAddress
    )
        public
        L2CrossDomainMessenger(_l1MessageSenderPrecompileAddress, _l2ToL1MessagePasserPrecompileAddress)
    {}

    /*
     * Internal Functions
     */

    /**
     * Verifies that a received cross domain message is valid.
     * .inheritdoc L2CrossDomainMessenger
     */
    function _verifyXDomainMessage()
        internal
        returns (
            bool
        )
    {
        return true;
    }

    /**
     * Internal relay function.
     */
    function _relayXDomainMessageToTarget(
        address _target,
        address _sender,
        bytes memory _message,
        uint256 _messageNonce
    )
        internal
    {
        DataTypes.L2MessageInclusionProof1 memory proof = DataTypes.L2MessageInclusionProof1({
                stateRoot: bytes32(''),
                stateRootIndex: 0,
                stateTrieWitness: bytes(''),
                storageTrieWitness: bytes('')
            });
        DataTypes.StateElementInclusionProof memory stateRootProof = DataTypes.StateElementInclusionProof({
                    batchIndex: 0,
                    batchHeader: DataTypes.StateChainBatchHeader({
                        elementsMerkleRoot: bytes32(''),
                        numElementsInBatch: 0,
                        cumulativePrevElements: 0
                    }),
                    indexInBatch: 0,
                    siblings: new bytes32[](1)
                });
        IL1CrossDomainMessenger(targetMessengerAddress).relayMessage(
            _target,
            _sender,
            _message,
            _messageNonce,
            proof,
            stateRootProof
        );
    }
}
