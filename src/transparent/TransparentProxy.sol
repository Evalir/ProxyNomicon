// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {EIP1967Proxy} from "../EIP1967/BasicEIP1967Proxy.sol";

/// @title BasicTransparentUpgradeableProxy
/// @author Enrique Ortiz @Evalir
/// @notice UNSAFE CODE, USE AT YOUR OWN RISK.
/// @notice A basic, transparent upgradeable proxy.
/// Storage and selector collision resistant.
/// Forwards all calls directly to its underlying implementation if the caller is not the
// admin.
/// Contains all the upgrade logic needed, which simplifies the overall structure of the
/// proxy.
/// A bit more expensive to deploy than an UUPS proxy, but much simpler in complexity.
contract BasicTransparentUpgradeableProxy is EIP1967Proxy {
    constructor(address _adminAddress, address _implementationAddress, bytes memory data)
        EIP1967Proxy(_adminAddress, _implementationAddress, data)
    {}

    modifier ifAdmin() {
        if (getAdmin() == msg.sender) {
            _;
        } else {
            _fallback();
        }
    }

    function upgradeTo(address newImplementation) external payable ifAdmin {
        _setImplementation(newImplementation);
    }

    function implementation() external payable ifAdmin returns (address) {
        return _implementation();
    }

    function changeAdmin(address newAdmin) public ifAdmin {
        _changeAdmin(newAdmin);
    }

    function getAdmin() internal view returns (address) {
        return loadAddressSlot(EIP1967_ADMIN_SLOT);
    }

    function _beforeFallback() internal virtual override {
        require(msg.sender != getAdmin(), "TransparentUpgradeableProxy: admin cannot fallback to proxy target");
        super._beforeFallback();
    }
}
