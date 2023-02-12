// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import "../Proxy.sol";

contract BasicEIP1967Proxy is Proxy {
    bytes32 private constant EIP1967_IMPLEMENTATION_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 private constant EIP1967_ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);

    constructor(address _admin) {
        bytes32 adminSlot = EIP1967_ADMIN_SLOT;
        assembly {
            sstore(adminSlot, _admin)
        }
    }

    modifier onlyAdmin() {
        address admin = loadAddressSlot(EIP1967_ADMIN_SLOT);
        require(msg.sender == admin, "not owner");
        _;
    }

    function setImplementation(address newImplementation) public onlyAdmin {
        setAddressSlot(EIP1967_IMPLEMENTATION_SLOT, newImplementation);
        emit Upgraded(newImplementation);
    }

    function _implementation() internal view override returns (address implementation) {
        return loadAddressSlot(EIP1967_IMPLEMENTATION_SLOT);
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
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
