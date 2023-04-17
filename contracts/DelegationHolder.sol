// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./interfaces/IInst.sol";

contract DelegationHolder {
    IInst public immutable inst;
    address public splitter;

    /**
     * @dev Thrown when non-splitter address calls functions
     */
    error OnlySplitterCanCall();

    /**
     * @dev Thrown when token transfer failed
     */
    error TokenTransferFailed();

    constructor(IInst _inst) {
        inst = _inst;
        splitter = msg.sender;
    }

    function withdrawTokens(uint256 amount) external {
        if (msg.sender != splitter) {
            revert OnlySplitterCanCall();
        }
        if (!inst.transfer(msg.sender, amount)) {
            revert TokenTransferFailed();
        }
    }

    function delegate(address newDelegatee) external {
        if (msg.sender != splitter) {
            revert OnlySplitterCanCall();
        }
        IInst(inst).delegate(newDelegatee);
    }
}