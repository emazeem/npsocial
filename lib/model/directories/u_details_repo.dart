import 'dart:convert';

import 'package:np_social/model/User.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';

class UserDetailRepo {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> getUserDetailsApi(dynamic data,String token) async {
    try {

      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchUserDetail, data,token);
      Map res = {
        'success':true,
        'message': response['message'],
        'data': response['data']['ambassador_details'],
      };
      return res;
    }
    catch (e) {

      Map<String,dynamic> res = {
        'success':false,
        'data':'',
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }
  Future<dynamic> updateSocialInfoApi(dynamic data,String token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.updateSocialInfo, data,token);
      Map res = {
        'success':true,
        'message': response['message'],
        'data': response['data'],
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
  Future<dynamic> updateLocationApi(dynamic data,String token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.updateLocation, data,token);
      Map res = {
        'success':true,
        'message': response['message'],
        'data': response['data'],
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

  Future<dynamic> updateSpecialityApi(dynamic data,String token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.updateSpeciality, data,token);
      Map res = {
        'success':true,
        'message': response['message'],
        'data': response['data'],
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

  Future<dynamic> getSpecialitiesApi(dynamic data,String token) async {
    try {

      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchSpecialities, data,token);
      Map res = {
        'success':true,
        'message': response['message'],
        'data': response['data'],
      };
      return res;
    }
    catch (e) {

      Map<String,dynamic> res = {
        'success':false,
        'data':'',
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

}