pragma solidity 0.5.16;

// External
import { ISavingsManager } from "../interfaces/ISavingsManager.sol";

// Internal
import { ISavingsContract } from "../interfaces/ISavingsContract.sol";
import { Module } from "../shared/Module.sol";

// Libs
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { StableMath } from "../shared/StableMath.sol";


/**
 * @title   SavingsContract
 * @author  Stability Labs Pty. Ltd.
 * @notice  Savings contract uses the ever increasing "exchangeRate" to increase
 *          the value of the Savers "credits" relative to the amount of additional
 *          underlying collateral that has been deposited into this contract ("interest")
 * @dev     VERSION: 1.0
 *          DATE:    2020-03-28
 */
contract SavingsContract is ISavingsContract, Module {

    using SafeMath for uint256;
    using StableMath for uint256;

    struct AssertionFailedHelper { uint256 magic; }

    // Core events for depositing and withdrawing
    event ExchangeRateUpdated(uint256 newExchangeRate, uint256 interestCollected);
    event SavingsDeposited(address indexed saver, uint256 savingsDeposited, uint256 creditsIssued);
    event CreditsRedeemed(address indexed redeemer, uint256 creditsRedeemed, uint256 savingsCredited);
    event AutomaticInterestCollectionSwitched(bool automationEnabled);

    // Underlying asset is mUSD
    IERC20 private mUSD;

    // Amount of underlying savings in the contract
    uint256 public totalSavings;
    // Total number of savings credits issued
    uint256 public totalCredits;

    // Rate between 'savings credits' and mUSD
    // e.g. 1 credit (1e18) mulTruncate(exchangeRate) = mUSD, starts at 1:1
    // exchangeRate increases over time and is essentially a percentage based value
    uint256 public exchangeRate = 1e18;
    // Amount of credits for each saver
    mapping(address => uint256) public creditBalances;
    bool private automateInterestCollection = true;

    constructor(address _nexus, IERC20 _mUSD)
        public
        Module(_nexus)
    {
        require(address(_mUSD) != address(0), "mAsset address is zero");
        mUSD = _mUSD;
    }

    /** @dev Only the savings managaer (pulled from Nexus) can execute this */
    modifier onlySavingsManager() {
        require(msg.sender == _savingsManager(), "Only savings manager can execute");
        _;
    }

    /** @dev Enable or disable the automation of fee collection during deposit process */
    function automateInterestCollectionFlag(bool _enabled)
        external
        onlyGovernor
    {
        automateInterestCollection = _enabled;
        emit AutomaticInterestCollectionSwitched(_enabled);
    }

    /***************************************
                    INTEREST
    ****************************************/

    /**
     * @dev Deposit interest (add to savings) and update exchange rate of contract.
     *      Exchange rate is calculated as the ratio between new savings q and credits:
     *                    exchange rate = savings / credits
     *
     * @param _amount   Units of underlying to add to the savings vault
     */
    function depositInterest(uint256 _amount)
        external
        onlySavingsManager
    {
        require(_amount > 0, "Must deposit something");

        // Transfer the interest from sender to here
        require(mUSD.transferFrom(msg.sender, address(this), _amount), "Must receive tokens");
        totalSavings = totalSavings.add(_amount);

        // Calc new exchange rate, protect against initialisation case
        if(totalCredits > 0) {
            // new exchange rate is relationship between totalCredits & totalSavings
            // totalCredits * exchangeRate = totalSavings
            // exchangeRate = totalSavings/totalCredits
            // e.g. (100e18 * 1e18) / 100e18 = 1e18
            // e.g. (101e20 * 1e18) / 100e20 = 1.01e18

            uint256 oldExchangeRate = exchangeRate;

            exchangeRate = totalSavings.divPrecisely(totalCredits);

            // P7
            if (!(oldExchangeRate <= exchangeRate)) {
                { AssertionFailedHelper memory helper; helper.magic = 0xcafecafecafecafecafecafecafecafecafecafecafecafecafecafecafe0000 + 7; }
                // assert(false);
            }

            emit ExchangeRateUpdated(exchangeRate, _amount);
        }
    }


    /***************************************
                    SAVING
    ****************************************/

    /**
     * @dev Deposit the senders savings to the vault, and credit them internally with "credits".
     *      Credit amount is calculated as a ratio of deposit amount and exchange rate:
     *                    credits = underlying / exchangeRate
     *      If automation is enabled, we will first update the internal exchange rate by
     *      collecting any interest generated on the underlying.
     * @param _amount          Units of underlying to deposit into savings vault
     * @return creditsIssued   Units of credits issued internally
     */
    function depositSavings(uint256 _amount)
        external
        returns (uint256 creditsIssued)
    {
        require(_amount > 0, "Must deposit something");

        if(automateInterestCollection) {
            // Collect recent interest generated by basket and update exchange rate
            ISavingsManager(_savingsManager()).collectAndDistributeInterest(address(mUSD));
        }

        // Transfer tokens from sender to here
        require(mUSD.transferFrom(msg.sender, address(this), _amount), "Must receive tokens");
        totalSavings = totalSavings.add(_amount);

        // Calc how many credits they receive based on currentRatio
        creditsIssued = _massetToCredit(_amount);
        totalCredits = totalCredits.add(creditsIssued);

        // add credits to balances
        creditBalances[msg.sender] = creditBalances[msg.sender].add(creditsIssued);

        emit SavingsDeposited(msg.sender, _amount, creditsIssued);
    }

    /**
     * @dev Redeem specific number of the senders "credits" in exchange for underlying.
     *      Payout amount is calculated as a ratio of credits and exchange rate:
     *                    payout = credits * exchangeRate
     * @param _credits         Amount of credits to redeem
     * @return massetReturned  Units of underlying mAsset paid out
     */
    function redeem(uint256 _credits)
        external
        returns (uint256 massetReturned)
    {
        require(_credits > 0, "Must withdraw something");

        uint256 saverCredits = creditBalances[msg.sender];
        require(saverCredits >= _credits, "Saver has no credits");

        creditBalances[msg.sender] = saverCredits.sub(_credits);
        totalCredits = totalCredits.sub(_credits);

        // Calc payout based on currentRatio
        massetReturned = _creditToMasset(_credits);
        totalSavings = totalSavings.sub(massetReturned);

        // Transfer tokens from here to sender
        require(mUSD.transfer(msg.sender, massetReturned), "Must send tokens");

        emit CreditsRedeemed(msg.sender, _credits, massetReturned);
    }

    /**
     * @dev Converts masset amount into credits based on exchange rate
     *               c = masset / exchangeRate
     */
    function _massetToCredit(uint256 _amount)
        internal
        view
        returns (uint256 credits)
    {
        // e.g. (1e20 * 1e18) / 1e18 = 1e20
        // e.g. (1e20 * 1e18) / 14e17 = 7.1429e19
        credits = _amount.divPrecisely(exchangeRate);
    }

    /**
     * @dev Converts masset amount into credits based on exchange rate
     *               m = credits * exchangeRate
     */
    function _creditToMasset(uint256 _credits)
        internal
        view
        returns (uint256 massetAmount)
    {
        // e.g. (1e20 * 1e18) / 1e18 = 1e20
        // e.g. (1e20 * 14e17) / 1e18 = 1.4e20
        massetAmount = _credits.mulTruncate(exchangeRate);
    }
}
