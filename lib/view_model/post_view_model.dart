import 'package:flutter/material.dart';
import 'package:np_social/model/Ad.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/post_repo.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';

class PostViewModel extends ChangeNotifier {
  Post? postResponse = Post();
  PostRepo _postRepo = PostRepo();

  PostViewModel({this.postResponse});

  ApiResponse _status = ApiResponse();
  ApiResponse get getStatus => _status;


  Future fetchTwoMorePosts(dynamic data, String token) async {
    print ('data : ${data}');
    if(data['number']=='0'){ _status = ApiResponse.loading('Fetching posts'); notifyListeners();}
    dynamic response = await _postRepo.getPublicPostApi(data, token);
    try {
      List list = [];
      response['data']['allposts'].forEach((item) {
        item['created_at'] = NpDateTime.fromJson(item['created_at']);
        item['user'] = User.fromJson(item['user']);
        if (item['assets'].toString() != '[]') {
          item['assets']['created_at'] =NpDateTime.fromJson(item['assets']['created_at']);
          item['assets'] = PostAsset.fromJson(item['assets']);
        } else {
          item['assets'] = new PostAsset();
        }
        list.add(Post.fromJson(item));
      });
      if(data['number']=='0'){ _status = ApiResponse.completed(list); notifyListeners();}
      if(response['data']['ad']!=null){
        list.add(Ad.fromJson(response['data']['ad']));
      }
      return list;
    } catch (e) {
      print('error : ${e}');
      _status = ApiResponse.error('Some error occurred!');
      notifyListeners();
    }
  }
  bool _noPost = false;
  bool get getNoPost => _noPost;

  Post? _singlePost = new Post();
  Post? get getSinglePost => _singlePost;


  void setSinglePost(Post post) {
    _singlePost = post;
    notifyListeners();
  }

  Future fetchSinglePost(dynamic data, String token) async {
    _noPost = false;
    _status = ApiResponse.loading('Fetching posts');
    dynamic response = await _postRepo.fetchSinglePostApi(data, token);
    try {
      dynamic item = response['data'];
      Post? post=Post();
      if (item == null){
        _noPost = true;
      }else{
        _noPost = false;
        item['created_at'] = NpDateTime.fromJson(item['created_at']);
        item['user'] = User.fromJson(item['user']);
        if (item['assets'].toString() != '[]') {
          item['assets']['created_at'] = NpDateTime.fromJson(item['assets']['created_at']);
          item['assets'] = PostAsset.fromJson(item['assets']);
        } else {
          item['assets'] = new PostAsset();
        }
        post = Post.fromJson(item);
      }
      _singlePost = post;
      _status = ApiResponse.completed(_singlePost);
      notifyListeners();
    } catch (e) {
      Utils.toastMessage('${response['message']}');
      _status = ApiResponse.error('Some error occurred!');
      notifyListeners();
    }
  }

  Future deletePost(dynamic data, String token) async {
    dynamic response = await _postRepo.deleteMyPostApi(data, token);
    try {
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage('${response['message']}');
    }
  }

  Future reportPost(dynamic data, String token) async {
    dynamic response;
    try {
      response = await _postRepo.reportPostApi(data, token);
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage('${e.toString()}');
    }
    return response;
  }

  Future reportUser(dynamic data, String token) async {
    dynamic response;
    try {
      response = await _postRepo.reportUserApi(data, token);
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage('${e.toString()}');
    }
    return response;
  }

  Future unblockUser(dynamic data, String token) async {
    dynamic response;
    try {
      response = await _postRepo.unblockUserApi(data, token);
      Utils.toastMessage(response['message']);
    } catch (e) {
      Utils.toastMessage('${e.toString()}');
    }
    return response;
  }

  List<Post?> groupPost = [];
  List<Post?> get getGroupPosts => groupPost;



  void setGroupPost(List<Post> posts) {
    groupPost = posts;
    notifyListeners();
  }
  BaseApiServices _apiServices = NetworkApiServices();

  Future fetchGroupPost(dynamic data) async {
    _status = ApiResponse.loading('Fetching posts');
    var authToken = await AppSharedPref.getAuthToken();

    try {
      dynamic response = await _apiServices.getPostAuthApiResponse(AppUrl.groupPost, data, authToken);
      List<Post?> _groupPost = [];
      response['data']['allposts'].forEach((item) {
        print('object ${item}');
        item['created_at'] = NpDateTime.fromJson(item['created_at']);
        item['user'] = User.fromJson(item['user']);
        if (item['assets'].toString() != '[]') {
          item['assets']['created_at'] =
              NpDateTime.fromJson(item['assets']['created_at']);
          item['assets'] = PostAsset.fromJson(item['assets']);
        } else {
          item['assets'] = new PostAsset();
        }
        _groupPost.add(Post.fromJson(item));
      });
      groupPost = _groupPost;
      _status = ApiResponse.completed(_groupPost);
      notifyListeners();
    } catch (e) {
      _status = ApiResponse.error('Some error occurred!');
      notifyListeners();
    }
  }
}

class MyPostViewModel extends ChangeNotifier {
  Post? postResponse = Post();
  PostRepo _postRepo = PostRepo();

  MyPostViewModel({this.postResponse});

  List<Post?> _myPost = [];

  List<Post?> get getMyPosts => _myPost;

  void setMyPosts(List<Post?> friendlist) {
    _myPost = friendlist;
    notifyListeners();
  }

  Future fetchMyPosts(dynamic data, String token) async {
    final response = await _postRepo.getMyPostApi(data, token);
    try {
      List<Post?> myPost = [];
      response['data'].forEach((item) {
        item['created_at'] = NpDateTime.fromJson(item['created_at']);
        item['user'] = User.fromJson(item['user']);
        if (item.containsKey('assets')) {
          if (item['assets'].toString() != '[]') {
            item['assets']['created_at'] =
                NpDateTime.fromJson(item['assets']['created_at']);
            item['assets'] = PostAsset.fromJson(item['assets']);
          } else {
            item['assets'] = new PostAsset();
          }
        } else {
          item['assets'] = new PostAsset();
        }
        myPost.add(Post.fromJson(item));
      });
      _myPost = myPost;
    } catch (e) {
      //Utils.toastMessage('${response['message']}');
    }
    notifyListeners();
  }

  Future fetchMyMorePosts(dynamic data, String token) async {
    final response = await _postRepo.getMyPostApi(data, token);
    List<Post?> myPost = [];
    response['data'].forEach((item) {
      item['created_at'] = NpDateTime.fromJson(item['created_at']);
      item['user'] = User.fromJson(item['user']);
      if (item.containsKey('assets')) {
        if (item['assets'].toString() != '[]') {
          item['assets']['created_at'] =
              NpDateTime.fromJson(item['assets']['created_at']);
          item['assets'] = PostAsset.fromJson(item['assets']);
        } else {
          item['assets'] = new PostAsset();
        }
      } else {
        item['assets'] = new PostAsset();
      }
      myPost.add(Post.fromJson(item));
    });
    return myPost;
  }

  Future createPost(Map data, String token) async {
    try {
      dynamic response;
      response = await _postRepo.createPostApi(data, token);
      return response;
    } catch (e) {
    }
  }
}
