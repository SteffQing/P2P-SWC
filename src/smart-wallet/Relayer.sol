// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../lib/SafeTransferLib.sol";
import "../lib/ERC20.sol";
import "../utils/Owner.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address who) external returns (uint);
}


contract Relayer is Owner {

    event TransactionSent(address indexed from, address indexed to, uint256 amount, address indexed token);

    mapping(address => bool) private relayers;

    constructor(address first_relayer) Owner(first_relayer) {
        relayers[first_relayer] = true;
    }

    modifier onlyRelayer() {
        require(relayers[msg.sender], "Only whitelisted relayers can call this function");
        _;
    }

    function addRelayer(address _relayer) external {
        onlyOwner();
        relayers[_relayer] = true;
    }

    function removeRelayer(address _relayer) external {
        onlyOwner();
        relayers[_relayer] = false;
    }

    function sendETH(address from, address to, uint256 amount) private {
        require(address(from).balance >= amount, "Sender has insufficient balance");
        SafeTransferLib.safeTransferETH(to, amount);
    }

    function sendToken(address from, address to, uint256 amount, address token) private {
        require(IERC20(token).balanceOf(from) >= amount, "Sender has insufficient balance");
        SafeTransferLib.safeTransfer(ERC20(token), to, amount);
    }

    function send(address from, address to, uint256 amount, address token) external onlyRelayer {
        if (token == address(0)) {
            sendETH(from, to, amount); 
        } else {
            sendToken(from, to, amount, token); 
        }
        emit TransactionSent(from, to, amount, token);
    }

}
