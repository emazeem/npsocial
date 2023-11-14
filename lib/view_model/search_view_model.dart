import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:np_social/model/CaseStudy.dart';
import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/other_user_repo.dart';
import 'package:np_social/model/directories/user_repo.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';

class SearchViewModel extends ChangeNotifier {
  User? userResponse = User();
  UserRepo _userRepo = UserRepo();

  Future search(dynamic data, String token) async {
    dynamic response = await _userRepo.getSearchUsersApi(data, token);
    List _searchResponse = [];
    var userRole =await AppSharedPref.getAuthRole();
    try {
      dynamic requiredResponse=response['data'];
      if ((data['type'] == 'users' || data['type'] == 'all') && requiredResponse['users'].toString()!='[]') {
        print('i am here 0');
        requiredResponse['users'].forEach((item) {
          print('user ${item}');
          item['created_at'] = NpDateTime.fromJson(item['created_at']);
          _searchResponse.add(User.fromJson(item));
        });
      }
      if(userRole == Role.User){
        if ((data['type'] == 'groups' || data['type'] == 'all') && requiredResponse['groups'].toString()!='[]') {
          print('i am here 1');
          requiredResponse['groups'].forEach((item) {
            print('groups ${item}');
            item['created_at'] = NpDateTime.fromJson(item['created_at']);
            _searchResponse.add(Groups.fromJson(item));
          });
        }
      }
      if ((data['type'] == 'case-studies' || data['type'] == 'all') && requiredResponse['case-studies'].toString()!='[]') {
        print('i am here 2');
          requiredResponse['case-studies'].forEach((item) {
          item['created_at'] = NpDateTime.fromJson(item['created_at']);
          item['user'] = User.fromJson(item['user']);
          _searchResponse.add(CaseStudy.fromJson(item));
        });
      }
      if ((data['type'] == 'posts' || data['type'] == 'all') && requiredResponse['posts'].toString()!='[]') {
        print('i am here 3');
        requiredResponse['posts'].forEach((jsonPost) {
          print('post ${jsonPost}');
          jsonPost['created_at'] = NpDateTime.fromJson(jsonPost['created_at']);
          jsonPost['user'] = User.fromJson(jsonPost['user']);
          if (jsonPost['assets'].toString() != '[]') {
            jsonPost['assets']['created_at'] =
                NpDateTime.fromJson(jsonPost['assets']['created_at']);
            jsonPost['assets'] = PostAsset.fromJson(jsonPost['assets']);
          } else {
            jsonPost['assets'] = new PostAsset();
          }
          Post _post = Post.fromJson(jsonPost);
          _searchResponse.add(_post);
        });
      }
      print('object ${_searchResponse}');
      return _searchResponse;
    } catch (e) {
      Utils.toastMessage('${response['message']}');
    }
  }
}
