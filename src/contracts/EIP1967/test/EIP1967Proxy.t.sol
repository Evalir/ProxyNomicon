// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../lib/NomiconTest.sol";
import "../../basic/TheAnswer.sol";
import "../BasicEIP1967Proxy.sol";

contract Answer1967ProxyTest is NomiconTest {
    TheAnswer public answers;
    BasicEIP1967Proxy public proxy;
    address attacker;

    function setUp() public {
        answers = new TheAnswer();
        proxy = new BasicEIP1967Proxy(address(this), address(answers), "");

        vm.label(address(proxy), "Basic Upgradeable Proxy");
        vm.label(address(answers), "TheAnswer");

        attacker = account("attacker");
        vm.deal(attacker, 1 ether);
    }

    function test_callWithProxy() public {
        (bool success,) = address(proxy).call(abi.encodeWithSignature("changeTheRealAnswer(uint256)", 42));
        (bool success2,) = address(proxy).call(abi.encodeWithSignature("getTheRealAnswer()"));
        assert(success);
        assert(success2);
        answers.getTheRealAnswer();
    }

    function test_changePreviousCollidingSlot() public {
        (, bytes memory data) = address(proxy).call(abi.encodeWithSignature("getAnswer1()"));

        address implementationAddress = address(uint160(uint256(bytes32(data))));
        assert(address(implementationAddress) != address(answers));
        console.log(implementationAddress, address(answers));

        (bool success,) = address(proxy).call(abi.encodeWithSignature("changeAnswer1(uint256)", 42));
        assert(success);
        (, bytes memory answerData) = address(proxy).call(abi.encodeWithSignature("getAnswer1()"));

        uint256 answer = uint256(bytes32(answerData));
        assert(answer == 42);
        console.log("Answer is indeed 42");
    }
}
