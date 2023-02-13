// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "./IERC1822.sol";
import {EIP1967Proxy, EIP1967Upgradeable} from "../EIP1967/BasicEIP1967Proxy.sol";

contract UUPSProxy is EIP1967Proxy {
    bytes32 private constant EIP1967_ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    event AdminChanged(address previousAdmin, address newAdmin);

    constructor(address _admin, address implementation) {
        bytes32 adminSlot = EIP1967_ADMIN_SLOT;
        assembly {
            sstore(adminSlot, _admin)
        }
        _setImplementation(implementation);
    }

    function implementation() external view returns (address) {
        return _getImplementation();
    }

    modifier onlyAdmin() {
        address admin = loadAddressSlot(EIP1967_ADMIN_SLOT);
        require(msg.sender == admin, "not owner");
        _;
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        address previousAdmin = loadAddressSlot(EIP1967_ADMIN_SLOT);
        setAddressSlot(EIP1967_ADMIN_SLOT, newAdmin);
        emit AdminChanged(previousAdmin, newAdmin);
    }
}

abstract contract UUPSUpgradeable is IERC1822Proxiable, EIP1967Upgradeable {
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(__self != address(this), "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function proxiableUUID() external view virtual override returns (bytes32) {
        return EIP1967_IMPLEMENTATION_SLOT;
    }

    function upgradeTo(address newImplementation) public virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _setImplementation(newImplementation);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
}
