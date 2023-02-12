// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

abstract contract Initializable {
    uint8 private _initialized;

    event Initialized(uint8 state);

    modifier onlyInitialized() {
        require(_initialized > 0, "not initialized");
        _;
    }

    modifier onlyUninitialized() {
        require(_initialized == 0, "already initialized");
        _;
    }

    function freezeImplementation() public virtual {
        require(_initialized == 0, "already initialized");
        _initialized = type(uint8).max;
        emit Initialized(type(uint8).max);
    }

    function initialized() internal virtual {
        require(_initialized == 0, "already initialized");
        _initialized = 1;
        emit Initialized(1);
    }

    function isInitialized() public view returns (uint8) {
        return _initialized;
    }
}
