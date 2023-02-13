// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../Proxy.sol";

/// @title BasicUpgradeableProxy
/// @author Enrique Ortiz @Evalir
/// @notice UNSAFE CODE, USE AT YOUR OWN RISK.
/// A simple upgradeable proxy, which delegates calls to the implementation.
/// This proxy is broken and only made for demonstration purposes.
/// It is NOT storage collision resistant, nor selector collision resistant.
/// Therefore, it is easily hackable. Such an example is provided in the tests for this
/// proxy.
contract BasicUpgradeableProxy is Proxy {
    address public implementation;
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    function setImplementation(address newImplementation) public onlyOwner {
        implementation = newImplementation;
    }

    function _implementation() internal view override returns (address) {
        return implementation;
    }

    function changeOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}
