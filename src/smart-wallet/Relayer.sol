// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../lib/SafeTransferLib.sol";
import "../lib/ERC20.sol";

contract Relayer {
    event TransactionSent(
        address indexed from,
        address indexed to,
        uint256 amount,
        address indexed token
    );

    address immutable owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }
    
    receive() external payable {}

    function sendETH(address from, address to, uint256 amount) private {
        require(
            address(from).balance >= amount,
            "Sender has insufficient balance"
        );
        SafeTransferLib.safeTransferETH(to, amount);
    }

    function sendToken(
        address from,
        address to,
        uint256 amount,
        address token
    ) private {
        ERC20 _token = ERC20(token);
        require(
            _token.balanceOf(from) >= amount,
            "Sender has insufficient balance"
        );
        SafeTransferLib.safeTransfer(_token, to, amount);
    }

    function send(
        address from,
        address to,
        uint256 amount,
        address token
    ) external onlyOwner {
        if (token == address(0)) {
            sendETH(from, to, amount);
        } else {
            sendToken(from, to, amount, token);
        }
        emit TransactionSent(from, to, amount, token);
    }
}
