// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IInst {

    function delegate(address delegatee) external;
    function transfer(address dst, uint rawAmount) external returns (bool);
}