// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {DeployFundMe} from "script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    address USER2 = makeAddr("user2");
    uint256 constant SEND_ETH = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //us -> FundMeTest (deploy) -> fundMe = Fundme() ,so i_owner =FundMeTest(address)!!
        DeployFundMe dfundMe = new DeployFundMe();
        fundMe = dfundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testminimumDollaris5() public {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.i_owner());
        console.log(address(this));
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund{value: 10000}();
    }

    modifier fund() {
        vm.prank(USER);
        fundMe.fund{value: SEND_ETH}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public fund {
        uint256 sp;
        sp = fundMe.getAddressToAmountFunded(USER);
        assertEq(sp, SEND_ETH);
    }

    function testFundAddsFundersToFundersArray() public {
        vm.prank(USER); //The next transaction will be sent by USER
        fundMe.fund{value: SEND_ETH}();
        address sp;
        sp = fundMe.getFunder(0);
        assertEq(sp, USER);
    }

    function testOnlyOwnerCanWithdraw() public fund {
        vm.expectRevert();
        vm.prank(USER2);
        fundMe.withdraw();
    }

    function testOwnerCanWithdraw() public fund {
        address sp = fundMe.getOwner();
        vm.prank(sp);
        fundMe.withdraw();
    }

    function testWithdrawFromMultipleFunders() public {
        uint160 numberofFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberofFunders; i++) {
            hoax(address(i), SEND_ETH);
            fundMe.fund{value: SEND_ETH}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
