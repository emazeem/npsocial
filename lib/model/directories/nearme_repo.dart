import 'dart:convert';

import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';

class NearmeRepo {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> fetchNearmeUsers(data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.fetchNearmeUser, data, token);
    try {
      Map res = {
        'message': response['message'],
        'data': response['data'],
      };
      return res;
    } catch (e) {
      Map res = {
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }
}
