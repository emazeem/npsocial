import 'package:flutter/foundation.dart';
import 'package:np_social/model/GroupUser.dart';
import 'package:np_social/model/Groups.dart'; 
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/groups_repo.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';



class GroupsViewModel extends ChangeNotifier {
  GroupsRepo _groupsRepo = GroupsRepo();
  List<Groups?> _myGroups = [];
  List<Groups?> _joinedGroups = [];
  List<Groups?> get getGroups => _myGroups;
  List<Groups?> get joinedGroups => _joinedGroups;
  Groups _groupdetails = Groups();
  Groups get getGroupDetails => _groupdetails;

  ApiResponse _groupStatus = ApiResponse();
  ApiResponse get getGroupstatus => _groupStatus;
  ApiResponse _joinedGroupStatus = ApiResponse();
  ApiResponse get getJoinedGroupstatus => _joinedGroupStatus; 
  
  void setGroupDetails(Groups _group) {
    _groupdetails = _group;
    notifyListeners();
  }


  Future fetchGroupDetails(dynamic data, String token) async { 
    try {
      _groupStatus = ApiResponse.loading('Fetching Group Details');
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.groupDetailsbyId, data, token); 
      Groups groupdetails= Groups.fromJson(response['data']); 
      _groupStatus = ApiResponse.completed(groupdetails);
      _groupdetails = groupdetails; 
      notifyListeners();
    } catch (e) {
      _groupStatus = ApiResponse.error('Please try again.!'); 
      notifyListeners();
    }
  }


  

  void setGroups(List<Groups> _noti) {
    _myGroups = _noti;
    notifyListeners();
  }

  Future fetchGroups(dynamic data, String token) async {
    try {
      _groupStatus = ApiResponse.loading('Fetching Groups');
      final response = await _groupsRepo.fetchGroupsApi(data, token);
      List<Groups?> _myNoti = [];
      response['response']['data'].forEach((item) {

        _myNoti.add(Groups.fromJson(item));
      });
      _groupStatus = ApiResponse.completed(_myNoti);
      _myGroups = _myNoti;
      notifyListeners();
    } catch (e) {
      _groupStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  // fetch joined groups
  Future fetchJoinedGroups(dynamic data, String token) async {
    try {
      _joinedGroupStatus = ApiResponse.loading('Fetching Groups');
      final response = await _groupsRepo.fetchGroupsApi(data, token);
      List<Groups?> _myNoti = [];
      List<Groups?> joinedGroups = [];

      response['response']['data'].forEach((item) {
        _myNoti.add(Groups.fromJson(item));
      });
      _myNoti.forEach((element) {
        if (element!.isMember == true) {
          joinedGroups.add(element);
          notifyListeners();
        }
      });

      _joinedGroupStatus = ApiResponse.completed(_myNoti);
      _joinedGroups = joinedGroups;
      notifyListeners();
    } catch (e) {
      _joinedGroupStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  //pull group requests
  List<GroupRequests?> _myGroupRequests = [];
  List<GroupRequests?> get getGroupRequests => _myGroupRequests;

  ApiResponse _status = ApiResponse();
  ApiResponse get getStatus => _status;

  void setGroupRequests(List<GroupRequests> _grouprequests) {
    _myGroupRequests = _grouprequests;
    notifyListeners();
  }

  Future fetchGroupRequests(dynamic data, String token) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      _status = ApiResponse.loading('Fetching Group Requests');
      final response = await _apiServices.getPostAuthApiResponse(
          AppUrl.groupRequestsReceivedToMe, {}, authToken);
      List<GroupRequests?> _grouprequests = [];
      response['data'].forEach((item) {
        _grouprequests.add(GroupRequests.fromJson(item));
      });
      _status = ApiResponse.completed(_grouprequests);
      _myGroupRequests = _grouprequests;
      notifyListeners();
    } catch (e) {
      _status = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  //pull group requests
  List<GroupRequests?> _groupJoinRequests = [];
  List<GroupRequests?> get getGroupJoinRequests => _groupJoinRequests;

  void setGroupJoinRequests(List<GroupRequests> _grouprequests) {
    _myGroupRequests = _grouprequests;
    notifyListeners();
  }

  Future fetchGroupJoinRequests(dynamic data) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      _status = ApiResponse.loading('Fetching Group Requests');
      final response = await _apiServices.getPostAuthApiResponse(
          AppUrl.groupRequestsReceivedToGroup, data, authToken);
      List<GroupRequests?> _grouprequests = [];
      response['data'].forEach((item) {
        _grouprequests.add(GroupRequests.fromJson(item));
      });
      _status = ApiResponse.completed(_grouprequests);
      _myGroupRequests = _grouprequests;
      notifyListeners();
    } catch (e) {
      _status = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  BaseApiServices _apiServices = NetworkApiServices();

  Future sendInvitation(dynamic data) async {
    _status = ApiResponse.loading('Processing...');
    var token = await AppSharedPref.getAuthToken();

    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.inviteFromGroupToUsers, data, token);
      _status = ApiResponse.completed(response);
      notifyListeners();
    } catch (e) {
      _status = ApiResponse.error('Please try again.!');
      notifyListeners();
      return false;
    }
  }

  Future removeMember(dynamic data) async {
    var token = await AppSharedPref.getAuthToken();

    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.removeMember, data, token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future action(dynamic data) async {
    print(data);
    var token = await AppSharedPref.getAuthToken();
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.groupRequestAction, data, token);
      Utils.toastMessage(response['message']);
      return true;
    } catch (e) {
      Utils.toastMessage('Something went wrong. Please try again!');
      return false;
    }
  }

  Future join(dynamic data) async {
    var token = await AppSharedPref.getAuthToken();
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.groupSendJoinRequest, data, token);
      Utils.toastMessage(response['message']);
      return true;
    } catch (e) {
      Utils.toastMessage('Something went wrong. Please try again!');
      return false;
    }
  }

  List<User?> _groupUsers = [];

  List<User?> get getGroupUsers => _groupUsers;

  Future searchGroups(
      String groupName, String searchTab, dynamic data, String token) async {
    if (searchTab == 'all') {
      _status = ApiResponse.loading('Searching Groups');
      await fetchGroups(data, token);
      _myGroups = _myGroups
          .where((element) =>(element!.title!.toLowerCase()).contains(groupName.toLowerCase())).toList();
      notifyListeners();

      _status = ApiResponse.completed(_myGroups);
    } else {
      _joinedGroupStatus = ApiResponse.loading('Searching Groups');
      await fetchJoinedGroups(
          data, token //fetch joined groups to search in joined groups
          );
      _joinedGroups = _joinedGroups
          .where((element) =>
              (element!.title!.toLowerCase()).contains(groupName.toLowerCase()))
          .toList();
      notifyListeners();
      _joinedGroupStatus = ApiResponse.completed(_joinedGroups);
    }
  }

  void setGroupUsers(List<User> _users) {
    _groupUsers = _users;
    notifyListeners();
  }

  Future fetchGroupMembers(dynamic data) async {
    _status = ApiResponse.loading('Fetching Group Requests');
    var authToken = await AppSharedPref.getAuthToken();
    try {
      final response = await _apiServices.getPostAuthApiResponse(
          AppUrl.fetchGroupMembers, data, authToken);
      List<User?> _users = [];
      response['data'].forEach((item) {
        print('user ${item}');
        _users.add(User.fromJson(item));
      });
      _status = ApiResponse.completed(_users);
      _groupUsers = _users;
      notifyListeners();
    } catch (e) {
      _status = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }
  List<User?> _groupTagginUsers = [];

  List<User?> get getGroupTaggingUsers => _groupTagginUsers;

   Future fetchGroupMembersForTagging(dynamic data) async {
    _status = ApiResponse.loading('Fetching Group Requests');
    var authToken = await AppSharedPref.getAuthToken();
    try {
      final response = await _apiServices.getPostAuthApiResponse(
          AppUrl.groupMembersforTagging, data, authToken);
          print ('usertag response ${response}');
      List<User?> _users = [];
      response['data'].forEach((item) {
        print('usertag ${item}');

        _users.add(User.fromJson(item));
      });
      print ('usertagusers ${_users}');
      
      _status = ApiResponse.completed(_users);
      _groupTagginUsers = _users;
      notifyListeners();
    } catch (e) {
      _status = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }
}
