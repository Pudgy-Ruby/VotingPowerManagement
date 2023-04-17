// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./DelegationHolder.sol";
import "./interfaces/IInst.sol";

contract DelegationSplitter is Ownable {
    uint256 public holders;
    IInst public immutable inst;

    event HolderCreated(address holder, bytes32 holderId);
    event TokenTransferred(address fromHolder, address toHolder, uint256 amount);
    event TokenDelegated(address holder, address delegatee);

    /**
     * @dev Thrown when holder already exist
     */
    error HolderAlreadyExists();

    /**
     * @dev Thrown when invalid holder
     */
    error InvalidHolder();

    /**
     * @dev Thrown when token transfer failed
     */
    error TokenTransferFailed();

    constructor(IInst _inst) {
        inst = _inst;
        _transferOwnership(msg.sender);
    }

    function createHolder(bytes32 holderId) external onlyOwner {

        bytes memory bytecode = type(DelegationHolder).creationCode;
        bytes32 saltHash = keccak256(abi.encodePacked(holderId));
        bytes32 bytecodeHash = keccak256(abi.encodePacked(bytecode, inst, saltHash));

        bytes32 contractHash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), saltHash, bytecodeHash)
        );
        address newHolder;


        if (isContract(newHolder)) {
            revert HolderAlreadyExists();
        }

        assembly {
            newHolder := create2(0, add(bytecode, 0x20), mload(bytecode), contractHash)
            if iszero(extcodesize(newHolder)) {
                revert(0, 0)
            }
        }

        holders++;

        emit HolderCreated(newHolder, holderId);
    }

    function transferTokens(address fromHolder, address toHolder, uint256 amount) external onlyOwner{
        if (!isContract(fromHolder) || !isContract(toHolder)) {
            revert InvalidHolder();
        }

        DelegationHolder(fromHolder).withdrawTokens(amount);
        IInst(inst).transfer(toHolder, amount);

        emit TokenTransferred(fromHolder, toHolder, amount);
    }

    function delegateTokens(address holder, address delegatee) external onlyOwner {
        if (!isContract(holder)) {
            revert InvalidHolder();
        }

        DelegationHolder(holder).delegate(delegatee);

        emit TokenDelegated(holder, delegatee);
    }

    function withdrawTokens(address holder, address to, uint256 amount) external onlyOwner{
        if (!isContract(holder)) {
            revert InvalidHolder();
        }

        DelegationHolder(holder).withdrawTokens(amount);
        if (!IInst(inst).transfer(to, amount)) {
            revert TokenTransferFailed();
        }
    }

    function isContract(address _addr) private returns (bool isContract){
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }
}