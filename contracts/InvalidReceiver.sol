// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Interfaces/IERC721Receiver.sol";

contract InvalidReceiver is IERC721Receiver {
    function onERC721Received(
    address operator,
    address from, 
    uint256 tokenId, 
    bytes memory data
    ) external returns(bytes4){
        return bytes4(keccak256("Invalid"));
    }
}