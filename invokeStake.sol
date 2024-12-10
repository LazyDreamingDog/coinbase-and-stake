// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStake {
    function withdraw(
        string calldata source,
        address account,
        uint256 amount
    ) external;
    
    function withdrawMultiple(
        string calldata source,
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external;
    
    function addToWhitelist(address _address) external;
}

contract InvokeStake {
    // Stake合约地址
    address public immutable STAKE_ADDRESS = 0x63BC05BC6FCAb99AF9A4c215B2e92a9C6f45D41F;
    
    // 操作者地址
    address public owner;
    
    // 事件
    event SingleWithdraw(string source, address account, uint256 amount);
    event MultipleWithdraw(string source, address[] accounts, uint256[] amounts);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // 初始化：将本合约添加到stake合约的白名单中
    function initialize() external onlyOwner {
        IStake(STAKE_ADDRESS).addToWhitelist(address(this));
    }
    
    // 增加白名单
    function addToWhitelist(address _address) public onlyOwner {
        IStake(STAKE_ADDRESS).addToWhitelist(_address);
    }

    // 单地址提现示例
    function singleWithdrawExample(
        string calldata source,
        address account,
        uint256 amount
    ) external onlyOwner {
        // 调用stake合约的withdraw方法
        IStake(STAKE_ADDRESS).withdraw(
            source,
            account,
            amount
        );
        
        emit SingleWithdraw(source, account, amount);
    }
    
    // 多地址提现示例
    function multipleWithdrawExample(
        string calldata source,
        address[] calldata accounts,
        uint256[] calldata amounts
    ) external onlyOwner {
        // 调用stake合约的withdrawMultiple方法
        IStake(STAKE_ADDRESS).withdrawMultiple(
            source,
            accounts,
            amounts
        );
        
        emit MultipleWithdraw(source, accounts, amounts);
    }
    
}
