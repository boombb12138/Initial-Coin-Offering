const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  //  Crypto Devs NFT合约地址
  const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;

  // 创建合约实例
  const cryptoDevsTokenContract = await ethers.getContractFactory(
    "CryptoDevToken"
  );
  // 部署
  const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(
    cryptoDevsNFTContract
  );
  await deployedCryptoDevsTokenContract.deployed();
  // 打印合约地址
  console.log(
    "Crypto Devs Token Contract Address:",
    deployedCryptoDevsTokenContract.address
  );
}
// 调用main函数，看看是不是部署成功
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
