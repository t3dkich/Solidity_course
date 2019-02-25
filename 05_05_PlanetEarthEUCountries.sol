pragma solidity >=0.4.22 <0.6.0;

contract PlanetEarth {
    
     struct euCountry {
        string name;
        string continent;
        uint population;
    }
    
    mapping(string => bool) continents;
    mapping(string => string) euCountriesAndCapitals;
    mapping(string => euCountry) keptCountries;
    
    constructor() public {
        euInitialFillings();
        continentsFill();
    }
    
    modifier EU_validCountry(string memory c) {
        require(keccak256(abi.encodePacked('')) != keccak256(abi.encodePacked(euCountriesAndCapitals[c])), 'Not a valid EU country or try with capital first letter (example "Bulgaria"');
        _;
    }
    
    function checkCapital(string memory country)
        public 
        view 
        EU_validCountry(country)
        returns(string memory)
    {
        return euCountriesAndCapitals[country];
    }
    
    function acceptCountry(string memory countryName, string memory continent, uint population)
        public
        payable
        EU_validCountry(countryName)
    {
        keptCountries[countryName] = euCountry(countryName, continent, population);
    }
    
    function showContinents() public pure returns(string memory) {
        return "Africa, Asia, Europe, North America, South America, Antarctica, Australia";
    }
    
    function continentsFill() private {
        continents['Africa'] = true;
        continents['Asia'] = true;
        continents['Europe'] = true;
        continents['North America'] = true;
        continents['SouthAmerica'] = true;
        continents['Antarctica'] = true;
        continents['Australia'] = true;
    }
    
    function euInitialFillings() private {
        euCountriesAndCapitals['Albania'] = 'Tirana';
        euCountriesAndCapitals['Andorra'] = 'Andorra la Vella';
        euCountriesAndCapitals['Austria'] = 'Vienna';
        euCountriesAndCapitals['Azerbaijan'] = 'Baku';
        euCountriesAndCapitals['Belarus'] = 'Minsk';
        euCountriesAndCapitals['Belgium'] = 'Brussels';
        euCountriesAndCapitals['Bosnia and Herzegovina'] = 'Sarajevo';
        euCountriesAndCapitals['Bulgaria'] = 'Sofia';
        euCountriesAndCapitals['Croatia'] = 'Zagreb';
        euCountriesAndCapitals['Cyprus'] = 'Nicosia';
        euCountriesAndCapitals['Czech Republic'] = 'Prague';
        euCountriesAndCapitals['Denmark'] = 'Copenhagen';
        euCountriesAndCapitals['Estonia'] = 'Tillinn';
        euCountriesAndCapitals['Finland'] = 'Helsinki';
        euCountriesAndCapitals['France'] = 'Paris';
        euCountriesAndCapitals['Georgia'] = 'Tbilisi';
        euCountriesAndCapitals['Germany'] = 'Berlin';
        euCountriesAndCapitals['Greece'] = 'Athens';
        euCountriesAndCapitals['Hungary'] = 'Budapest';
        euCountriesAndCapitals['Iceland'] = 'Reykjavik';
        euCountriesAndCapitals['Ireland'] = 'Dublin';
        euCountriesAndCapitals['Italy'] = 'Rome';
        euCountriesAndCapitals['Kazakhstan'] = 'Astana';
        euCountriesAndCapitals['Kosovo'] = 'Pristina';
        euCountriesAndCapitals['Latvia'] = 'Riga';
        euCountriesAndCapitals['Liechtenstein'] = 'Vaduz';
        euCountriesAndCapitals['Lithuania'] = 'Vilnius';
        euCountriesAndCapitals['Luxembourg'] = 'Luxembourg';
        euCountriesAndCapitals['Malta'] = 'Valletta';
        euCountriesAndCapitals['Moldova'] = 'Chisinau';
        euCountriesAndCapitals['Monaco'] = 'Monaco';
        euCountriesAndCapitals['Montenegro'] = 'Podgorica';
        euCountriesAndCapitals['Netherlands'] = 'Amsterdam';
        euCountriesAndCapitals['North Macedonia'] = 'Skopje';
        euCountriesAndCapitals['Norway'] = 'Oslo';
        euCountriesAndCapitals['Poland'] = 'Warsaw';
        euCountriesAndCapitals['Portugal'] = 'Lisbon';
        euCountriesAndCapitals['Romania'] = 'Bucharest';
        euCountriesAndCapitals['Russia'] = 'Moscow';
        euCountriesAndCapitals['San Marino'] = 'San Marino';
        euCountriesAndCapitals['Serbia'] = 'Belgrade';
        euCountriesAndCapitals['Slovakia'] = 'Bratislava';
        euCountriesAndCapitals['Slovenia'] = 'Ljubljana';
        euCountriesAndCapitals['Spain'] = 'Madrid';
        euCountriesAndCapitals['Sweden'] = 'Stockholm';
        euCountriesAndCapitals['Switzerland'] = 'Bern';
        euCountriesAndCapitals['Turkey'] = 'Ankara';
        euCountriesAndCapitals['Ukraine'] = 'Kyiv';
        euCountriesAndCapitals['United Kingdom'] = 'London';
        euCountriesAndCapitals['Vatican City'] = 'Vatican City';
    }
    
}

