// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;


contract Twitter{
   struct Tweet{
    uint256 id;
    address author;
    string content;
    uint256 timestamp;
    uint256 likes;
   }

    uint32 public MAX_TWEET_LENGTH = 380;
    mapping (address=>Tweet[]) public  tweets;
    address public owner;

    constructor () {
        owner = msg.sender;
    } 
    modifier onlyOwner{
        require(owner==msg.sender, "You are not the owner");
        _;
    }
    function changeTweetLength(uint16 newTweetLength)public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }
    function createTweets(string memory _tweet) public {
        require(bytes(_tweet).length<=MAX_TWEET_LENGTH, "Tweet is too long");

        Tweet memory newTweets = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });
        tweets[msg.sender].push(newTweets);
    }
    function likeTweet(address author, uint256 id) external {
        require(tweets[author][id].id == id, "There is no tweet exist with this id");
        tweets[author][id].likes++;
    }
    function unlikeTweet(address author, uint256 id) external {
        require(tweets[author][id].id == id, "There is no tweets exist with this id");
        require(tweets[author][id].likes>0, "This post has no likes");
        tweets[author][id].likes--;
    }

    function getTweet( uint _i) public view returns (Tweet memory){
        return tweets[msg.sender][_i];
    }
    function getAllTweets(address _owner) public  view returns(Tweet[] memory){
        return tweets[_owner];
    }
}