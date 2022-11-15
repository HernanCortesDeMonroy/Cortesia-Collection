// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

contract CheckerERC165 is IERC165{
    mapping(bytes4 => bool) internal supportedInterfaces;

    constructor() {
        supportedInterfaces[this.supportsInterface.selector] = true;
    }

    function supportsInterface(bytes4 interfaceId) external view returns(bool) {
        return supportedInterfaces[interfaceId];
    }
}