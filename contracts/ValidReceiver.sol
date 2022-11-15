// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Interfaces/IERC721Receiver.sol";

contract ValidReceiver is IERC721Receiver {
    function onERC721Received(
    address _operator, 
    address _from,
    uint256 _tokenId, 
    bytes memory _data
    ) external returns(bytes4) {
        return bytes4(keccak256("onERC721Received(address, address, uint256, bytes)"));
    }
}