import 'package:flutter/foundation.dart';
import 'package:np_social/model/Notification.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/notification_repo.dart';

class NotificationViewModal extends ChangeNotifier {

  Notifications? galleryResponse=Notifications();
  NotificationRepo _notificationRepo=NotificationRepo();
  NotificationViewModal({this.galleryResponse});

  List<Notifications?> _myNotifications=[];
  List<Notifications?> get getMyNotification => _myNotifications;

  ApiResponse _notificationStatus=ApiResponse();
  ApiResponse get getNotificationStatus => _notificationStatus;

  void setMyNotification(List<Notifications> _noti) {
    _myNotifications = _noti;
    notifyListeners();
  }

  Future fetchNotifications(dynamic data,String token) async {
    try{
      _notificationStatus = ApiResponse.loading('Fetching notifications');
      final response =  await _notificationRepo.getNotifications(data,token);
      List<Notifications?> _myNoti=[];
      response['data'].forEach((item) {
        item['created_at']=NpDateTime.fromJson(item['created_at']);
        _myNoti.add(Notifications.fromJson(item));
      });
      _notificationStatus = ApiResponse.completed(_myNoti);
      _myNotifications=_myNoti;
      notifyListeners();

    }catch(e){
      _notificationStatus = ApiResponse.error('Please try again.!');
      notifyListeners();
    }
  }

  Future allNotificationsMarkAsRead(dynamic data,String token) async {
    try{
      final response =  await _notificationRepo.markAllNotificationAsRead(data,token);
    }catch(e){
    }
  }

}