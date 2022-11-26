// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./utils/CheckERC165.sol";
import "./Interfaces/IERC721.sol";
import "./Interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Cortesia is IERC721, CheckerERC165{
    using SafeMath for uint256;

    address internal creator;
    uint256 internal maxId;

    mapping(address => uint256) internal balances;

    mapping(uint256 => bool) internal burned;
    
    mapping(uint256 => address) internal owners;
    //approve
    mapping(uint256 => address) internal allowance;
    //operators
    mapping(address => mapping(address => bool)) internal authorised;



    constructor(uint _initialSupply) CheckerERC165() {
        creator = msg.sender;
        balances[msg.sender] = _initialSupply;
        maxId = _initialSupply;

        supportedInterfaces[
            this.balanceOf.selector ^ 
            this.ownerOf.selector ^
            bytes4(keccak256("safeTransferFrom(address, address, uint256)")) ^
            bytes4(keccak256("safeTransferFrom(address, address, uint256, bytes)")) ^
            this.transferFrom.selector ^
            this.approve.selector ^
            this.setApprovalForAll.selector ^
            this.getApproved.selector ^
            this.isApprovedForAll.selector
        ] = true;
    } 

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        address owner = ownerOf(_tokenId);
        require(owner == msg.sender
            || allowance[_tokenId] == msg.sender
            || authorised[owner][msg.sender]);
        require(owner == _from);
        require(_to != address(0));

        emit Transfer(_from, _to, _tokenId);

        owners[_tokenId] = _to;
        balances[_from]--;
        balances[_to]++;

        if(allowance[_tokenId] != address(0)) {
            delete allowance[_tokenId];
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public {
        transferFrom(_from, _to, _tokenId);
        uint32 size;
        assembly {
            size:=extcodesize(_to)
        }
        if(size > 0) {
            IERC721Receiver receiver = IERC721Receiver(_to);
            require(receiver.onERC721Received(msg.sender, _from, _tokenId, data)
            ==
            bytes4(keccak256("onERC721Received(address, address, uint256, bytes)")));
        }
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function approve(address _approved, uint256 _tokenId) external {
        address owner = ownerOf(_tokenId);
        require(owner == msg.sender || authorised[owner][msg.sender]);
        emit Approval(owner, _approved, _tokenId);
        allowance[_tokenId] = _approved;
    }

    function getApproved(uint256 _tokenId) external view returns(address) {
        require(isValidToken(_tokenId));
        return allowance[_tokenId];
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        emit ApprovalForAll(msg.sender, _operator, _approved);
        authorised[msg.sender][_operator] = _approved;
    }

    function isApprovedForAll(address _owner, address _operator) external view returns(bool) {
        return authorised[_owner][_operator];
    }

    function balanceOf(address _owner) external view returns(uint256 balance) {
        return balances[_owner];
    }

    function isValidToken(uint256 _tokenId) internal view returns(bool) {
        return _tokenId != 0 && _tokenId <= maxId && !burned[_tokenId];
    }

    function ownerOf(uint256 _tokenId) public view returns(address) {
        require(isValidToken(_tokenId), "Token is not valid");
        if(owners[_tokenId] != address(0)) {
            return owners[_tokenId];
        }
        else {
            return creator;
        }
    }

    function issueTokens(uint256 _extraTokens) public{
        require(msg.sender == creator, "You are not creator");
        balances[msg.sender] = balances[msg.sender].add(_extraTokens);

        for(uint i = maxId.add(1); i <= maxId.add(_extraTokens); i++) {
            emit Transfer(address(0), creator, i);
        }

        maxId += _extraTokens;
    }

    function burnToken(uint256 _tokenId) external{
        address owner = ownerOf(_tokenId);
        require(owner == msg.sender
            || allowance[_tokenId] == msg.sender
            || authorised[owner][msg.sender]
        );
        burned[_tokenId] = true;
        balances[owner]--;

        emit Transfer(owner, address(0), _tokenId);
    }
}