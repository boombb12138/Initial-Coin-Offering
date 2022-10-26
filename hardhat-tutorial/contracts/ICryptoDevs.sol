// SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

interface ICryptoDevs {
    // 根据给定的tokenlist的index返回owner拥有的token ID
    // 和balanceOf 一起使用来枚举owner所有的token
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256 tokenId);

    //返回owner拥有的token数量
    function balanceOf(address owner) external view returns (uint256 balance);
}
