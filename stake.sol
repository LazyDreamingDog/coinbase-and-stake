// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 修改 Coinbase 合约的接口
interface ICoinbase {
    function addCoinbaseDirectly(
        string calldata source,
        address[] calldata rewardAddresses,
        uint256[] calldata rewardAmounts,
        string calldata rewardType
    ) external;
    
    function addCoinbase(
        string calldata source,
        address[] calldata rewardAddresses,
        string calldata rewardType,
        uint256 totalAmount,
        uint256 numWinners
    ) external;
}

contract Stake {
    // Coinbase合约地址
    address public constant COINBASE_ADDRESS = 0xF02F87F086a53cb793E7e920bea648bb52A7d75D;
    string public constant REWARDTYPE = "STAKE";
    
    
    // 白名单mapping
    mapping(address => bool) public whitelist;
    
    // 检查白名单的modifier
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Caller is not whitelisted");
        _;
    }
    
    // 添加白名单地址
    function addToWhitelist(address _address) public {
        require(_address != address(0), "Invalid address");
        whitelist[_address] = true;
    }
    
    // 单地址提现函数
    function withdraw(
        string calldata source,
        address account,
        uint256 amount
    ) external onlyWhitelisted {
        require(account != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than 0");
        
        // 准备参数
        address[] memory accounts = new address[](1);
        accounts[0] = account;
        
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = amount;
        
        // 调用Coinbase合约的addCoinbaseDirectly方法
        ICoinbase(COINBASE_ADDRESS).addCoinbaseDirectly(
            source,
            accounts,
            amounts,
            REWARDTYPE
        );
    }
    
    // 多地址提现函数
    function withdrawMultiple(
        string calldata source,
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external onlyWhitelisted {
        require(accounts.length > 0, "No addresses provided");
        require(accounts.length == amounts.length, "Arrays length mismatch");
        
        // 计算总金额
        uint256 totalAmount = 0;
        for(uint i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        // 调用Coinbase合约的addCoinbase方法
        ICoinbase(COINBASE_ADDRESS).addCoinbase(
            source,
            accounts,
            REWARDTYPE,
            totalAmount,
            accounts.length
        );
    }
}
