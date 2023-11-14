import 'dart:async';

import 'package:flutter/material.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/Comment.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/comment_repo.dart';
import 'package:np_social/model/directories/post_repo.dart';
import 'package:np_social/utils/Utils.dart';

class CommentViewModel extends ChangeNotifier {
  Comment? commentResponse = Comment();
  CommentRepo _commentRepo = CommentRepo();

  CommentViewModel({this.commentResponse});

  List<Comment?> _allComments = [];
  List<Comment?> get getAllComments => _allComments;
  bool _isReplying = false;
  bool get isReplying => _isReplying;
  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;
  bool _isReplyLoading = false;
  bool get isReplyLoading => _isReplyLoading;
  bool _isCommentLoading = false;
  bool get isCommentLoading => _isCommentLoading;
  int _choosedIndex = 0;
  int get choosedIndex => _choosedIndex;
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  Comment? _replyingComment;
  Comment? get replyingCommentData => _replyingComment;
  Comment? _editComment;
  Comment? get editCommentData => _editComment;

  ApiResponse fetchAllCommentStatus = ApiResponse();
  ApiResponse get getAllCommentStatus => fetchAllCommentStatus;

  void setAllComments(List<Comment> comments) {
    _allComments = comments;
    notifyListeners();
  }



  void setReplyValue(Comment? comment) {
    _isReplying = true;
    if (_isReplying) {
      _replyingComment = comment;
    } else {
      _replyingComment = null;
    }
    notifyListeners();
  }

  void setReply() {
    _isReplying = !_isReplying;
    notifyListeners();
  }

  void removeCancel() {
    _isReplying = false;
    notifyListeners();
  }

  void setReplyingoff() {
    _isReplying = false;
    notifyListeners();
  }

  void setEditValue(Comment? comment, {bool isEditValue = true}) {
    _isEditing = isEditValue;
    if (_isEditing) {
      _editComment = comment;
    } else {
      _editComment = null;
    }
    notifyListeners();
  }

  void setEdit() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  Future fetchAllComments(dynamic data, String token) async {
    fetchAllCommentStatus = ApiResponse.loading('Fetching comments..');
    try {
      final response = await _commentRepo.getAllCommentsApi(data, token);
      List<Comment> allComments = [];
      response['data'].forEach((item) {
        print(item);
        item['created_at'] = NpDateTime.fromJson(item['created_at']);
        item['updated_at'] = NpDateTime.fromJson(item['updated_at']);
        item['user'] = User.fromJson(item['user']);
        if (item['parent_id'] == null) {
          allComments.add(Comment.fromJson(item));
        }
      });
      _allComments = allComments;
      notifyListeners();
      fetchAllCommentStatus = ApiResponse.completed(_allComments); 
      notifyListeners();
    } catch (e) {
      fetchAllCommentStatus = ApiResponse.error('Please try again.!');
    }
  }

  Future storeComments(dynamic data, String token) async {
    _isEnabled = true;
    dynamic response;
    response = await _commentRepo.storeCommentApi(data, token);
    _isEnabled = false;
    notifyListeners();
    return response;
  }

  Future deleteComment(dynamic data, String token) async {
    _isCommentLoading = true;
    _isEnabled = true;
    final response = await _commentRepo.deleteCommentApi(data, token);
    print(response);
    _isCommentLoading = false;
    _isEnabled = false;
    notifyListeners();
    return response;
  }

  Future editComment(dynamic data, String token) async {
    final response = await _commentRepo.editCommentApi(data, token);
    return response;
  }

  Future fetchCommentReply(dynamic commentId, String token, int index) async {
    _choosedIndex = index;
    final response = await _commentRepo.getCommentReplyApi(commentId, token);
    return response;
  }

  void disposeData() {
    _isEditing = false;
    _editComment = null;
  }

  Function debounce(Function func,
      [Duration duration = const Duration(milliseconds: 300)]) {
    Timer? timer;

    return () {
      if (timer != null) {
        timer!.cancel();
      }

      timer = Timer(duration, () {
        func();
      });
    };
  }
}
