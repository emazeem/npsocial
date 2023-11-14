import 'package:flutter/material.dart';
import 'package:np_social/model/AuthToken.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/directories/user_repo.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenViewModel extends ChangeNotifier {

  AuthToken? _authTokenResponse=AuthToken();
  AuthToken? get getToken => _authTokenResponse;

  set setTokenResponse(AuthToken authToken) {
    _authTokenResponse = authToken;
    notifyListeners();
  }

  Future getAuthToken() async {

    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString(Constants.authToken) ?? '';
    notifyListeners();
     _authTokenResponse=AuthToken.fromJson({'token':'${token.toString()}'});
    notifyListeners();
  }
}