// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IProfile {
    struct UserProfile{
        string displayName;
        string bio;
    }
    function getProfile(address _user ) external  view returns (UserProfile memory);
}

contract Twitter is Ownable {
   struct Tweet{
    uint256 id;
    address author;
    string content;
    uint256 timestamp;
    uint256 likes;
   }
   IProfile profileContract;

    constructor(address _profileContract) Ownable(msg.sender) {
        profileContract = IProfile(_profileContract);
    }
    
      uint32 public MAX_TWEET_LENGTH = 380;
    mapping (address=>Tweet[]) public  tweets;

    event TweetCreated(uint256 id, address author, string content, uint256 timestamp );
    event TweetLiked(address liker, address tweetAuthor, uint256 id, uint256 newLikedCount);
    event TweetUnliked(address unliker, address tweetAuthor, uint256 id, uint256 newLikedCount);

    modifier onlyRregistered(){
        IProfile.UserProfile memory userProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(userProfileTemp.displayName).length>0, "USER NOT REGISTERED");
        _;
    }

    function changeTweetLength(uint16 newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }
    function createTweets(string memory _tweet) public onlyRregistered{
        require(bytes(_tweet).length<=MAX_TWEET_LENGTH, "Tweet is too long");

        Tweet memory newTweets = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });
        tweets[msg.sender].push(newTweets);

        emit TweetCreated(newTweets.id, newTweets.author,newTweets.content, newTweets.timestamp);
    }
    function likeTweet(address author, uint256 id) external onlyRregistered{
        require(tweets[author][id].id == id, "There is no tweet exist with this id");
        tweets[author][id].likes++;
        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }
    function unlikeTweet(address author, uint256 id) external onlyRregistered{
        require(tweets[author][id].id == id, "There is no tweets exist with this id");
        require(tweets[author][id].likes>0, "This post has no likes");
        tweets[author][id].likes--;
        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }

    function getTweet( uint _i) public view returns (Tweet memory){
        return tweets[msg.sender][_i];
    }
    function getAllTweets(address _owner) public  view returns(Tweet[] memory){
        return tweets[_owner];
    }
    function getAllLikes(address author)external view returns(uint){
        uint256 totalLikes = 0;
        for(uint i = 0; i<tweets[author].length; i++){
            totalLikes += tweets[author][i].likes;
        }
        return  totalLikes;
    }
}