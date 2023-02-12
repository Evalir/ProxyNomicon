// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../Proxy.sol";

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
