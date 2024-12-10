// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICoinbase {
    function addToWhitelist(address _address) external;

    function addCoinbase(
        string calldata source,
        address[] calldata rewardAddresses,
        string calldata rewardType,
        uint256 totalAmount,
        uint256 numWinners
    ) external;
    
    function addCoinbaseDirectly(
        string calldata source,
        address[] calldata rewardAddresses,
        uint256[] calldata rewardAmounts,
        string calldata rewardType
    ) external;
}

contract CoinbaseOperator {
    // Coinbase合约地址
    address public immutable COINBASE_ADDRESS = 0xF02F87F086a53cb793E7e920bea648bb52A7d75D;
    
    // 操作者mapping
    mapping(address => bool) public operators;
    
    // 奖励类型枚举
    enum RewardType {
        STAKE,
        MINE,
        VOTE,
        CUSTOM
    }
    
    // 自定义奖励类型结构体
    struct CustomRewardType {
        string name;
        string description;
        bool isValid;
    }
    
    // 存储自定义奖励类型
    mapping(uint256 => CustomRewardType) public customRewardTypes;
    uint256 public nextCustomRewardTypeId = uint256(RewardType.CUSTOM);
    
    // 事件
    event OperatorAdded(address indexed operator);
    event OperatorRemoved(address indexed operator);
    event CustomRewardTypeAdded(uint256 indexed typeId, string name);
    event RewardDistributed(
        string source,
        string rewardType,
        uint256 totalAmount,
        uint256 recipientCount
    );
    
    // 构造函数
    constructor() {
        operators[msg.sender] = true;
    }
    
    // 修饰符
    modifier onlyOperator() {
        require(operators[msg.sender], "Caller is not an operator");
        _;
    }
    
    // 管理操作者
    function addOperator(address operator) external onlyOperator {
        require(operator != address(0), "Invalid operator address");
        operators[operator] = true;
        emit OperatorAdded(operator);
    }
    
    function removeOperator(address operator) external onlyOperator {
        operators[operator] = false;
        emit OperatorRemoved(operator);
    }
    
    // 增加白名单
    function addToWhitelist(address _address) external onlyOperator {
        ICoinbase(COINBASE_ADDRESS).addToWhitelist(_address);
    }

    // 添加自定义奖励类型
    function addCustomRewardType(
        string calldata name,
        string calldata description
    ) external onlyOperator returns (uint256) {
        uint256 newTypeId = nextCustomRewardTypeId++;
        
        customRewardTypes[newTypeId] = CustomRewardType({
            name: name,
            description: description,
            isValid: true
        });
        
        emit CustomRewardTypeAdded(newTypeId, name);
        return newTypeId;
    }
    
    // 获取奖励类型字符串
    function getRewardTypeString(uint256 rewardTypeId) public view returns (string memory) {
        if (rewardTypeId == uint256(RewardType.STAKE)) return "stake";
        if (rewardTypeId == uint256(RewardType.MINE)) return "mine";
        if (rewardTypeId == uint256(RewardType.VOTE)) return "vote";
        
        require(customRewardTypes[rewardTypeId].isValid, "Invalid reward type");
        return customRewardTypes[rewardTypeId].name;
    }
    
    // 随机抽奖分发奖励
    function distributeRewardWithLottery(
        string calldata source,
        uint256 rewardTypeId,
        address[] calldata candidates,
        uint256 totalAmount,
        uint256 numWinners
    ) external onlyOperator {
        string memory rewardType = getRewardTypeString(rewardTypeId);
        
        ICoinbase(COINBASE_ADDRESS).addCoinbase(
            source,
            candidates,
            rewardType,
            totalAmount,
            numWinners
        );
        
        emit RewardDistributed(source, rewardType, totalAmount, numWinners);
    }
    
    // 直接分发奖励
    function distributeRewardDirectly(
        string calldata source,
        uint256 rewardTypeId,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external onlyOperator {
        string memory rewardType = getRewardTypeString(rewardTypeId);
        
        ICoinbase(COINBASE_ADDRESS).addCoinbaseDirectly(
            source,
            recipients,
            amounts,
            rewardType
        );
        
        uint256 totalAmount = 0;
        for(uint i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        emit RewardDistributed(source, rewardType, totalAmount, recipients.length);
    }
}
