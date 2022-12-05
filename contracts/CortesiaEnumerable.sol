// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Interfaces/IERC721Enumerable.sol";
import "./Cortesia.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract CortesiaEnumerable is Cortesia, IERC721Enumerable {
    using SafeMath for uint256;
    uint256[] internal allTokens; //tokenIndexes

    mapping(uint256 => uint256) internal indexTokens; //For burn function
    mapping(address => uint256[]) internal ownedTokens; //ownerTokenIndexes
    mapping(uint256 => uint256) internal ownedTokensIndex; //tokenTokenIndexes

    constructor(uint _initialSupply) Cortesia(_initialSupply) {
        for(uint i = 0; i < _initialSupply; i++) {
            ownedTokensIndex[i+1] = i;
            ownedTokens[creator].push(i+1);
            allTokens.push(i+1);
            indexTokens[i+1] = i;
        }
        
        supportedInterfaces[
            this.totalSupply.selector ^
            this.tokenByIndex.selector ^
            this.tokenOfOwnerByIndex.selector
        ] = true;
    }

    function totalSupply() external view returns(uint256) {
        return allTokens.length;
    }

    function tokenByIndex(uint256 _index) 
    external view returns(uint256) {
        require(_index < allTokens.length);
        return allTokens[_index];
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index)
    external view returns(uint256) {
        require(_index < balances[_owner]);
        return ownedTokens[_owner][_index];
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId)
    public {
        address owner = ownerOf(_tokenId);

        require(owner == msg.sender
        || allowance[_tokenId] == msg.sender
        || authorised[owner][msg.sender]
        );

        require(owner == _from);
        require(_to != address(0));

        emit Transfer(_from, _to, _tokenId);

        owners[_tokenId] = _to;
        balances[_from]--;
        balances[_to]++;

        if(allowance[_tokenId] != address(0)) {
            delete allowance[_tokenId];
        }

        uint oldIndex = ownedTokensIndex[_tokenId];

        if(oldIndex != ownedTokens[_from].length - 1) {
            ownedTokens[_from][oldIndex] = 
            ownedTokens[_from][ownedTokens[_from].length - 1];

            ownedTokensIndex[ownedTokens[_from][oldIndex]] = oldIndex;
        }

        ownedTokens[_from].pop(); // reduce ownedTokens length
        ownedTokensIndex[_tokenId] = ownedTokens[_to].length;
        ownedTokens[_to].push(_tokenId);
    }

    function _issueTokens(uint256 _extraTokens) public{
        require(msg.sender == creator);
        balances[msg.sender] = balances[msg.sender].add(_extraTokens);

        uint256 newId;

        for(uint i = 0; i < _extraTokens; i++) {
            newId = maxId.add(i).add(1);
            ownedTokensIndex[newId] = ownedTokens[creator].length;
            ownedTokens[creator].push(newId);

            indexTokens[newId] = allTokens.length;
            allTokens.push(newId);

            emit Transfer(address(0), creator, newId);
        }
        maxId = maxId.add(_extraTokens);
    }

    function _burnToken(uint256 _tokenId) external{
        address owner = ownerOf(_tokenId);
        require(owner == msg.sender
            || allowance[_tokenId] == msg.sender
            || authorised[owner][msg.sender]
        );

        burned[_tokenId] = true;
        balances[owner]--;
        emit Transfer(owner, address(0), _tokenId);

        uint oldIndex = ownedTokensIndex[_tokenId];
        if(oldIndex != ownedTokens[owner].length - 1) {
            ownedTokens[owner][oldIndex] = 
            ownedTokens[owner][ownedTokens[owner].length - 1];
            ownedTokensIndex[ownedTokens[owner][oldIndex]] = oldIndex;
        }

        ownedTokens[owner].pop();        
        delete ownedTokensIndex[_tokenId];

        oldIndex = indexTokens[_tokenId];
        if(oldIndex != allTokens.length - 1) {
            allTokens[oldIndex] = allTokens[allTokens.length - 1];
        }
        allTokens.pop();
    }
}