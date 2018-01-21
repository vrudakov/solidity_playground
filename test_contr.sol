pragma solidity ^0.4.18;


contract safeMath {

	function add( uint256 x, uint256 y ) internal pure returns ( uint256 z ) {
		assert( ( z = x + y ) >= x );
	}

	function sub( uint256 x, uint256 y ) internal pure returns ( uint256 z ) {
		assert( ( z = x - y ) <= x );
	}
}

contract Play is safeMath {

	uint public allMoney;

	mapping(address => uint256) public 	balanceOf;

	event FundTransfer(address backer, uint amount);
	event InternalTransfer(address from, address to, uint amount);

	function () payable public {
		uint amount = msg.value;
		balanceOf[msg.sender] = add(balanceOf[msg.sender], amount);
		allMoney = add(amount, allMoney);
	}

	function withdrawal (uint howMany) public {
		if (balanceOf[msg.sender] > 0 && balanceOf[msg.sender] >= howMany) {
			if (howMany > 0) {
				balanceOf[msg.sender] -= howMany;
				if (msg.sender.send(howMany)) {
					FundTransfer(msg.sender, howMany);
				} else {
					balanceOf[msg.sender] += howMany;
                }
            }
   		}
   	}

   	function sendToFriend (address friend, uint howMany) public {
		if (balanceOf[msg.sender] > 0 && balanceOf[msg.sender] >= howMany) {
			balanceOf[msg.sender] -= howMany;
			balanceOf[friend] += howMany;
			InternalTransfer(msg.sender, friend, howMany);
		}
   	}
}


