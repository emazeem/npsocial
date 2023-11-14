import 'package:flutter/material.dart';
import 'package:np_social/model/Friend.dart';
import 'package:np_social/model/Like.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/Comment.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/comment_repo.dart';
import 'package:np_social/model/directories/friend_repo.dart';
import 'package:np_social/model/directories/like_repo.dart';
import 'package:np_social/model/directories/post_repo.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';

class FriendViewModel extends ChangeNotifier {
  ActionButtonStatus? friendResponse = ActionButtonStatus();
  FriendRepo _friendRepo = FriendRepo();


  ActionButtonStatus? actionBtnStatus = new ActionButtonStatus();
  ActionButtonStatus? get getActionButtonStatus => actionBtnStatus;

  setActionButtonStatus(ActionButtonStatus _actionBtnStatus) {
    actionBtnStatus = _actionBtnStatus;
    notifyListeners();
  }



  Future fetchActionButtonStatus(dynamic data, String token) async {
    dynamic response = await _friendRepo.friendStatusApi(data, token);

    try{
      ActionButtonStatus _actionBtnStatus = new ActionButtonStatus();
      print('action button status ${response}');
      dynamic friendResponse = response['data']['friend'];
      if(friendResponse==null){
        _actionBtnStatus.showSendRequestBtn = true;
      }else{
        _actionBtnStatus.showSendRequestBtn = false;
        if (friendResponse['from'].toString() == data['auth_user']) {
          if(friendResponse['status'] == '0'){
            _actionBtnStatus.showCancelFriendRequestBtn = true;
          }else{
            _actionBtnStatus.showCancelFriendRequestBtn = false;
          }
        } else {
          _actionBtnStatus.showCancelFriendRequestBtn = false;
        }
        if (friendResponse['status'] == '0') {
          if (friendResponse['to'].toString() == data['auth_user']) {
            _actionBtnStatus.showAcceptRejectBtn = true;
          }
        }
        if (friendResponse['status'] == '1') {
          _actionBtnStatus.showUnfriendBtn = true;
        } else {
          _actionBtnStatus.showUnfriendBtn = false;
        }
      }
      if(response['data']['is_auth_org']==true){
        _actionBtnStatus.showAcceptRejectBtn=false;
        _actionBtnStatus.showSendRequestBtn=false;
        _actionBtnStatus.showCancelFriendRequestBtn=false;
        _actionBtnStatus.showUnfriendBtn=false;
      }
      _actionBtnStatus.showUnFollowBtn=false;
      _actionBtnStatus.showFollowBtn=false;
      if(response['data']['is_auth_user']==true && response['data']['other_is_org']==true){
        _actionBtnStatus.showFollowBtn=!response['data']['is_follower'];
        _actionBtnStatus.showUnFollowBtn=response['data']['is_follower'];
      }

      actionBtnStatus=_actionBtnStatus;
    }catch(e){
      print('Error');
    }

    notifyListeners();
  }




  bool? _followStatus;
  bool? get getFollowStatus => _followStatus;


  setFollowStatus(bool? status) {
    _followStatus = status;
    notifyListeners();
  }
  BaseApiServices _apiServices = NetworkApiServices();

  ApiResponse _status = ApiResponse();
  ApiResponse get getStatus => _status;

  Future fetchFollowStatus(dynamic data) async {
    bool? status;
    _status = ApiResponse.loading('Fetching follow status');
    var authToken = await AppSharedPref.getAuthToken();
    _followStatus=status;
    notifyListeners();
    final response = await _apiServices.getPostAuthApiResponse(AppUrl.followStatus, data, authToken);
    try{
      _followStatus=response['data'];
      _status = ApiResponse.completed(_followStatus);
      notifyListeners();
    }catch(e){
      _status = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

}

class ActionButtonStatus {
  bool? showSendRequestBtn;
  bool? showCancelFriendRequestBtn;
  bool? showUnfriendBtn;
  bool? showAcceptRejectBtn;
  bool? showFollowBtn;
  bool? showUnFollowBtn;

  ActionButtonStatus({
    this.showSendRequestBtn,
    this.showCancelFriendRequestBtn,
    this.showUnfriendBtn,
    this.showAcceptRejectBtn,
  });
}
