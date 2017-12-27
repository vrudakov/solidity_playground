                    pragma solidity ^0.4.18;

interface token {
    function    transfer(address _to, uint256 _value) public returns (bool success);
    function    burn( uint256 value ) public returns ( bool success );
    function    balanceOf( address user ) public view returns ( uint256 );
}

contract Crowdsale {
    address     public beneficiary;
    uint        public amountRaised;
    uint        public deadline;
    uint        public price;
    token       public tokenReward;

    mapping(address => uint256) public balanceOf;

    bool    public crowdsaleClosed = false;
    bool    public crowdsaleSuccess = false;

    event   GoalReached(address recipient, uint totalAmountRaised, bool crowdsaleSuccess);
    event   FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function    Crowdsale( address addressOfTokenUsedAsReward) public {
        beneficiary = msg.sender;
        price = 1 ether;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
    * Fallback function
    *
    * The function without name is the default function that is called whenever anyone sends funds to a contract
    */
    function () public payable {
        require(!crowdsaleClosed);

        uint amount = msg.value;
        require((amount % price) == 0);
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
        FundTransfer(msg.sender, amount, true);
    }

    modifier onlyOwner() {
        require(msg.sender == beneficiary);
        _;
    }

    function goalManagment(bool statement) public onlyOwner {
        require(crowdsaleClosed == false);    
        crowdsaleClosed = true;
        crowdsaleSuccess = statement;
        GoalReached(beneficiary, amountRaised, crowdsaleSuccess);
    }

    /**
    * Withdraw the funds
    *
    * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
    * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
    * the amount they contributed.
    */
    function    withdrawalMoneyBack() public {
        uint    amount;

        if (crowdsaleClosed == true && crowdsaleSuccess == false) {
            amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            amountRaised -= amount;
            msg.sender.transfer(amount);
            FundTransfer(msg.sender, amount, false);
        }
    }

    function    withdrawalOwner() public onlyOwner {
        if (crowdsaleSuccess == true && crowdsaleClosed == true) {
            beneficiary.transfer(amountRaised);
            FundTransfer(beneficiary, amountRaised, false);
            burnToken();
        }
    }

    function    burnToken() private {
        uint amount;

        amount = tokenReward.balanceOf(this);
        tokenReward.burn(amount);
    }
}