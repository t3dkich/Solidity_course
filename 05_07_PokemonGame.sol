pragma solidity >=0.4.22 <0.6.0;

contract PokemonGame {
    
    mapping(uint16 => string) knownPokemons;
    mapping(address => mapping(uint16 => bool)) userPokemons;
    mapping(address => uint) lastCaught;
    mapping(uint16 => address[]) eachType_allPlayers;
    
    constructor() public {
        _pokemonFilling();
    }
    
    modifier notCaughtThisPokemonYet(uint16 pokeIndex) {
        require(userPokemons[msg.sender][pokeIndex] == false, 'You have caught this pokemon before!');
        _;
    }
    
    modifier after15seconds {
        if (lastCaught[msg.sender] != 0) {
            require(lastCaught[msg.sender] + 15 seconds < now, 'Must wait 15 seconds before catch one more pokemon!');
        }
        _;
    }
    
    modifier hasCaughtEver {
        require(lastCaught[msg.sender] > 0, 'This user has no pokemons!');
        _;
    }
    
    function catchPokemon(uint16 pokeIndex) 
        public
        notCaughtThisPokemonYet(pokeIndex)
        after15seconds
    {
        userPokemons[msg.sender][pokeIndex] = true;
        lastCaught[msg.sender] = now;
        eachType_allPlayers[pokeIndex].push(msg.sender);
    }
    
    function listPokemonTypeByUser(uint16 pokeIndex) public view returns(address[] memory) {
        return eachType_allPlayers[pokeIndex];
    }
    
    function listUserPokemons(address user) 
        public 
        view
        hasCaughtEver
        returns(string memory)
    {
        string memory temp = '';
        for (uint16 i = 0; i < 32; i++) {
            if (userPokemons[user][i]) {
                if (keccak256(abi.encodePacked(temp)) == keccak256(abi.encodePacked(''))) {
                    temp = string(abi.encodePacked(knownPokemons[i]));
                } else {
                    temp = string(abi.encodePacked(temp, ', ', knownPokemons[i]));
                }
            }
        }
        return temp;
    }
    
    function _pokemonFilling() private {
        string[32] memory pokes = 
            [
            'Bulbasaur', 'Ivysaur', 'Venusaur', 'Charmander', 'Charmeleon', 'Charizard', 'Squirtle', 'Wartortle',
            'Blastoise', 'Caterpie', 'Metapod', 'Butterfree', 'Weedle', 'Kakuna', 'Beedrill', 'Pidgey', 'Pidgeotto', 'Pidgeot', 'Rattata', 'Raticate',
            'Spearow', 'Fearow', 'Ekans', 'Arbok', 'Pikachu', 'Raichu', 'Sandshrew', 'Sandslash', 'NidoranF', 'Nidorina', 'Nidoqueen', 'NidoranM'
            ];
        
        for (uint16 i = 0; i < 32; i++) {
            knownPokemons[i] = pokes[i];
        }
    }
}