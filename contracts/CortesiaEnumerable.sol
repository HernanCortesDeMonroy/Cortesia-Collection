// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Interfaces/IERC721Enumerable.sol";
import "./Cortesia.sol";

contract CortesiaEnumerable is Cortesia, IERC721Enumerable {
    uint256[] internal tokenIndexes;

    mapping(uint256 => uint256) internal indexTokens; //For burn function
    mapping(address => uint256[]) internal ownerTokenIndexes;
    mapping(uint256 => uint256) internal tokenTokenIndexes;

    constructor() {
        supportedInterfaces[
            this.totalSupply.selector ^
            this.tokenByIndex.selector ^
            this.tokenOfOwnerByIndex
        ]
    }
}