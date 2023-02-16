// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./IERC1822.sol";
import {EIP1967Proxy, EIP1967Upgrade} from "../EIP1967/BasicEIP1967Proxy.sol";

/// @title UUPSProxy
/// @author Enrique Ortiz @Evalir
/// @notice UNSAFE CODE, USE AT YOUR OWN RISK.
/// @notice barebones UUPS proxy. Enough logic added for owner upgradeability.
/// Note that *none* of the multiple safety checks other than the necessary ones
/// are in place on this version of this proxy.
/// This proxy could stop being upgradeable if it upgrades to a contract that has
/// no upgrade mechanism.
/// This proxy is also brickable if the implementation contract allows DELEGATECALLs
/// to arbitrary addresses, allowing a SELFDESTRUCT to be called.
contract UUPSProxy is EIP1967Proxy {
    constructor(address _adminAddress, address _implementationAddress, bytes memory data)
        EIP1967Proxy(_adminAddress, _implementationAddress, data)
    {}
}

/// @title UUPSUpgradeable
/// @author Enrique Ortiz Pichardo @Evalir
/// @notice Abstract contract that defines the functionality that the implementation
/// contract should implement to become UUPS compliant and upgradeable.
/// It is extremely important that _authorizeUpgrade is overriden and access control is added,
/// Or anyone could upgrade the contract.
/// Note that in this implementation IERC1822Proxiable is unused, as its supposed to be the security mechanism
/// to ensure that future upgrades are UUPS compliant, but this mechanism is not implemented here.
abstract contract UUPSUpgradeable is IERC1822Proxiable, EIP1967Upgrade {
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(__self != address(this), "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: should not be called through delegatecall");
        _;
    }

    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return EIP1967_IMPLEMENTATION_SLOT;
    }

    function upgradeTo(address newImplementation) public virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _setImplementation(newImplementation);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;

    function implementation() external view returns (address) {
        return _getImplementation();
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        _changeAdmin(newAdmin);
    }
}
