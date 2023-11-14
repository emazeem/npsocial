import 'dart:convert';

import 'package:np_social/model/User.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';

class FriendRepo {
  BaseApiServices _apiServices = NetworkApiServices();
  Future<dynamic> friendStatusApi(data,token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.friendStatus, data,token);
      Map res = {
        'message': response['message'],
        'data': response['data'],
      };
      return res;
    }
    catch (e) {
      Map res = {
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }
}