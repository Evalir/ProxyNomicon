// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../lib/NomiconTest.sol";
import "../TheMeaningOfLife.sol";
import "../../transparent/TransparentProxy.sol";

contract TransparentUpgradeableProxyTest is NomiconTest {
    TheMeaningOfLife public deepThought;
    TheMeaningOfLife public deepThought2;
    BasicTransparentUpgradeableProxy public proxy;
    address alice;

    function setUp() public {
        deepThought = new TheMeaningOfLife();
        deepThought2 = new TheMeaningOfLife();
        deepThought.freezeImplementation();
        deepThought2.freezeImplementation();

        vm.label(address(proxy), "Proxy");
        vm.label(address(deepThought), "Deep Thought");

        alice = account("alice");
        vm.deal(alice, 1 ether);

        proxy = new BasicTransparentUpgradeableProxy(address(this), address(deepThought), "");
    }

    function test_transparency() public {
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
        assert(address(42) == notImplAddr);
        console.log(notImplAddr, address(deepThought));
    }

    function test_upgradeability() public {
        address oldImplAddress = proxy.implementation();
        assert(oldImplAddress == address(deepThought));

        proxy.setImplementation(address(deepThought2));

        address newImplAddress = proxy.implementation();
        assert(newImplAddress == address(deepThought2));
    }
}
