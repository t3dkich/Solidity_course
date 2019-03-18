pragma solidity ^0.5.0;
 
contract SupplyChain {
  address owner;
 
  uint skuCount;
 
  mapping(uint => Item) items;
 
  enum State {ForSale, Sold, Shipped, Received}
  State public state;
 
  struct Item {
      string name;
      uint sku;
      uint price;
      State state;
      address payable seller;
      address payable buyer;
  }
 
    event ForSale(uint sku);
    event Sold(uint sku);
    event Shipped(uint sku);
    event Received(uint sku);
 
  modifier onlyOwner (address _address) { require (msg.sender == owner); _;}
 
  modifier verifyCaller (address _address) { require (msg.sender == _address); _;}
 
  modifier paidEnough(uint _price) { require(msg.value >= _price); _;}
 
  modifier checkValue(uint _sku) {
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }
 
  modifier forSale {
      require(state == State.ForSale);
      _;
  }
  modifier sold {
      require(state == State.Sold);
      _;
  }
  modifier shipped {
      require(state == State.Shipped);
      _;
  }
  modifier received {
      require(state == State.Received);
      _;
  }
 
 
  constructor() public {
    owner = msg.sender;
    skuCount = 0;
  }
 
  function addItem(string memory _name, uint _price) public returns(bool){
    emit ForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
    skuCount = skuCount + 1;
    return true;
  }
 
  function buyItem(uint sku)
    public
    forSale
    paidEnough(items[sku].price)
    checkValue(sku)
    payable
  {
      items[sku].state = State.Sold;
      items[sku].seller.transfer(msg.value);
      emit Sold(sku);
  }
 
  function shipItem(uint sku)
    sold
    verifyCaller(items[sku].seller)
    public
  {
      state = State.Shipped;
      emit Shipped(sku);
  }
 
    function receiveItem(uint sku)
    received
    verifyCaller(items[sku].seller)
    public
  {
      state = State.Received;
      emit Received(sku);
  }
 
  function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }
 
}