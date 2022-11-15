// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./IERC165.sol";

interface IERC721{

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns(uint256 balance);

    function ownerOf(uint256 tokenId) external view returns(address owner);

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) external;

    function transferFrom (
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function approveForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns(address operator);

    function isApprovedForAll(address owner, address operator) external view returns(bool);

}


