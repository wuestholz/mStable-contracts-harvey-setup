/* eslint-disable max-classes-per-file */
/* eslint-disable lines-between-class-members */

import { Address } from "../types/common";
import { BN } from "./tools";
import utils from "web3-utils";

/**
 * @notice This file contains constants relevant across the mStable test suite
 * Wherever possible, it should conform to fixed on chain vars
 */

export const ratioScale = new BN(10).pow(new BN(8));
export const fullScale: BN = new BN(10).pow(new BN(18));

export const DEAD_ADDRESS = "0x0000000000000000000000000000000000000001";
export const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

export const MAX_UINT256 = new BN(2).pow(new BN(256)).sub(new BN(1));

export const ZERO = new BN(0);
export const ONE_MIN = new BN(60);
export const TEN_MINS = new BN(60 * 10);
export const ONE_DAY = new BN(60 * 60 * 24);
export const FIVE_DAYS = new BN(60 * 60 * 24 * 5);
export const TEN_DAYS = new BN(60 * 60 * 24 * 10);
export const ONE_WEEK = new BN(60 * 60 * 24 * 7);
export const ONE_YEAR = new BN(60 * 60 * 24 * 7 * 52);

export const KEY_SAVINGS_MANAGER = utils.keccak256("SavingsManager");
export const KEY_PROXY_ADMIN = utils.keccak256("ProxyAdmin");

export class MainnetAccounts {
    // Exchange Accounts
    private okex: Address = "0x6cC5F688a315f3dC28A7781717a9A798a59fDA7b";
    private binance: Address = "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE";
    public FUND_SOURCES = {
        dai: this.okex,
        usdc: this.binance,
        tusd: "0x3dfd23a6c5e8bbcfc9581d2e864a68feb6a076d3",
        usdt: this.binance,
    };
    public USDT_OWNER: Address = "0xc6cde7c39eb2f0f0095f41570af89efc2c1ea828";

    // All Native Tokens
    public DAI: Address = "0x6b175474e89094c44da98b954eedeac495271d0f";
    public TUSD: Address = "0x0000000000085d4780B73119b644AE5ecd22b376";
    public USDC: Address = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    public USDT: Address = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
    public allNativeTokens: Address[] = [this.DAI, this.TUSD, this.USDC, this.USDT];

    // AAVE
    public aavePlatform: Address = "0x24a42fD28C976A61Df5D00D0599C34c4f90748c8";
    public aTUSD: Address = "0x4DA9b813057D04BAef4e5800E36083717b4a0341";
    public aUSDT: Address = "0x71fc860F7D3A592A4a98740e39dB31d25db65ae8";
    public allATokens: Address[] = [this.aTUSD, this.aUSDT];

    // Compound cTokens
    public cDAI: Address = "0x5d3a536e4d6dbd6114cc1ead35777bab948e3643";
    public cUSDC: Address = "0x39aa39c021dfbae8fac545936693ac917d5e7563";
    public allCTokens: Address[] = [this.cDAI, this.cUSDC];
}

export class RopstenAccounts {
    // All Native Tokens
    public DAI: Address = "0xb5e5d0f8c0cba267cd3d7035d6adc8eba7df7cdd";
    public USDC: Address = "0x8a9447df1fb47209d36204e6d56767a33bf20f9f";

    public TUSD: Address = "0xb36938c51c4f67e5e1112eb11916ed70a772bd75";

    public USDT: Address = "0xB404c51BBC10dcBE948077F18a4B8E553D160084";
    public allNativeTokens: Address[] = [this.DAI, this.TUSD, this.USDC, this.USDT];

    // AAVE
    public aavePlatform: Address = "0x1c8756FD2B28e9426CDBDcC7E3c4d64fa9A54728";
    public aTUSD: Address = "0x3de3f55afdb0cf2753fae759f36d892126a06c81";
    public aUSDT: Address = "0x790744bC4257B4a0519a3C5649Ac1d16DDaFAE0D";
    public allATokens: Address[] = [this.aTUSD, this.aUSDT];

    // Compound cTokens
    public cDAI: Address = "0x6ce27497a64fffb5517aa4aee908b1e7eb63b9ff";
    public cUSDC: Address = "0x20572e4c090f15667cf7378e16fad2ea0e2f3eff";
    public allCTokens: Address[] = [this.cDAI, this.cUSDC];
}
