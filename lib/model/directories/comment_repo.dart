import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';

class CommentRepo {
  BaseApiServices _apiServices = NetworkApiServices();
  Future<dynamic> getAllCommentsApi(data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.fetchAllComments, data, token);
    try {
      Map res = {
        'message': response['message'],
        'data': response['data']['fetch_comment'],
      };
      return res;
    } catch (e) {
      Map res = {
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

  Future<dynamic> storeCommentApi(data, token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.storeComments, data, token);
      Map res = {
        'message': response['message'],
        'success': true,
        'data': response['data']['comment'],
      };
      return res;
    } catch (e) {
      Map res = {
        'success': false,
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

  //Delete Comment
  Future<dynamic> deleteCommentApi(data, token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.deleteComments, data, token);
      Map res = {
        'message': response['message'],
        'success': true,
        'data': response['data'],
      };
      return res;
    } catch (e) {
      Map res = {
        'success': false,
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

  //Add Reply
  Future<dynamic> getCommentReplyApi(data, token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.fetchReplyComments, data, token);
      Map res = {
        'message': response['message'],
        'success': true,
        'data': response['data']['comments'],
      };
      return res;
    } catch (e) {
      Map res = {
        'success': false,
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

  //Edit Comment
  Future<dynamic> editCommentApi(data, token) async {
    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(
          AppUrl.editComments, data, token);
      Map res = {
        'message': response['message'],
        'success': true,
        'data': response['data']['comment'],
      };
      return res;
    } catch (e) {
      Map res = {
        'success': false,
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }
}
