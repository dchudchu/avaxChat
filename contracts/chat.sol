pragma solidity 0.8.19; 
// SPDX-License-Identifier: MIT

contract AvaxChat {

    //Defining struct types
    struct user {
        string name;

        friend[] friendList;
    }

    struct friend {
        address pubkey;
        string name;
    }

    struct message {
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct allUsers {
        string name;
        address accountAddress;
    }

    allUsers[] getAllUsers;

    mapping (address => user) userList;
    mapping (bytes32 => message[]) allMessages;

    //Check Users exist

    function checkUser(address pubkey) public view returns(bool) {
        return bytes(userList[pubkey].name).length > 0;
    }

    //Create new account
    function createAccount(string calldata name) external {
        require(checkUser(msg.sender) == false, "User already exists");
        require(bytes(name).length > 0, "Please enter a username");
        userList[msg.sender].name = name;
        
        getAllUsers.push(allUsers(name, msg.sender));
    }

    //Find usernames
    function getUserName (address pubkey) external view returns(string memory){
        require(checkUser(pubkey) == true, string(abi.encodePacked("No account registered for ", pubkey)));
        return userList[pubkey].name;
    }

            //Identifier for different conversations
    function _getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32){
        if(pubkey1 < pubkey2){
            return keccak256(abi.encodePacked(pubkey1, pubkey2));
        } else {
        return keccak256(abi.encodePacked(pubkey2, pubkey1));
        }
    }

    //Send messages
    function sendMessage (address friend_key, string calldata _msg) external {
        require(checkUser(msg.sender), "Create an account before sending messages");
        require(checkUser(friend_key), "Friend's address is not registered");
        require(checkFriend(msg.sender, friend_key), "ERROR: Not friends");

        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        message memory newMsg = message(msg.sender, block.timestamp, _msg);

        allMessages[chatCode].push(newMsg);
    }

    //Read Messages

    function readMessage (address friend_key) external view returns(message[] memory) {
        bytes32 chatCode = _getChatCode(msg.sender, friend_key);
        return allMessages[chatCode];
    }

    //Add Friends
    function addFriend(address friendkey, string calldata name) external {
        require(checkUser(friendkey), "Friend address is not regisetered");
        require(checkUser(msg.sender), "Please create an account before trying to add friends");
        require(msg.sender != friendkey, "User cannot add themselves");
        require(checkFriend(msg.sender, friendkey) == false, "User already added");

        _addFriend(msg.sender, friendkey, name);
        _addFriend(friendkey, msg.sender, userList[msg.sender].name);
    }

    //Check friends
    //Keep in mind the lengths of each friends list, for loop may not iterate properly
    function checkFriend(address senderkey, address friendkey) internal view returns(bool) {
        friend[] memory friends = userList[senderkey].friendList;
        for (uint256 i = 0; i < friends.length; i++) {
            if (friends[i].pubkey == friendkey) {
                return true;
            }
        }
        return false;
    }

    //Internal Add Friends Function
    function _addFriend (address sender, address friend_key, string memory name) internal {
        friend memory newFriend = friend(friend_key, name);
        userList[sender].friendList.push(newFriend);
    }

    //Get Friendslist

    function getFriendList() external view returns(friend[] memory) {
        return userList[msg.sender].friendList;
    }

    function getAllAppUsers() public view returns(allUsers[] memory) {
        return getAllUsers;
    }

}

