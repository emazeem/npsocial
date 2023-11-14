import 'package:flutter/material.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import '../model/services/BaseApiServices.dart';

class AdsViewModel extends ChangeNotifier {
  BaseApiServices _apiServices = NetworkApiServices();

  Future registerClick(dynamic data,) async {
    var token = await AppSharedPref.getAuthToken();
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.registerImpression, data, token);
      print(response);
    } catch (e) {
      return false;
    }
  }

  Future registerImpression(dynamic data) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.registerImpression, data, authToken);
      return response;
    } catch (e) {
      print(e);
      Utils.toastMessage('Something went wrong');
    }
  }
}
