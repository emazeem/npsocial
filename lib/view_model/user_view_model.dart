import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/other_user_repo.dart';
import 'package:np_social/model/directories/user_repo.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/near-me.dart';

class UserViewModel extends ChangeNotifier {
  BaseApiServices _apiServices = NetworkApiServices();

  User? userResponse = User();
  UserRepo _userRepo = UserRepo();
  bool _isAboutVisible = false;
  bool _isSInfoVisible = false;
  bool _isWInfoVisible = false;
  bool _isLicenseVisible = false;
  bool _isMarketMessage = false;
  User? _sellerUserData;

  User? get getUser => userResponse;
  bool get aboutVisible => _isAboutVisible;
  bool get sInfoVisible => _isSInfoVisible;
  bool get wInfoVisible => _isWInfoVisible;
  bool get isLicenseVisible => _isLicenseVisible;
  bool get isMarketMessage => _isMarketMessage;
  User? get sellerUserData => _sellerUserData; 
  List<User>? _allUserList = [];
  List<User>? get getAllUserList => _allUserList;

  ApiResponse _status = ApiResponse();
  ApiResponse get getStatus => _status;

  void setUser(User newUser) {
    userResponse = newUser;
    notifyListeners();
  }

  void setChatType(bool value) {
    _isMarketMessage = value;
    notifyListeners();
  }

  void setAboutVisible() {
    _isAboutVisible = !_isAboutVisible;
    notifyListeners();
  }

  void setSocialInfoVisible() {
    _isSInfoVisible = !_isSInfoVisible;
    notifyListeners();
  }

  void setWorkPlaceVisible() {
    _isWInfoVisible = !_isWInfoVisible;
    notifyListeners();
  }

  void setLicenseVisible() {
    _isLicenseVisible = !_isLicenseVisible;
    notifyListeners();
  }

  UserViewModel({this.userResponse});
  Future getUserDetails(dynamic data, String token, {bool isSellerDetails = false}) async {
    dynamic response = await _userRepo.getUserApi(data, token);
    try {
      response['data']['created_at'] = NpDateTime.fromJson(response['data']['created_at']);
      User? us = User.fromJson(response['data']);
      if (isSellerDetails) {
        _sellerUserData = us;
      } else {
        userResponse = us;
      }
      notifyListeners();
    } catch (e) {
      notifyListeners();
      //Utils.toastMessage('${response['message']}');
    }
  }

  ApiResponse fetchFriendStatus = ApiResponse();
  ApiResponse get getFetchFriendStatus => fetchFriendStatus;

  List<User?> _friendsResponse = [];
  List<User?> get getFriends => _friendsResponse;

  void setFriends(List<User> friendlist) {
    _friendsResponse = friendlist;
    notifyListeners();
  }

  Future fetchFriends(dynamic data, String token) async {
    fetchFriendStatus = ApiResponse.loading('Fetching friend');
    try {
      final response = await _userRepo.getFriendsApi(data, token);
      List<User> users = [];
      response['data'].forEach((item) {
        item['unread'] = item['unread'] as int?;
        item['created_at'] = NpDateTime.fromJson(item['created_at']);
        users.add(User.fromJson(item));
      });
      _friendsResponse = users;
      fetchFriendStatus = ApiResponse.completed(_friendsResponse);
      notifyListeners();
    } catch (e) {
      fetchFriendStatus = ApiResponse.error('Please try again.!');
    }
  }



  List<User?> _chatFriends = [];
  List<User?> get getChatFriends => _chatFriends;

  void setChatFriends(List<User> u) {
    _chatFriends = u;
    notifyListeners();
  }

  Future fetchChatFriends() async {
    _status = ApiResponse.loading('Fetching chat friend');
    var authToken = await AppSharedPref.getAuthToken();
    try {
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchChatFriends,{}, authToken);
      List<User> users = [];
      response['data'].forEach((item) {
        item['created_at']=item['created_at']==null?NpDateTime():NpDateTime.fromJson(item['created_at']);
        users.add(User.fromJson(item));
      });
      _chatFriends = users;
      _status = ApiResponse.completed(_chatFriends);
      notifyListeners();
    } catch (e) {
      print('object ${e}');
      _status = ApiResponse.error('Please try again.!');
    }
  }



  //MarketPlace Friend
  ApiResponse fetchMarketFriendStatus = ApiResponse();
  ApiResponse get getFetchFriendStaMarketPlaceFriendStatus =>
      fetchMarketFriendStatus;
  List<User?> _marketPlaceFriendsResponse = [];
  List<User?> get getMarketFriends => _marketPlaceFriendsResponse;
  void setFriendsOfMarketPlace(List<User> friendlist) {
    _marketPlaceFriendsResponse = friendlist;
    notifyListeners();
  }

  Future fetchMarketPlaceFriends(dynamic data, String token) async {
    ApiResponse _fetchFriendStatus = ApiResponse.loading('Fetching friend');
    fetchMarketFriendStatus = _fetchFriendStatus;

    final response =
        await _userRepo.getMarketPlaceFriendsRequestApi(data, token);
    try {
      List<User> users = [];
      response['data'].forEach((item) {
        item['unread'] = item['unread'] as int?;
        item['created_at'] = item['created_at'] == null
            ? null
            : NpDateTime.fromJson(item['created_at']);
        users.add(User.fromJson(item));
      });
      _marketPlaceFriendsResponse = [];
      _marketPlaceFriendsResponse = users;
      _fetchFriendStatus = ApiResponse.completed(_marketPlaceFriendsResponse);
      fetchMarketFriendStatus = _fetchFriendStatus;
      notifyListeners();
    } catch (e) {
      //Utils.toastMessage('${response['message']}');
      _fetchFriendStatus = ApiResponse.error('Please try again.!');
      fetchMarketFriendStatus = _fetchFriendStatus;
    }
  }

  ApiResponse _fetchFriendRequestStatus = ApiResponse();
  ApiResponse get getFetchFriendRequestStatus => _fetchFriendRequestStatus;
  List<User?> _friendsRequestResponse = [];
  List<User?> get getFriendsRequest => _friendsRequestResponse;
  void setFriendsRequestResponse(List<User> friendRequestList) {
    _friendsRequestResponse = friendRequestList;
    notifyListeners();
  }
  Future followRequest(dynamic data)async{
     var authToken = await AppSharedPref.getAuthToken();
   
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.addFollower,data, authToken);
      print(response);
     return response;

  }
  Future unfollowRequest(dynamic data)async{
    print(data);
     var authToken = await AppSharedPref.getAuthToken();
   
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.removeFollower,data, authToken);
      print(response);
     return response;

  }

  Future fetchFriendsRequest(dynamic data, String token) async {
    _fetchFriendRequestStatus =
        ApiResponse.loading('Fetching friends request list');
    final response = await _userRepo.getFriendsRequestApi(data, token);
    try {
      List<User> users = [];
      response['data'].forEach((item) {
        users.add(User.fromJson(item['user_from']));
      });
      _friendsRequestResponse = users;
      _fetchFriendRequestStatus =
          ApiResponse.completed(_friendsRequestResponse);
    } catch (e) {
      Utils.toastMessage('${response['message']}');
      _fetchFriendRequestStatus = ApiResponse.error('Please try again.!');
    }
    notifyListeners();
  }

  List<User?> _searchResponse = [];
  List<User?> get getSearchUser => _searchResponse;
  set setSearchUserResponse(List<User> search) {
    _searchResponse = search;
    notifyListeners();
  }

  List<User?> _allUsers = [];
  List<User?> get getAllUsers => _allUsers;



  void setAllUsers(List<User> _data) {
    _allUsers = _data;
    notifyListeners();
  }

  Future searchAllUsers(String key) async {
    await this.fetchAllUsers();
    _allUsers = _allUsers
        .where((element) =>
            (element!.fname!.toLowerCase() + element.lname!.toLowerCase())
                .contains(key.toLowerCase()))
        .toList();
    notifyListeners();
  }

  Future fetchAllUsers() async {
    var authToken = await AppSharedPref.getAuthToken();
    _allUsers = [];
    try {
      _status = ApiResponse.loading('Fetching list of all users.');
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchAllUsers, {}, authToken);

      List<User?> _users = [];
      response['data'].forEach((item) {
        _users.add(User.fromJson(item));
      });
      _status = ApiResponse.completed(_users);
      _allUsers = _users;
      notifyListeners();
    } catch (e) {
      _status = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }


  List<User?> _fetchFollowers = [];
  List<User?> get getFollowers => _fetchFollowers;


  void setFollowers(List<User> _data) {
    _fetchFollowers = _data;
    notifyListeners();
  }
  Future fetchFollowers(dynamic data) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      _status = ApiResponse.loading('Fetching followers.');
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchFollowers, data, authToken);

      List<User?> _users = [];
      response['data'].forEach((item) {
        _users.add(User.fromJson(item));
      });
      _status = ApiResponse.completed(_users);
      _fetchFollowers = _users;
      notifyListeners();
    } catch (e) {
      _status = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  Future changePassword(dynamic data, String token) async {
    dynamic response = await _userRepo.changePasswordApi(data, token);
    response = jsonDecode(response);
    return response['message'];
  }

  Future messagesMarkAsRead(dynamic data, String token) async {
    dynamic response = await _userRepo.messagesMarkAsReadApi(data, token);
    response = jsonDecode(response);
    return response['message'];
  }

  Future sendFriendRequest(dynamic data, String token) async {
    dynamic response = await _userRepo.sendFriendRequestApi(data, token);
    response = jsonDecode(response);
    return response;
  }

  Future blockUser(dynamic data, String token) async {
    dynamic response = await _userRepo.blockUserApi(data, token);
    response = jsonDecode(response);
    return response;
  }

  Future reportUser(
      dynamic data, String token, String reportDescription) async {
    dynamic response =
        await _userRepo.reportUserApi(data, token, reportDescription);
    response = jsonDecode(response);
    return response;
  }

  Future unfriend(dynamic data, String token) async {
    dynamic response = await _userRepo.unfriendApi(data, token);
    response = jsonDecode(response);
    return response;
  }

  Future acceptOrRejectFriendRequest(dynamic data, String token) async {
    dynamic response =
        await _userRepo.acceptOrRejectFriendRequestApi(data, token);
    try {
      response = jsonDecode(response);
      return response;
    } catch (e) {
      Utils.toastMessage('${response['message']}');
    }
  }

  Future forgetPasswordEmail(dynamic data) async {
    dynamic response = await _userRepo.forgetPasswordEmailApi(data);
    response = jsonDecode(response);
    return response;
  }

  Future createNewPassword(dynamic data) async {
    dynamic response = await _userRepo.createNewPasswordApi(data);
    response = jsonDecode(response);
    return response;
  }

  Future deleteAccount(dynamic data, String token) async {
    dynamic response = await _userRepo.deleteAccountApi(data, token);
    try {
      response = jsonDecode(response);
      return response;
    } catch (e) {
      Utils.toastMessage('${response['message']}');
    }
  }

  bool _isAuthResponse = false;
  bool get isAuth => _isAuthResponse;

  Future ifUserIsAuth(user) async {
    int AuthId = await AppSharedPref.getAuthId();
    _isAuthResponse = (AuthId == user);
    notifyListeners();
  }

  List<User?> _blockedUserResponse = [];
  List<User?> get getBlockedUsers => _blockedUserResponse;

  ApiResponse _fetchBlocklistStatus = ApiResponse();
  ApiResponse get getBlocklistStatus => _fetchBlocklistStatus;
  void setBlockedUserResponse(List<User> blocklist) {
    _blockedUserResponse = blocklist;
    notifyListeners();
  }

  Future blockedUsers(dynamic data, String token) async {
    _fetchBlocklistStatus = ApiResponse.loading('Fetching block list');
    dynamic response;
    _blockedUserResponse = [];
    try {
      response = await _userRepo.getBlockedUsersApi(data, token);

      response['data'].forEach((item) {
        _blockedUserResponse.add(User.fromJson(item));

        _fetchBlocklistStatus = ApiResponse.completed(_blockedUserResponse);
      });
      _fetchBlocklistStatus = ApiResponse.completed(_blockedUserResponse);
      notifyListeners();
    } catch (e) {
      _fetchBlocklistStatus = ApiResponse.error(response['message']);
      Utils.toastMessage('${response['message']}');
    }
  }
}

class OtherUserViewModel extends ChangeNotifier {
  User? otherUserResponse = User();
  OtherUserRepo _otherUserRepo = OtherUserRepo();
  OtherUserViewModel({this.otherUserResponse});
  bool _isAboutVisible = false;
  bool _isSInfoVisible = false;
  bool _isWInfoVisible = false;
  User? get getOtherUser => otherUserResponse;
  bool get aboutVisible => _isAboutVisible;
  bool get sInfoVisible => _isSInfoVisible;
  bool get wInfoVisible => _isWInfoVisible;
  void setAboutVisible() {
    _isAboutVisible = !_isAboutVisible;
    notifyListeners();
  }

  void setSocialInfoVisible() {
    _isSInfoVisible = !_isSInfoVisible;
    notifyListeners();
  }

  void setWorkPlaceVisible() {
    _isWInfoVisible = !_isWInfoVisible;
    notifyListeners();
  }

  void otherUserResponseSetter(User newUser) {
    otherUserResponse = newUser;
    notifyListeners();
  }

  Future getOtherUserDetails(dynamic data, String token) async {
    dynamic response = await _otherUserRepo.getOtherUserApi(data, token);
    try {
      response['data']['created_at'] =
          NpDateTime.fromJson(response['data']['created_at']);
      User? us = User.fromJson(response['data']);
      otherUserResponse = us;
      notifyListeners();
    } catch (e) {
      //Utils.toastMessage('${response['message']}');
    }
  }
}
