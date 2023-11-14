import 'package:flutter/material.dart';
import 'package:np_social/model/Conferences.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/utils.dart';

import '../model/services/BaseApiServices.dart';

class ConferenceViewModel extends ChangeNotifier {
  BaseApiServices _apiServices = NetworkApiServices();

  ApiResponse _status = ApiResponse();
  ApiResponse get getStatus => _status;

  Future createConference(dynamic data) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      final response = await _apiServices.getPostAuthApiResponse(AppUrl.storeConference, data, authToken);
      return response;
    } catch (e) {
      return false;
    }
  }

  Future fetchEventsByDate(dynamic data) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.fetchEventsByDate, data, authToken);
      return response;
    } catch (e) {
      return false;
    }
  }
  Future fetchPollsOfEvent(dynamic data) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.eventsPollFetch, data, authToken);
      
      return response['data'];
    } catch (e) {
      return false;
    }
  }

  Future fetchEventCount(dynamic data) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.fetchCountOfEventsByMonth, data, authToken);
      return response;
    } catch (e) {
      return false;
    }
  }
 Future deleteConference(dynamic data, String token) async {
    dynamic response = await NetworkApiServices().getPostAuthApiResponse(AppUrl.deleteConferencs,data, token);
    try {
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage('${response['message']}');
    }
  }

  Future storeeventCount(dynamic data) async {
    var authToken = await AppSharedPref.getAuthToken();
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.storeEventCount, data, authToken);
      return response;
    } catch (e) {
      return false;
    }
  }
}
