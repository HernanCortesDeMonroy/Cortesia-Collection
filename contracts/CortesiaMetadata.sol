// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "./Cortesia.sol";
import "./Interfaces/IERC721Metadata.sol";

contract CortesiaMetadata is IERC721Metadata, Cortesia {
    string private __name;
    string private __symbol;
    bytes private __uriBase;

    constructor(
        uint _initialSupply, 
        string memory _name, 
        string memory _symbol, 
        string memory _uriBase
        ) Cortesia(_initialSupply) {
            __name = _name;
            __symbol = _symbol;
            __uriBase = bytes(_uriBase);

            supportedInterfaces[
                this.name.selector ^
                this.symbol.selector ^ 
                this.tokenURI.selector
            ] = true;
        } 
    
    function name() external view returns(string memory _name) {
        _name = __name;
    }

    function symbol() external view returns(string memory _symbol) {
        _symbol = __symbol;
    }

    function tokenURI(uint256 _tokenId) external view returns(string memory) {
        require(isValidToken(_tokenId));

        uint maxLength = 78;
        bytes memory reversed = new bytes(maxLength);
        uint i = 0;

        while(_tokenId != 0) {
            uint remainder = _tokenId % 10;
            _tokenId /= 10;
            reversed[i++] = bytes1(uint8(48 + remainder));
        }

        bytes memory s = new bytes(__uriBase.length + 1);
        uint j;

        for(j = 0; j < __uriBase.length; j++) {
            s[j] = __uriBase[j];
        }

        for(j = 0; j < i; j++) {
            s[j + __uriBase.length] = reversed[i - 1 - j];
        }

        return string(s);
    }
    
}