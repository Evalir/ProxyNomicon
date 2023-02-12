// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract TheAnswer {
    uint256 public answer1;
    uint256 public answer2;
    uint256 public theRealAnswer;

    function getTheRealAnswer() public view returns (uint256) {
        return theRealAnswer;
    }

    function getAnswer1() public view returns (uint256) {
        return answer1;
    }

    function getAnswer2() public view returns (uint256) {
        return answer2;
    }

    function changeAnswer1(uint256 newAnswer) public {
        answer1 = newAnswer;
    }

    function changeAnswer2(uint256 newAnswer) public {
        answer2 = newAnswer;
    }

    function changeTheRealAnswer(uint256 newAnswer) public {
        theRealAnswer = newAnswer;
    }
}
