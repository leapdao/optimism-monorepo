pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

/* Library Imports */
import { DataTypes } from "../utils/libraries/DataTypes.sol";

/**
 * @title IL1CrossDomainMessenger
 */
contract IL1CrossDomainMessenger {
    /*
     * Contract Variables
     */

    mapping (bytes32 => bool) public receivedMessages;
    mapping (bytes32 => bool) public sentMessages;
    address public targetMessengerAddress;
    uint256 public messageNonce;
    address public xDomainMessageSender;


    /*
     * Public Functions
     */
    
    /**
     * Relays a cross domain message to a contract.
     * @param _target Target contract address.
     * @param _sender Message sender address.
     * @param _message Message to send to the target.
     * @param _messageNonce Nonce for the provided message.
     * @param _proof Inclusion proof for the given message.
     */
    function relayMessage(
        address _target,
        address _sender,
        bytes memory _message,
        uint256 _messageNonce,
        DataTypes.L2MessageInclusionProof1 memory _proof,
        DataTypes.StateElementInclusionProof memory _stateElementProof
    ) public;

    /**
     * Sends a cross domain message to the target messenger.
     * @param _target Target contract address.
     * @param _message Message to send to the target.
     * @param _gasLimit Gas limit for the provided message.
     */
    function sendMessage(
        address _target,
        bytes memory _message,
        uint32 _gasLimit
    ) public;

    /**
     * Replays a cross domain message to the target messenger.
     * @param _target Target contract address.
     * @param _sender Original sender address.
     * @param _message Message to send to the target.
     * @param _messageNonce Nonce for the provided message.
     * @param _gasLimit Gas limit for the provided message.
     */
    function replayMessage(
        address _target,
        address _sender,
        bytes memory _message,
        uint256 _messageNonce,
        uint32 _gasLimit
    ) public;
}