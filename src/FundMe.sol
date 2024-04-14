// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    // Type Declarations
    using PriceConverter for uint256;

    uint256 public minimumUSD = 5e18;
    // 2425 gas

    // Storage Variables!
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;

    // Could we make this constant?  /* hint: no! We should make it immutable! */
    address private immutable i_owner;
    // 2552 gas
    // 417 gas
    uint256 public constant MINIMUM_USD = 5 * 10 ** 18;

    // 325 gas
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
        i_owner = msg.sender;
    }

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent $5
        // 1.How do we send ETH to this Contract?
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 funderLength = s_funders.length;
        // save it on memory cheaper then Storage 
        for (
            uint256 funderIndex = 0;
            funderIndex < funderLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        // For Loop
        // [ 1, 2, 3, 4 ] elements
        //   0  1  2  3   indexes
        // For (/* Starting index; ending index; Step amount */)
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            // looping and save it in Storage >>address[] private s_funders make So Expensive
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        // reset the array
        // withdraw the funds
        s_funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);

        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    // modifier onlyOwner() {
    //     require(msg.sender == i_owner, "Sender is not owner");
    //     _;
    // }

    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

    /**
     * View / Pure Functions ( Getters )
     */
    // reason?>> check to populated >> FundMeTest.t.sol edit
    function getAdressToAmountFunded(
        address fundingAdress
    ) public view returns (uint256) {
        return s_addressToAmountFunded[fundingAdress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
        // }

        // function getNumFunders() external view returns (uint256) {
        //     return s_funders.length;
        // }

        // function getVersion() external view returns (uint256) {
        //     return s_priceFeed.version();
        // }

        // function getPriceFeed() external view returns (AggregatorV3Interface) {
        //     return s_priceFeed;
        // }
    }

    // Concepts we didn't cover yet (will cover in later sections)
    // 1. Enum
    // 2. Events
    // 3. Try / Catch
    // 4. Function Selector
    // 5. abi.encode / decode
    // 6. Hash with keccak256
    // 7. Yul / Assembly

    // I use this function to call it on FundMeTest.t.sol by using startingOwnerBalance = fundMe.getOwner() but turn i_owner to private NOT PUBLIC >>address private immutable i_owner;
    function getOwner() external view returns (address) {
        return i_owner;
    }

    /** Getter Functions */

    /**
     * @notice Gets the amount that an address has funded
     *  @param fundingAddress the address of the funder
     *  @return the amount funded
     */
}
