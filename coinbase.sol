// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Coinbase {
    // 白名单mapping
    mapping(address => bool) public whitelist;
    
    // 硬编码的mapping地址
    address public constant STAKING_ADDRESS = 0x63BC05BC6FCAb99AF9A4c215B2e92a9C6f45D41F;
    
    // 构造函数中初始化硬编码地址到白名单
    constructor() {
        whitelist[STAKING_ADDRESS] = true;
    }
    
    // 事件定义
    event CoinbaseAdded(
        string indexed source,  // 来源区 string类型 
        string indexed rewardType,      // 奖励类型(如：挖矿、质押、投票等)
        uint256 indexed timestamp,
        address[] selectedAddresses, // 奖励地址
        uint256[] rewards       // 奖励金额
    );
    
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
    
    // 选择随机地址的内部函数 ： "Fisher-Yates洗牌算法"的变体
    function _selectRandomAddresses(address[] memory addresses, uint256 numToSelect) 
        internal view returns (address[] memory) {
        require(numToSelect <= addresses.length, "Cannot select more addresses than provided");
        
        address[] memory selectedAddresses = new address[](numToSelect);
        address[] memory tempAddresses = new address[](addresses.length);
        
        // 复制地址数组
        for(uint i = 0; i < addresses.length; i++) {
            tempAddresses[i] = addresses[i];
        }
        
        // 随机选择地址
        for(uint i = 0; i < numToSelect; i++) {
            // 1. 生成随机索引：范围是从0到未处理的地址数量
            // block.prevrandao 经过修改后可获取共识传来的随机数
            uint256 randomIndex = block.prevrandao % (tempAddresses.length - i);
            
            // 2. 将随机选中的地址保存到结果数组
            selectedAddresses[i] = tempAddresses[randomIndex];
            
            // 3. 将已选中的地址与数组末尾未选择的地址交换
            tempAddresses[randomIndex] = tempAddresses[tempAddresses.length - 1 - i];
        }
        
        return selectedAddresses;
    }
    
    // 添加coinbase奖励（带抽签）
    function addCoinbase(
        string calldata source,  // 新增 source 参数，类型为 string
        address[] calldata rewardAddresses,
        string calldata rewardType,
        uint256 totalAmount,
        uint256 numWinners  // 抽签人数
    ) external onlyWhitelisted {
        require(rewardAddresses.length > 0, "No addresses provided");
        require(numWinners > 0 && numWinners <= rewardAddresses.length, "Invalid number of winners");
        
        // 随机选择获奖地址
        address[] memory selectedAddresses = _selectRandomAddresses(rewardAddresses, numWinners);
        
        // 计算奖励比例
        uint256[] memory rewards = new uint256[](numWinners);
        uint256 remainingAmount = totalAmount;
        
        // 按抽签顺序分配不同比例的奖励
        // 第一名获得剩余金额的50%
        // 第二名获得剩余金额的30%
        // 其余平分剩下的金额
        if(numWinners >= 1) {
            rewards[0] = remainingAmount * 50 / 100; // 第一名50%
            remainingAmount -= rewards[0];
        }
        
        if(numWinners >= 2) {
            rewards[1] = remainingAmount * 30 / 100; // 第二名30%
            remainingAmount -= rewards[1];
        }
        
        if(numWinners > 2) {
            uint256 rewardPerRemaining = remainingAmount / (numWinners - 2);
            for(uint i = 2; i < numWinners; i++) {
                rewards[i] = rewardPerRemaining;
                remainingAmount -= rewardPerRemaining;
            }
        }
        
        // 如果有余数，将余数加到第一名的奖励中
        if(remainingAmount > 0) {
            rewards[0] += remainingAmount;
        }
        
        // 触发事件
        emit CoinbaseAdded(
            source,  // 使用传入的 source
            rewardType,
            block.timestamp,
            selectedAddresses,
            rewards
        );
    }
    
    // 添加coinbase奖励（不需要抽签）
    function addCoinbaseDirectly(
        string calldata source,  // 新增 source 参数，类型为 string
        address[] calldata rewardAddresses,
        uint256[] calldata rewardAmounts,
        string calldata rewardType
    ) external onlyWhitelisted {
        require(rewardAddresses.length > 0, "No addresses provided");
        require(rewardAddresses.length == rewardAmounts.length, "Arrays length mismatch");
        
        emit CoinbaseAdded(
            source,  // 使用传入的 source
            rewardType,
            block.timestamp,
            rewardAddresses,
            rewardAmounts
        );
    }
}



