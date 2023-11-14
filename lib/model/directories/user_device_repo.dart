import 'dart:convert';

import 'package:np_social/model/User.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';

class UserDeviceRepo {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> storeDeviceIdApi(data,token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.storeDeviceId, data,token);
      Map res = {
        'message': response['message'],
        'success':true,
        'data': response['data']['comment'],
      };
      return res;
    }
    catch (e) {
      Map res = {
        'success':false,
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

  Future<dynamic> removeDeviceIdApi(data,token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.removeDeviceId, data,token);
      Map res = {
        'message': response['message'],
        'success':true,
        'data': response['data']['comment'],
      };
      return res;
    }
    catch (e) {
      Map res = {
        'success':false,
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

}