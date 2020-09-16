pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/* Interface Imports */
import { IL2CrossDomainMessenger } from "./L2CrossDomainMessenger.interface.sol";
import { DataTypes } from "../utils/libraries/DataTypes.sol";

/* Contract Imports */
import { BaseMockCrossDomainMessenger } from "./BaseMockCrossDomainMessenger.sol";
import { L1CrossDomainMessenger } from "./L1CrossDomainMessenger.sol";

/**
 * @title MockL1CrossDomainMessenger
 */
contract MockL1CrossDomainMessenger is BaseMockCrossDomainMessenger, L1CrossDomainMessenger {
    
    constructor(
        address _addressResolver
    )
        public
        L1CrossDomainMessenger(_addressResolver)
    {}
    
    /*
     * Internal Functions
     */

    /**
     * Verifies that the given message is valid.
     * .inheritdoc L1CrossDomainMessenger
     */
    function _verifyXDomainMessage(
        bytes memory _xDomainCalldata,
        DataTypes.L2MessageInclusionProof1 memory _proof,
        DataTypes.StateElementInclusionProof memory _stateRootProof
    )
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
        IL2CrossDomainMessenger(targetMessengerAddress).relayMessage(
            _target,
            _sender,
            _message,
            _messageNonce
        );
    }
}
