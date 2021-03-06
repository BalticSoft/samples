pragma solidity >=0.6.0;
pragma AbiHeader expire;

import "13_Interfaces.sol";

// This contract implements 'IBankClient' interface.
contract BankClient is IBankClient {

    address bankCollector;
    uint debtAmount;

    constructor(address _bankCollector) public {
        require(tvm.pubkey() != 0);
        require(msg.pubkey() == tvm.pubkey());
        tvm.accept();
        bankCollector = _bankCollector;
    }

    // Modifier that allows public function to be called only by message signed with owner's pubkey.
    modifier onlyOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey());
        tvm.accept();
        _;
    }

    // Modifier that allows public function to accept external calls only from bank collecor.
    modifier onlyCollector {
        // Runtime function to obtain message sender address.
        require(msg.sender == bankCollector, 101);

        // Runtime function that allows contract to process inbound messages spending
        // its own resources (it's necessary if contract should process all inbound messages,
        // not only those that carry value with them).
        tvm.accept();
        _;
    }

    function demandDebt(uint amount) public override onlyCollector {
        IBankCollector(msg.sender).receivePayment{value: amount}();
    }

    function obtainDebtAmount() public onlyOwnerAndAccept {
        IBankCollector(bankCollector).getDebtAmount{value: 0.5 ton}();
    }

    function setDebtAmount(uint amount) public override onlyCollector {
        debtAmount = amount;
    }

    /*
     * Public Getters
     */
    function getDebtAmount() public view returns (uint d) {
        return debtAmount;
    }
}
