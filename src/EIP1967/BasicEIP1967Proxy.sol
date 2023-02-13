// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../Proxy.sol";

/// @title EIP1967Upgrade
/// @author Enrique Ortiz @Evalir
/// @notice UNSAFE CODE, USE AT YOUR OWN RISK.
/// @notice abstract contract that makes a proxy EIP1967 compliant, by adding the corresponding slots
/// and internal setter/getter functions.
abstract contract EIP1967Upgrade {
    bytes32 internal constant EIP1967_IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 internal constant EIP1967_ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    event AdminChanged(address previousAdmin, address newAdmin);
    event Upgraded(address indexed implementation);

    modifier onlyAdmin() {
        address admin = loadAddressSlot(EIP1967_ADMIN_SLOT);
        require(msg.sender == admin, "not owner");
        _;
    }

    function _getImplementation() internal view returns (address) {
        return loadAddressSlot(EIP1967_IMPLEMENTATION_SLOT);
    }

    function _setImplementation(address newImplementation) internal {
        setAddressSlot(EIP1967_IMPLEMENTATION_SLOT, newImplementation);
        emit Upgraded(newImplementation);
    }

    function _changeAdmin(address newAdmin) internal {
        address previousAdmin = loadAddressSlot(EIP1967_ADMIN_SLOT);
        setAddressSlot(EIP1967_ADMIN_SLOT, newAdmin);
        emit AdminChanged(previousAdmin, newAdmin);
    }

    function loadAddressSlot(bytes32 slot) internal view returns (address data) {
        assembly {
            data := sload(slot)
        }
    }

    function setAddressSlot(bytes32 slot, address data) internal {
        assembly {
            sstore(slot, data)
        }
    }
}

/// @title EIP1967Proxy
/// @author Enrique Ortiz @Evalir
/// @notice UNSAFE CODE, USE AT YOUR OWN RISK.
/// A barebones EIP1967 proxy, with all low level functions in place for proxy upgradeability.
/// Needs further extensions for usage. Only provides by itself an override `_implementation()` function
/// to point to the correct storage slot for the implementation.
contract EIP1967Proxy is Proxy, EIP1967Upgrade {
    constructor(address _adminAddress, address _implementationAddress) {
        _changeAdmin(_adminAddress);
        _setImplementation(_implementationAddress);
    }

    function _implementation() internal view override returns (address) {
        return _getImplementation();
    }
}

/// @title BasicEIP1967Proxy
/// @author Enrique Ortiz @Evalir
/// @notice UNSAFE CODE, USE AT YOUR OWN RISK.
/// A simple EIP1967 compliant proxy, which is storage-collision resistant,
/// but still vulnerable to selector hash collision. Made for demonstration purposes.
/// It is also not upgradeable. Upgradeability is provided by a transparent or UUPS proxy.
contract BasicEIP1967Proxy is EIP1967Proxy {
    constructor(address _adminAddress, address _implementationAddress) EIP1967Proxy(_adminAddress, _implementationAddress) {}

    function implementation() external view returns (address) {
        return _implementation();
    }
}
