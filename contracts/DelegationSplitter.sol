// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DelegationHolder.sol";
import "./interfaces/IInst.sol";

contract DelegationSplitter is Ownable {
    mapping(address => bool) public holders;
    mapping(bytes32 => address) public holderById;
    IInst public inst;

    event HolderCreated(address holder, bytes32 holderId);
    event TokenTransferred(address fromHolder, address toHolder, uint256 amount);
    event TokenDelegated(address holder, address delegatee);

    constructor(IInst _inst) {
        inst = _inst;
    }

    function createHolder(bytes32 holderId) external onlyOwner {
        if (holders[holderById[holderId]]) {
            revert IInst.HolderAlreadyExists();
        }
        // Deploy Contract

        bytes32 bytecodeHash = keccak256(type(DelegationHolder).creationCode);
        bytes32 saltHash = keccak256(abi.encodePacked(holderId));
        bytes32 contractHash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), saltHash, bytecodeHash)
        );
        address newHolder = address(uint160(uint256(contractHash)));

        DelegationHolder(newHolder).initialize(inst);

        holders[newHolder] = true;
        holderById[holderId] = newHolder;

        emit HolderCreated(newHolder, holderId);
    }

    function transferTokens(address fromHolder, address toHolder, uint256 amount) external onlyOwner{
        if (!holders[fromHolder] || !holders[toHolder]) {
            revert IInst.InvalidHolder();
        }

        DelegationHolder(fromHolder).withdrawTokens(amount);
        IInst(inst).transfer(toHolder, amount);

        emit TokenTransferred(fromHolder, toHolder, amount);
    }

    function delegateTokens(address holder, address delegatee) external onlyOwner {
        if (!holders[holder]) {
            revert IInst.InvalidHolder();
        }

        DelegationHolder(holder).delegate(delegatee);

        emit TokenDelegated(holder, delegatee);
    }

    function withdrawTokens(address holder, address to, uint256 amount) external onlyOwner{
        if (!holders[holder]) {
            revert IInst.InvalidHolder();
        }

        DelegationHolder(holder).withdrawTokens(amount);
        if (!IInst(inst).transfer(to, amount)) {
            revert IInst.TokenTransferFailed();
        }
    }
}