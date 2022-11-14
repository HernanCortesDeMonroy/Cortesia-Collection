pragma solidity ^0.8.16;

import "@openzeppelin/contracts/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CortesiaNFT is ERC721Enumarable, Ownable {
    using Strings for uint256;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.05 ether;
    uint256 presaleCost = 0.03 ether;
    uint256 public maxSupply = 100;
    uint256 public maxMintAmount = 5;
    bool public paused = false;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public presaleWallets;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        mint(msg.sender, 20);
    }

    function _baseURI() internal view virtual override returns(string memory) {
        return baseURI;
    }

    function mint(address _to, uint256 _minAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_minAmount > 0);
        require(_minAmount <= maxMintAmount);

        if(msg.sender != owner()) {
            if(whitelisted[msg.sender] != true) {
                if(presaleWallets[msg.sender] != true) {
                    require(msg.value >= cost * _minAmount);
                } else {
                    require(msg.value >= presaleCost * _minAmount);
                }
            }
        }
        for(uint256 i = 1; i <= _minAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256 memory tokenIds = new uint256[](ownerTokenAmount);
        for (uint256 i; i< ownerTokenAmount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns(string memory) {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(
            currentBaseURI,
            tokenId.toString(),
            baseExtension
            )
        ) : "";
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setPresaleCost(uint256 _newCost) public onlyOwner {
        presaleCost = _newCost;
    }
    
    function setMaxMintAmount(uint256 _newMaxMintAmount) onlyOwner {
        maxMintAmount = _newMaxMintAmount;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function whitelistedUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    function removeWhitelistedUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function addPresaleUser(address _user) public onlyOwner {
        presaleWallets[_user] = true;
    }

    function add100PresaleUsers(address[100] memory _users) public onlyOnwer {
        for(uint256 i = 0; i < 2; i++) {
            presaleWallets[_users[i]] = true;
        }
    }

    function removePresaleUser(address _user) public onlyOwner {
        (bool success, ) = payable(msg.sender).call {
            value: address(this).balance
        }("");
        require(success);
    }
}