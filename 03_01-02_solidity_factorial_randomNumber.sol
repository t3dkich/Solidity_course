pragma solidity >=0.4.22 <0.6.0;

contract Factorial {
    
    /*
		Making factorial by loop is problematic because it has a real chance for the number "n" to be pretty large number so the contract can run out of Gas.
		That way is cheaper than doing it by recursion.
    */
    function byLoop(uint n) pure public returns(uint) {
        uint number = 1;
        
        for (uint i = 2; i <= n; i++) {
            number *= i;
        }
        
        return number;
    }
    
    /*
		Making factorial by recursion is problematic because it has a real chance for the number "n" to be pretty large number so the contract can run out of Gas.
		That way is more expensive than doing it by loop because of calling "byRecursion" function many times.
    */
    function byRecursion(uint n) pure public returns(uint){
        if (n == 1) {
            return n;
        } else {
            return n * byRecursion(n - 1);
        }
    }
}

contract RandomNumber {

	/*
		Problem here can accure if using current datetime because different nodes and miners are set on different timezone so different result can be generated for '_number' variable.
	*/
	function randomNumber() view public returns(uint16) {
        uint _random;
        for (uint i = 2; i <= 20; i++) {
            _random ^= (((block.timestamp * block.difficulty / gasleft())) * i) % 114;
        }
        return uint16(_random);
    }
}