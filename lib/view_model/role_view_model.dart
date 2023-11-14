import 'package:flutter/material.dart';
import 'package:np_social/model/AuthToken.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/directories/user_repo.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleViewModel extends ChangeNotifier {

  int _role=0;
  int get getAuthRole =>_role ;

  void setRole(int role) {
    _role = role;
    notifyListeners();
  }
  Future getRole() async {
    _role = await AppSharedPref.getAuthRole();
    notifyListeners();
  }
}