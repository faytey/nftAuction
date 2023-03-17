//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract FitexAuction{
    address public owner;
// Current NFTs supported

    IERC721 public Fitex;
    bool public isOn;
    uint public id;
    address highestBidder;
    uint highestBid;
    
    struct auctionDetails{
        uint startTime;
        uint startBidAmount;
        uint endTime;
        uint id;
    }
    mapping(address => uint256) private _balances;
mapping(address => auctionDetails[]) public owners;
mapping(uint => auctionDetails) public ids;
mapping(address => uint[]) public bid;

constructor(){
Fitex = IERC721(0xD94f85eE6F087C2b0366C0CBb7b6091d19152047);
id = 0;
owner = msg.sender;
}

function createAuction(uint token_id) public returns(uint _id){
    require(Fitex.balanceOf(msg.sender) > 0, "You do not have the supported NFT to bid");
    Fitex.transferFrom(msg.sender, address(this), token_id);
    auctionDetails[] storage auction = owners[msg.sender];
    auctionDetails memory create;
    // create.id = uint(ids[token_id]);
    create.startTime = block.timestamp;
    create.startBidAmount = 5000 gwei;
    create.endTime = (create.startTime + 3600);
    _id = id++;
    create.id = _id;
    auction.push(create);
    isOn = true;
}

// function bidAmount(uint _amount) private {
//     auctionDetails memory amount;
//     amount.startBidAmount = _amount;
//     bids.push(_amount);
// }

function bidForNft(uint auctionId, uint amount) external payable {
    auctionDetails memory bidding;
    uint256[] storage bids = bid[msg.sender];
    require(block.timestamp < bidding.endTime, "Auction ended!!!");
    require(msg.sender != address(0), "Address cannot be address(0)");
    require(amount >= bidding.startBidAmount, "Kindly bid higher ");
    payable(address(this)).transfer(amount);
    if(amount > highestBid){
    highestBid = amount;
    highestBidder = msg.sender;
    }
    bids.push(amount);
}
function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(Fitex.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        // Check that tokenId was not transferred by `_beforeTokenTransfer` hook
        require(Fitex.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");

        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;
        }
    }
function endAuction(uint tokenId) private {
    auctionDetails memory ending;
    require(block.timestamp >= ending.endTime, "Auction still ongoing");
    if(highestBid == 0){
        _transfer(address(this), owner, tokenId);
    }else{
        _transfer(address(this), highestBidder, tokenId);
        payable(owner).transfer(highestBid / (uint(10) /uint(100)));
    }
}

function withdraw() external payable {
    require(address(this).balance >= 0, "Not enough balance");
    payable(owner).transfer(address(this).balance);
}
}