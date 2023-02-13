// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {Initializable} from "../lib/Initializable.sol";

contract TheMeaningOfLife is Initializable {
    uint256 theAnswerToLife;

    function initialize(uint256 answer) public onlyUninitialized {
        theAnswerToLife = answer;

        initialized();
    }

    function getTheAnswer() external view returns (uint256) {
        return theAnswerToLife;
    }

    function implementation() external pure returns (address) {
        return address(uint160(uint256(42)));
    }
}