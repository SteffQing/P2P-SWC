// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint amt) external returns (bool);
    function symbol() external view returns (string memory) ;
}
interface Deployer{
    function isAdmin(address admin) external view returns (bool);
}
contract SmartWallet {
    address private admin;
    Deployer private deployer;

    event ReceivedETH(uint amount);
    event SentETH(uint amount);
    event SentToken(address token, uint amount);

    modifier onlyAdmin() {
        require(deployer.isAdmin(admin), "Not the admin");
        _;
    }
    constructor(address _admin, address _deployer) {
        admin = _admin;
        deployer = Deployer(_deployer);
    }
    
    // Allow wallet to receive ETH
    function deposit() external payable {
        emit ReceivedETH(msg.value);}
    receive() external payable {
        emit ReceivedETH(msg.value);
    }
    // Withdraw ETH
  function withdrawEth(address payable recipient, uint256 amount) external onlyAdmin {
    require(recipient != address(0));
        (bool success,) = recipient.call{value: amount}("");
        require(success, "withdraw failed");
        emit SentETH(amount);
    }

    // Withdraw ERC20 tokens from the wallet
    function withdrawERC20Token(IERC20 token, address to, uint256 amount) external onlyAdmin {
        require(to != address(0), "cannot send to address 0");
        require(token.transfer(to, amount), "Token transfer failed");
        emit SentToken(address(token), amount);
    }
}