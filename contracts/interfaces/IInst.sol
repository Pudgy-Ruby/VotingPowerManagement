// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IInst {

    /**
     * @dev Thrown when non-splitter address calls functions
     */
    error OnlySplitterCanCall();

    /**
     * @dev Thrown when token transfer failed
     */
    error TokenTransferFailed();

    /**
     * @dev Thrown when holder already exist
     */
    error HolderAlreadyExists();

    /**
     * @dev Thrown when invalid holder
     */
    error InvalidHolder();

    function delegate(address delegatee) external;
    function transfer(address dst, uint rawAmount) external returns (bool);
}