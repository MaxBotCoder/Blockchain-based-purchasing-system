//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

contract code{

    address ContractAdmin;
    uint public TotalCapital;
    uint public TokenPrice;

    mapping(address => uint) public ValuePassthrough;
    mapping(address => uint) public TemporaryValue;
    mapping(address => uint) public TokensPurchased;
    mapping(address => uint) public TokensOrdered;
    mapping(address => uint) public PurchasePrice;
    mapping(address => uint) public TransactionStatusSuccess;
    mapping(address => uint) public TransactionStatusFailure;

    constructor(uint _TokenPrice, address _CryptoCollectorAddress){
        TokenPrice = _TokenPrice;
        ContractAdmin = _CryptoCollectorAddress;
    }

    struct _LeadInvestor {
        uint _CryptoInvested;
        address _Investor;
    }

    _LeadInvestor public LeadInvestor;

    struct TokenInfo {
        uint _TokensbBoughtTotal;
        uint _TokensJustBought;
        string _TransactionStatus;
        uint _NumberOfTransactionSuccesses;
        uint _NumberOfTransactionFailures;
        uint _TimeOfTransaction;
    }

    mapping(address => TokenInfo) public TokenPurchaseInfo;

    function BuyToken(uint TokenQuantity) payable public {
        ValuePassthrough[msg.sender] = msg.value;
        TemporaryValue[msg.sender] = ValuePassthrough[msg.sender];
        TotalCapital += msg.value;
        ValuePassthrough[msg.sender] = 0;
        TokensOrdered[msg.sender] = TokenQuantity;
        PurchasePrice[msg.sender] = TokensOrdered[msg.sender] * TokenPrice;
        if(TemporaryValue[msg.sender] == PurchasePrice[msg.sender]) {
            TokensPurchased[msg.sender] += TokensOrdered[msg.sender];
            TransactionStatusSuccess[msg.sender] += 1;
            TransactionStatusFailure[msg.sender] += 0;
            TokenPurchaseInfo[msg.sender] = TokenInfo(TokensPurchased[msg.sender], TokensOrdered[msg.sender], "Success", TransactionStatusSuccess[msg.sender], TransactionStatusFailure[msg.sender], block.timestamp);
            payable(ContractAdmin).call{value: PurchasePrice[msg.sender]}("");
            if(TemporaryValue[msg.sender] > TotalCapital - TemporaryValue[msg.sender]){
                LeadInvestor = _LeadInvestor(TemporaryValue[msg.sender], msg.sender);
            }
        } else {
            TokensPurchased[msg.sender] += 0;
            TokensOrdered[msg.sender] += 0;
            TransactionStatusSuccess[msg.sender] += 0;
            TransactionStatusFailure[msg.sender] += 1;
            TokenPurchaseInfo[msg.sender] = TokenInfo(TokensPurchased[msg.sender], TokensOrdered[msg.sender], "Failure", TransactionStatusSuccess[msg.sender], TransactionStatusFailure[msg.sender], block.timestamp);
            payable(msg.sender).call{value: TemporaryValue[msg.sender]}("");
        }
    }
}
