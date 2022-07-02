//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe { 

    using SafeMathChainlink for uint256;

    mapping(address=>uint256) public addressToAmount;
    address public owner;
    address[] public funders;

    constructor() public {
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10**18;
        require(convertEthToUSD(msg.value) >= minimumUSD, "You need to spend atleast 50 USD.");
        addressToAmount[msg.sender] += msg.value; 
        funders.push(msg.sender);
    }

    function getPrice() public view returns(uint256) {
        AggregatorV3Interface newContract = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = newContract.latestRoundData();
        // ETH/USD rate in 18 digit 
        return uint256(answer * 10000000000);
    }

    function convertEthToUSD(uint256 etherAmount) public view returns(uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountUSD = (ethPrice * etherAmount) / 1000000000000000000;
        // the actual ETH/USD conversation rate, after adjusting the extra 0s.
        return ethAmountUSD;
    }

    modifier onlyOwner {
        require(owner == msg.sender);
        _;
    }

    function withdraw() payable onlyOwner public{
        msg.sender.transfer(address(this).balance);
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmount[funder] = 0;
        }
        funders = new address[](0);
    }


}