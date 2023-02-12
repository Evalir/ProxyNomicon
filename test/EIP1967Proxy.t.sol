// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/lib/NomiconTest.sol";
import "../src/basic/TheAnswer.sol";
import "../src/EIP1967/BasicEIP1967Proxy.sol";

contract Answer1967ProxyTest is NomiconTest {
    TheAnswer public answers;
    BasicEIP1967Proxy public proxy;
    address attacker;

    function setUp() public {
        answers = new TheAnswer();
        proxy = new BasicEIP1967Proxy(address(this));
        proxy.setImplementation(address(answers));

        vm.label(address(proxy), "Basic Upgradeable Proxy");
        vm.label(address(answers), "TheAnswer");

        attacker = account("attacker");
        vm.deal(attacker, 1 ether);
    }

    function test_callWithProxy() public {
        address(proxy).call(abi.encodeWithSignature("changeTheRealAnswer(uint256)", 42));
        address(proxy).call(abi.encodeWithSignature("getTheRealAnswer()"));
        answers.getTheRealAnswer();
    }

    function test_changePreviousCollidingSlot() public {
        (, bytes memory data) = address(proxy).call(abi.encodeWithSignature("getAnswer1()"));

        address implementationAddress = address(uint160(uint256(bytes32(data))));
        assert(address(implementationAddress) != address(answers));
        console.log(implementationAddress, address(answers));

        address(proxy).call(abi.encodeWithSignature("changeAnswer1(uint256)", 42));
        (, bytes memory answerData) = address(proxy).call(abi.encodeWithSignature("getAnswer1()"));

        uint256 answer = uint256(bytes32(answerData));
        assert(answer == 42);
        console.log("Answer is indeed 42");
    }
}
