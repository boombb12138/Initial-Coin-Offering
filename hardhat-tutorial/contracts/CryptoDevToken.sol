// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// Owner合约
// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    // 一个token的价格
    uint256 public constant tokenPrice = 0.001 ether;
    // 每个NFT会给用户10个token
    // 1个ERC20代币就相当于10^-18个tokens，它是token的最小面值
    uint256 public constant tokensPerNFT = 10 * 10**18;
    //  Crypto Dev Tokens的总数为10000
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    //CryptoDevsNFT 合约实例
    ICryptoDevs CryptoDevsNFT;
    // 跟踪哪个tokenIds被claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    // mint 'amount' 数量的CryptoDevTokens
    // 要求：msg.value要>=tokenPrice * amount
    function mint(uint256 amount) public payable {
        // msg.value要>=tokenPrice * amount
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Ether sent is incorrect");
        // total tokens + amount <= 10000 否则就返回交易
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Exceeds the max total supply available."
        );
        // 这个函数是来自ERC20合约 它会给msg.sender创造amountWithDecimals的代币
        _mint(msg.sender, amountWithDecimals);
    }

    // mint tokens基于sender拥有的NFT数量
    // 要求：sender拥有的NFT数量要大于0，Tokens不能被sender所有的NFT claimed
    function claim() public {
        address sender = msg.sender;
        // 得到sender拥有的NFT总数
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        // 如果没有NFT 就返回交易
        require(balance > 0, "You dont own any Crypto Dev NFT's");
        //    amount跟踪没有被claimed的tokenId的数量
        uint256 amount = 0;
        // 循环余额，根据token list的index得到sender拥有的tokenId
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            // 如果这个tokenId还没有被claimed 就增加数量
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        // 如果所有的tokenID都被claimed了，返回交易
        require(amount > 0, "You have already claimed all the tokens");
        //mint (amount * 10) tokens给每个NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    // 提取发送给合约的所有的ETH和token
    // 要求：连接钱包的必须是owner
    // 为什么withdraw可以这样子调用owner - 继承自Owner合约
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance; //得到owner的余额
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // 接收Ether. msg.data的函数必须是空的
    receive() external payable {}

    // 当msg.data不是空的时候Fallback会被调用
    fallback() external payable {}
}
