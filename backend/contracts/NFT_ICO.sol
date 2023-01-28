// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable{
    uint256 public constant tokenPrice = 0.001 ether;
    uint256 public constant tokensPerNFT = 10 * 10**18;
    uint256 public maxTotalSupply = 10000 * 10**18;

    ICryptoDevs CryptoDevsNFT;

    mapping(uint256 => bool) tokenIdClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto dev token", "CD"){
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    function mint(uint256 amount) public payable{
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Please send more ETH");
        uint256 amountWithDecimals = amount * 10 **18;
        require((totalSupply() + amountWithDecimals) <= maxTotalSupply, "Exceeds total supply");
        _mint(msg.sender, amountWithDecimals);

    }

    function claim() public{
        address sender = msg.sender;
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        require(balance > 0, "You don't own NFT");
        uint256 amount = 0;
        for(uint256 i =0; i< balance; i++){
            uint256 tokenID = CryptoDevsNFT.tokenOfOwnerByIndex(sender,i);
            if(!tokenIdClaimed[tokenID]){
                amount += 1;
                tokenIdClaimed[tokenID] =true;
            }
        }
        require(amount > 0, "You have already claimed for all NFTs");
        _mint(msg.sender, amount*tokensPerNFT); 
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "Nothing to withdraw, contract balance empty");
        
        address _owner = owner();
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
      }

    receive() external payable {}
    fallback() external payable {}

}
