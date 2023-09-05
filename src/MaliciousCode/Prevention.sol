// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Prevention {
    Bar public bar;

    constructor() {
        bar = new Bar();
    }
}

contract Bar {
    event Log(string message);

    function log() public {
        emit Log("Bar was called");
    }
}

// Initialize a new contract inside the constructor
// Make the address of external contract public so that the code of the external contract can be reviewed
