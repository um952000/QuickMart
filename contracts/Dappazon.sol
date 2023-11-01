// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0 <0.9.0;

contract Dappazon {
    address public owner; //a state variable.

    // arbitrary data type for our item........
    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 time;
        Item item;
    }

    //creating mapping for Item struct to its differnet values(items)
    mapping(uint256 => Item) public items;

    //mapping for orderCount
    mapping(address => uint256) public orderCount;

    //mapping for quantity of each no of order..........
    mapping(address => mapping(uint256 => Order)) public orders;

    event Buy(address buyer, uint256 orderId, uint256 itemId);
    event List(string name, uint256 cost, uint256 quantity);

    // restrictiong list to only to the owner of the marketplace
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() {
        owner = msg.sender; // this is the person who is deploying the smart contract
    }

    //LIST Products

    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        //Create item struct (creating a new item)

        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );

        //Save item struct(Item) to blockchain

        items[_id] = item; // an array of differnet items

        //Emit an event in the blockchain
        emit List(_name, _cost, _stock);
    }

    //Buy Products
    //payble is used to send the ether
    function buy(uint256 _id) public payable {
        //Fetch item
        Item memory item = items[_id];

        //Require enough ether to buy an item
        require(msg.value >= item.cost);

        //Create and order (each order has unique timestamp related to it)
        Order memory order = Order(block.timestamp, item);

        //Add order for user
        orderCount[msg.sender]++; //<-- Order ID
        orders[msg.sender][orderCount[msg.sender]] = order;

        // Subtract stock
        items[_id].stock = item.stock - 1;

        //Emit event
        emit Buy(msg.sender, orderCount[msg.sender], item.id);
    }

    //Withdraw funds

    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success);
    }
}

//........................................
