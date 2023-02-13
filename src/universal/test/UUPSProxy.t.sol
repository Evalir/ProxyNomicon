// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../../lib/NomiconTest.sol";
import "../../finance/UUPSPaymentSplitter.sol";
import "../UUPSProxy.sol";

contract UUPSProxyTest is NomiconTest {
    PaymentSplitter public splitter;
    PaymentSplitter public splitter2;
    UUPSProxy public proxy;
    address alice;
    address bob;

    function setUp() public {
        splitter = new PaymentSplitter();
        splitter2 = new PaymentSplitter();
        splitter.freezeImplementation();
        splitter2.freezeImplementation();

        proxy = new UUPSProxy(address(this), address(splitter));

        vm.label(address(proxy), "Proxy");
        vm.label(address(splitter), "Splitter1");
        vm.label(address(splitter2), "Splitter2");

        alice = account("alice");
        bob = account("bob");
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
    }

    function test_setupAndUpgrade() public {
        // Initialize the proxy
        address[] memory payees = new address[](2);
        payees[0] = alice;
        payees[1] = bob;
        uint256[] memory shares = new uint256[](2);
        shares[0] = 1;
        shares[1] = 1;

        // Proxy initialization and ownership checks
        {
            (bool success,) = address(proxy).call(
                abi.encodeWithSignature("initialize(address[],uint256[],address)", payees, shares, address(this))
            );
            assert(success);
            // Test that we cannot initialize again
            (bool shouldFail,) = address(proxy).call(
                abi.encodeWithSignature("initialize(address[],uint256[],address)", payees, shares, address(this))
            );
            assert(!shouldFail);
            // Get the owner and assert we are the owner
            (, bytes memory ownerData) = address(proxy).call(abi.encodeWithSignature("owner()"));
            address owner = bytesToAddress(ownerData);
            assert(owner == address(this));
            console.log(owner, address(this));
        }

        // Proxy state, upgrade and after-upgrade state checks
        {
            (, bytes memory totalSharesData) = address(proxy).call(abi.encodeWithSignature("totalShares()"));
            uint256 totalShares = bytesToUint256(totalSharesData);
            assert(totalShares == 2);

            // Attempt an upgrade to splitter2, which should succeed.
            (bool upgradeSuccess,) =
                address(proxy).call(abi.encodeWithSignature("upgradeTo(address)", address(splitter2)));
            require(upgradeSuccess);

            address newImpl = proxy.implementation();
            require(newImpl == address(splitter2));
            console.log(newImpl, address(splitter2));

            // Ensure state is the same after upgrade
            (, bytes memory totalShares2Data) = address(proxy).call(abi.encodeWithSignature("totalShares()"));
            uint256 totalShares2 = bytesToUint256(totalShares2Data);
            assert(totalShares2 == totalShares);
            console.log(totalShares2, totalShares);
        }
    }
}
