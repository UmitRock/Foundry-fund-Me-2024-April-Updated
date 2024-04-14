// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    // prank Cheatcode EvmError: OutOfFunds

    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000 wei $ 339.03 in 2024 Apr 7 3pm
    uint256 constant STARTING_BALANCE = 10 ether; // fake deal Cheatcode address make it 10ETH
    uint256 constant GAS_PRICE = 2; // Exp>> gas price 2

    function setUp() external {
        // fundme->us calling=> FundMeText Deploying=> FundMe
        // onwer FundMeTest not fundMe solve address(this)
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        console.log("We are live");
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        console.log(fundMe.getOwner());
        console.log(address(this));
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
        // test/mocks/MockV3Aggregator.sol >>uint256 public constant version = 4;
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert("You need to spend more ETH!"); // the next line, should revert!
        // assert(this tx fails/reverts)
        fundMe.fund(); // send 0 value >> less then minmum vale 5$ this line must be fails in transaction but this function is gonna revert >> vm.expectRevert
    }

    function testFundUpdatesFundedDataStructure() public {
        // use fake address>> makeAddr
        vm.prank(USER); // the next TX will be sent by USER makrAddr

        fundMe.fund{value: SEND_VALUE}(); // send more then $5
        // funder to s_funder, addressToAmountFunded to s_addressToAmountFunded and make turn them private in FundME.sol update it
        // getAdressToAmountFunded came from FundME.sol here test it
        uint256 amountFunded = fundMe.getAdressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    //     [PASS] testFundUpdatesFundedDataStructure() (gas: 99709)
    // Traces:
    //   [2853994] FundMeTest::setUp()
    //     ├─ [1421382] → new DeployFundMe@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    //     │   └─ ← 6989 bytes of code
    //     ├─ [1390960] DeployFundMe::run()
    //     │   ├─ [906303] → new HelperConfig@0x104fBc016F4bb334D775a19E8A6510109AC63E00
    //     │   │   ├─ [0] VM::startBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   ├─ [377461] → new MockV3Aggregator@0x90193C961A926261B756D1E5bb255e67ff9498A1
    //     │   │   │   └─ ← 1108 bytes of code
    //     │   │   ├─ [0] VM::stopBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   └─ ← 2241 bytes of code
    //     │   ├─ [359] HelperConfig::activeNetworkConfig() [staticcall]
    //     │   │   └─ ← MockV3Aggregator: [0x90193C961A926261B756D1E5bb255e67ff9498A1]
    //     │   ├─ [0] VM::startBroadcast()
    //     │   │   └─ ← ()
    //     │   ├─ [417707] → new FundMe@0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
    //     │   │   └─ ← 1864 bytes of code
    //     │   ├─ [0] VM::stopBroadcast()
    //     │   │   └─ ← ()
    //     │   └─ ← FundMe: [0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496]
    //     ├─ [0] VM::deal(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], 10000000000000000000 [1e19])
    //     │   └─ ← ()
    //     └─ ← ()

    //   [99709] FundMeTest::testFundUpdatesFundedDataStructure()
    //     ├─ [0] VM::prank(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D])
    //     │   └─ ← ()
    //     ├─ [81332] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [8993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [491] FundMe::getAdressToAmountFunded(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D]) [staticcall]
    //     │   └─ ← 100000000000000000 [1e17]
    //     ├─ [0] VM::assertEq(100000000000000000 [1e17], 100000000000000000 [1e17]) [staticcall]
    //     │   └─ ← ()
    //     └─ ← ()
    //**************************************************** */

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    // test fund() function on FundMe.sol
    function testAddFunderToArrayOfFunder() public funded {
        // instead of
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        // use after public funded modifier

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // instead of
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        // use after public funded modifier
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    //     [PASS] testOnlyOwnerCanWithdraw() (gas: 99942)
    // Traces:
    //   [2853994] FundMeTest::setUp()
    //     ├─ [1421382] → new DeployFundMe@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    //     │   └─ ← 6989 bytes of code
    //     ├─ [1390960] DeployFundMe::run()
    //     │   ├─ [906303] → new HelperConfig@0x104fBc016F4bb334D775a19E8A6510109AC63E00
    //     │   │   ├─ [0] VM::startBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   ├─ [377461] → new MockV3Aggregator@0x90193C961A926261B756D1E5bb255e67ff9498A1
    //     │   │   │   └─ ← 1108 bytes of code
    //     │   │   ├─ [0] VM::stopBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   └─ ← 2241 bytes of code
    //     │   ├─ [359] HelperConfig::activeNetworkConfig() [staticcall]
    //     │   │   └─ ← MockV3Aggregator: [0x90193C961A926261B756D1E5bb255e67ff9498A1]
    //     │   ├─ [0] VM::startBroadcast()
    //     │   │   └─ ← ()
    //     │   ├─ [417707] → new FundMe@0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
    //     │   │   └─ ← 1864 bytes of code
    //     │   ├─ [0] VM::stopBroadcast()
    //     │   │   └─ ← ()
    //     │   └─ ← FundMe: [0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496]
    //     ├─ [0] VM::deal(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], 10000000000000000000 [1e19])
    //     │   └─ ← ()
    //     └─ ← ()

    //   [99942] FundMeTest::testOnlyOwnerCanWithdraw()
    //     ├─ [0] VM::prank(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D])
    //     │   └─ ← ()
    //     ├─ [81332] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [8993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D])
    //     │   └─ ← ()
    //     ├─ [0] VM::expectRevert(custom error f4844814:)
    //     │   └─ ← ()
    //     ├─ [270] FundMe::withdraw()
    //     │   └─ ← FundMe__NotOwner()
    //     └─ ← ()
    //****************************************** */

    function testWithdrawWithASingleFunder() public funded {
        // Introduce Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance; // fundMe = FundMe.sol
        uint256 startingFundMeBalance = address(fundMe).balance; // fundMe = FundMe.sol

        // Introduce Act
        // uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); // only onwner can withdraw
        fundMe.withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log("Gas Used: ", gasUsed);

        // Introduce Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundMeBalance
        );
    }

    //     [PASS] testWithdrawWithASingleFunder() (gas: 85032)
    // Traces:
    //   [2851994] FundMeTest::setUp()
    //     ├─ [1420382] → new DeployFundMe@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    //     │   └─ ← 6984 bytes of code
    //     ├─ [1389960] DeployFundMe::run()
    //     │   ├─ [906303] → new HelperConfig@0x104fBc016F4bb334D775a19E8A6510109AC63E00
    //     │   │   ├─ [0] VM::startBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   ├─ [377461] → new MockV3Aggregator@0x90193C961A926261B756D1E5bb255e67ff9498A1
    //     │   │   │   └─ ← 1108 bytes of code
    //     │   │   ├─ [0] VM::stopBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   └─ ← 2241 bytes of code
    //     │   ├─ [359] HelperConfig::activeNetworkConfig() [staticcall]
    //     │   │   └─ ← MockV3Aggregator: [0x90193C961A926261B756D1E5bb255e67ff9498A1]
    //     │   ├─ [0] VM::startBroadcast()
    //     │   │   └─ ← ()
    //     │   ├─ [416707] → new FundMe@0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
    //     │   │   └─ ← 1859 bytes of code
    //     │   ├─ [0] VM::stopBroadcast()
    //     │   │   └─ ← ()
    //     │   └─ ← FundMe: [0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496]
    //     ├─ [0] VM::deal(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], 10000000000000000000 [1e19])
    //     │   └─ ← ()
    //     └─ ← ()

    //   [89245] FundMeTest::testWithdrawWithASingleFunder()
    //     ├─ [0] VM::prank(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D])
    //     │   └─ ← ()
    //     ├─ [81354] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [8993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     ├─ [0] VM::prank(DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38])
    //     │   └─ ← ()
    //     ├─ [8526] FundMe::withdraw()
    //     │   ├─ [0] DefaultSender::fallback{value: 100000000000000000}()
    //     │   │   └─ ← ()
    //     │   └─ ← ()
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     ├─ [0] VM::assertEq(0, 0) [staticcall]
    //     │   └─ ← ()
    //     ├─ [0] VM::assertEq(79228162514364337593543950335 [7.922e28], 79228162514364337593543950335 [7.922e28]) [staticcall]
    //     │   └─ ← ()
    //     └─ ← ()

    function testWithdrawMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // address(0),addres(1)...
            hoax(address(i), SEND_VALUE);
            // fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        } //less then

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert phase
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    //     [PASS] testWithdrawMultipleFunders() (gas: 487584)
    // Traces:
    //   [2852027] FundMeTest::setUp()
    //     ├─ [1420382] → new DeployFundMe@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    //     │   └─ ← 6984 bytes of code
    //     ├─ [1389960] DeployFundMe::run()
    //     │   ├─ [906303] → new HelperConfig@0x104fBc016F4bb334D775a19E8A6510109AC63E00
    //     │   │   ├─ [0] VM::startBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   ├─ [377461] → new MockV3Aggregator@0x90193C961A926261B756D1E5bb255e67ff9498A1
    //     │   │   │   └─ ← 1108 bytes of code
    //     │   │   ├─ [0] VM::stopBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   └─ ← 2241 bytes of code
    //     │   ├─ [359] HelperConfig::activeNetworkConfig() [staticcall]
    //     │   │   └─ ← MockV3Aggregator: [0x90193C961A926261B756D1E5bb255e67ff9498A1]
    //     │   ├─ [0] VM::startBroadcast()
    //     │   │   └─ ← ()
    //     │   ├─ [416707] → new FundMe@0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
    //     │   │   └─ ← 1859 bytes of code
    //     │   ├─ [0] VM::stopBroadcast()
    //     │   │   └─ ← ()
    //     │   └─ ← FundMe: [0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496]
    //     ├─ [0] VM::deal(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], 10000000000000000000 [1e19])
    //     │   └─ ← ()
    //     └─ ← ()

    //   [491797] FundMeTest::testWithdrawMultipleFunders()
    //     ├─ [0] VM::prank(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D])
    //     │   └─ ← ()
    //     ├─ [81354] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [8993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000001, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000001)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000002, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000002)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000003, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000003)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000004, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000004)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000005, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000005)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000006, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000006)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000007, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000007)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000008, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000008)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000009, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000009)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     ├─ [0] VM::startPrank(DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38])
    //     │   └─ ← ()
    //     ├─ [15699] FundMe::withdraw()
    //     │   ├─ [0] DefaultSender::fallback{value: 1000000000000000000}()
    //     │   │   └─ ← ()
    //     │   └─ ← ()
    //     ├─ [0] VM::stopPrank()
    //     │   └─ ← ()
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     └─ ← ()

    function testWithdrawMultipleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address
            // vm.deal new address
            // address(0),addres(1)...
            hoax(address(i), SEND_VALUE);
            // fund the fundMe
            fundMe.fund{value: SEND_VALUE}();
        } //less then

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert phase
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
    //     [PASS] testWithdrawMultipleFunders() (gas: 487584)
    // Traces:
    //   [2852027] FundMeTest::setUp()
    //     ├─ [1420382] → new DeployFundMe@0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f
    //     │   └─ ← 6984 bytes of code
    //     ├─ [1389960] DeployFundMe::run()
    //     │   ├─ [906303] → new HelperConfig@0x104fBc016F4bb334D775a19E8A6510109AC63E00
    //     │   │   ├─ [0] VM::startBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   ├─ [377461] → new MockV3Aggregator@0x90193C961A926261B756D1E5bb255e67ff9498A1
    //     │   │   │   └─ ← 1108 bytes of code
    //     │   │   ├─ [0] VM::stopBroadcast()
    //     │   │   │   └─ ← ()
    //     │   │   └─ ← 2241 bytes of code
    //     │   ├─ [359] HelperConfig::activeNetworkConfig() [staticcall]
    //     │   │   └─ ← MockV3Aggregator: [0x90193C961A926261B756D1E5bb255e67ff9498A1]
    //     │   ├─ [0] VM::startBroadcast()
    //     │   │   └─ ← ()
    //     │   ├─ [416707] → new FundMe@0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496
    //     │   │   └─ ← 1859 bytes of code
    //     │   ├─ [0] VM::stopBroadcast()
    //     │   │   └─ ← ()
    //     │   └─ ← FundMe: [0xA8452Ec99ce0C64f20701dB7dD3abDb607c00496]
    //     ├─ [0] VM::deal(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D], 10000000000000000000 [1e19])
    //     │   └─ ← ()
    //     └─ ← ()

    //   [491797] FundMeTest::testWithdrawMultipleFunders()
    //     ├─ [0] VM::prank(user: [0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D])
    //     │   └─ ← ()
    //     ├─ [81354] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [8993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000001, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000001)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000002, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000002)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000003, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000003)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000004, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000004)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000005, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000005)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000006, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000006)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000007, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000007)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000008, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000008)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [0] VM::deal(0x0000000000000000000000000000000000000009, 100000000000000000 [1e17])
    //     │   └─ ← ()
    //     ├─ [0] VM::prank(0x0000000000000000000000000000000000000009)
    //     │   └─ ← ()
    //     ├─ [46954] FundMe::fund{value: 100000000000000000}()
    //     │   ├─ [993] MockV3Aggregator::latestRoundData() [staticcall]
    //     │   │   └─ ← 1, 200000000000 [2e11], 1, 1, 1
    //     │   └─ ← ()
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     ├─ [0] VM::startPrank(DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38])
    //     │   └─ ← ()
    //     ├─ [15699] FundMe::withdraw()
    //     │   ├─ [0] DefaultSender::fallback{value: 1000000000000000000}()
    //     │   │   └─ ← ()
    //     │   └─ ← ()
    //     ├─ [0] VM::stopPrank()
    //     │   └─ ← ()
    //     ├─ [202] FundMe::getOwner() [staticcall]
    //     │   └─ ← DefaultSender: [0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38]
    //     └─ ← ()
}
