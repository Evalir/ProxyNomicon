// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../lib/NomiconTest.sol";
import "../TheMeaningOfLife.sol";
import "../../transparent/TransparentProxy.sol";

contract TransparentUpgradeableProxyTest is NomiconTest {
    TheMeaningOfLife public deepThought;
    BasicTransparentUpgradeableProxy public proxy;
    address alice;

    function setUp() public {
        deepThought = new TheMeaningOfLife();
        deepThought.freezeImplementation();

        proxy = new BasicTransparentUpgradeableProxy(address(this));
        proxy.setImplementation(address(deepThought));

        vm.label(address(proxy), "Proxy");
        vm.label(address(deepThought), "Deep Thought");

        alice = account("alice");
        vm.deal(alice, 1 ether);
    }

    function test_transparency() public {
        (bool success,) = address(proxy).call(abi.encodeWithSignature("initialize(uint256)", 42));
        assert(success);
        (bool shouldFail,) = address(proxy).call(abi.encodeWithSignature("initialize(uint256)", 1337));
        assert(!shouldFail);

        // Let's try and get the implementation
        // This should succeed, as we're using the admin account (this contract)
        address implAddr = proxy.implementation();
        assert(implAddr == address(deepThought));
        console.log(implAddr, address(deepThought));

        // Now, let's pretend we're an user and try the same thing.
        // This should now fall through to the actual contract, even if
        // selectors are identical.
        vm.prank(alice);
        address notImplAddr = proxy.implementation();
        assert(address(deepThought) != notImplAddr);
        console.log(notImplAddr, address(deepThought));
    }
}
