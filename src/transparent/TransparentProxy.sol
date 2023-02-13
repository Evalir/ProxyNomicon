// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {EIP1967Proxy} from "../EIP1967/BasicEIP1967Proxy.sol";

contract BasicTransparentUpgradeableProxy is EIP1967Proxy {
    bytes32 private constant EIP1967_ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    event AdminChanged(address previousAdmin, address newAdmin);

    constructor(address _admin) {
        bytes32 adminSlot = EIP1967_ADMIN_SLOT;
        assembly {
            sstore(adminSlot, _admin)
        }
    }

    modifier ifAdmin() {
        if (getAdmin() == msg.sender) {
            _;
        } else {
            _fallback();
        }
    }

    function setImplementation(address newImplementation) public ifAdmin {
        setAddressSlot(EIP1967_IMPLEMENTATION_SLOT, newImplementation);
        emit Upgraded(newImplementation);
    }


    function changeAdmin(address newAdmin) public ifAdmin {
        address previousAdmin = loadAddressSlot(EIP1967_ADMIN_SLOT);
        setAddressSlot(EIP1967_ADMIN_SLOT, newAdmin);
        emit AdminChanged(previousAdmin, newAdmin);
    }

    function implementation() external payable ifAdmin returns (address) {
        return _implementation();
    }

    function getAdmin() internal view returns (address) {
        return loadAddressSlot(EIP1967_ADMIN_SLOT);
    }
}
