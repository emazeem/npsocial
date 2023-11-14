import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';

class GroupsRepo {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> fetchGroupsApi(data,token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchGroups, data,token);
    try {
      Map res = {
        'response': response,
        'success':true,
      };
      return res;
    }
    catch (e) {
      Map res = {
        'success':false,
        'response': '${e.toString()}',
      };
      return res;
    }
  }

  fetchGroupApi(data, String token) {}

}