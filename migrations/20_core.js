/* eslint-disable no-undef */
/* eslint-disable prefer-const */
/* eslint-disable one-var */

const c_CommonHelpers = artifacts.require('CommonHelpers');
const c_ForgeValidator = artifacts.require('ForgeValidator');
const c_StableMath = artifacts.require('StableMath');
const c_PublicStableMath = artifacts.require('PublicStableMath');

const c_SavingsManager = artifacts.require('SavingsManager')
const c_SavingsContract = artifacts.require('SavingsContract')

const c_MassetHelpers = artifacts.require('MassetHelpers')
const c_Masset = artifacts.require('Masset')
const c_BasketManager = artifacts.require('BasketManager')

module.exports = async (deployer, network, accounts) => {

  // Address of the price source to whitelist in the OracleHub
  // const oracleSource = [];
  const [_, governor, fundManager, oracleSource, feePool] = accounts;

  /** Common Libs */
  await deployer.deploy(c_StableMath, { from: _ });
  await deployer.link(c_StableMath, c_Masset);
  await deployer.link(c_StableMath, c_PublicStableMath);
  await deployer.link(c_StableMath, c_ForgeValidator);
  await deployer.link(c_StableMath, c_MassetHelpers);
  await deployer.deploy(c_ForgeValidator);
  await deployer.deploy(c_PublicStableMath, { from: _ });
  await deployer.deploy(c_CommonHelpers, { from: _ });
  await deployer.link(c_CommonHelpers, c_BasketManager);
  // await deployer.link(c_Masset, c_MassetHelpers);
  await deployer.deploy(c_MassetHelpers, { from: _ });

  /** Nexus */
  await deployer.deploy(c_Nexus, governor, { from: governor });
  const d_Nexus = await c_Nexus.deployed();


  console.log(`[Nexus]: '${d_Nexus.address}'`)
}
