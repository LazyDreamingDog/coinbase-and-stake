##### 两个合约的地址

```
coinbase 合约地址："F02F87F086a53cb793E7e920bea648bb52A7d75D"

stake 合约地址："63BC05BC6FCAb99AF9A4c215B2e92a9C6f45D41F"
```

##### 合约接口说明

```solidity
interface ICoinbase {
		// 设置Coinbase合约的白名单（目前是没有限制该方法的调用者，任何人都可以设置）
    function addToWhitelist(address _address) external;

		// 带抽签的激励记录
    function addCoinbase(
        string calldata source,								// 激励来源区
        address[] calldata rewardAddresses,		// 激励地址 
        string calldata rewardType,						// 激励类型，质押、投票等
        uint256 totalAmount,									// 激励总额
        uint256 numWinners										// 最终可获得激励的人数
    ) external;
    
    // 不带抽签的激励记录
    function addCoinbaseDirectly(
        string calldata source,								// 来源区
        address[] calldata rewardAddresses,		// 激励地址
        uint256[] calldata rewardAmounts,			// 每个地址对应的金额
        string calldata rewardType						// 激励类型
    ) external;
}

```



```solidity
// Stake合约仅作记录，Deposit 和 Withdraw 具体方法自定义
interface IStake {
		// 单地址的提现：用于大额提现，不会经过抽签
    function withdraw(
        string calldata source,		// 来源区
        address account,					// 提现地址
        uint256 amount						// 提现金额
    ) external;
    
    // 多地址的提现：用于小额提现，会经过抽签
    function withdrawMultiple(
        string calldata source,						// 来源区
        address[] calldata accounts,			// 提现地址
        uint256[] calldata amounts				// 每个提现地址对应的金额
    ) external;
    
    // 设置Stake合约的白名单（目前是没有限制该方法的调用者，任何人都可以设置）
    function addToWhitelist(address _address) external;
}

```

