// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {Chainlink, ChainlinkClient} from "@chainlink/contracts@1.0.0/src/v0.8/ChainlinkClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts@1.0.0/src/v0.8/shared/access/ConfirmedOwner.sol";
import {LinkTokenInterface} from "@chainlink/contracts@1.0.0/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract FetchFromArray is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    string public temp;

    bytes32 private jobId;
    uint256 private fee;

    event RequestTemp(bytes32 indexed requestId, string temp);

    constructor() ConfirmedOwner(msg.sender) {
        _setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        _setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        jobId = "7d80a6386ef543a3abb52817f6707e3b";
        fee = (1 * LINK_DIVISIBILITY) / 10; 
    }

    function requestTemp() public returns (bytes32 requestId) {
        Chainlink.Request memory req = _buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        req._add(
            "get",
            //here "city=820000" means Macau
            "https://restapi.amap.com/v3/weather/weatherInfo?city=820000&key=8e8ff3cc1a665ca1a63f544f5706152a"
        );

        req._add("path", "lives,0,temperature_float"); 

        return _sendChainlinkRequest(req, fee);
    }

    function fulfill(
        bytes32 _requestId,
        string memory _temp
    ) public recordChainlinkFulfillment(_requestId) {
        emit RequestTemp(_requestId, _temp);
        temp = _temp;
    }
}

