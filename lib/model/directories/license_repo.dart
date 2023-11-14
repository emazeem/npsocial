import 'dart:convert';

import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';

class LicenseRepo {
  BaseApiServices _apiServices = NetworkApiServices();

  Future<dynamic> fetchLicenseApi(data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.fetchLicense, data, token);
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

  Future<dynamic> storeLicenseApi(data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.storeLicense, data, token);
    try {
      Map res = {
        'response': response,
        'success': true,
      };
      return res;
    } catch (e) {
      Map res = {
        'success': false,
        'response': '${e.toString()}',
      };
      return res;
    }
  }

  Future<dynamic> deleteLicenseApi(data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.deleteLicense, data, token);
    try {
      Map res = {
        'response': response,
        'success': true,
      };
      return res;
    } catch (e) {
      Map res = {
        'success': false,
        'response': '${e.toString()}',
      };
      return res;
    }
  }

  Future<dynamic> updateLicenseApi(data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.updateLicense, data, token);
    try {
      Map res = {
        'response': response,
        'success': true,
      };
      return res;
    } catch (e) {
      Map res = {
        'success': false,
        'response': '${e.toString()}',
      };
      return res;
    }
  }
}
