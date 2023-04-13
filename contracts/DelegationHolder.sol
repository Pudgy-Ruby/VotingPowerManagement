// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "./interfaces/IInst.sol";

contract DelegationHolder {
    IInst public inst;
    address public delegatee;
    address public splitter;

    function initialize(IInst _inst) external {
        inst = _inst;
        splitter = msg.sender;
    }

    function withdrawTokens(uint256 amount) external {
        if (msg.sender != splitter) {
            revert IInst.OnlySplitterCanCall();
        }
        if (!inst.transfer(msg.sender, amount)) {
            revert IInst.TokenTransferFailed();
        }
    }

    function delegate(address newDelegatee) external {
        if (msg.sender != splitter) {
            revert IInst.OnlySplitterCanCall();
        }
        IInst(inst).delegate(newDelegatee);
    }
}