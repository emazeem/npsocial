import 'package:flutter/material.dart';
import 'package:np_social/model/Chat.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/chat_repo.dart';
import 'package:np_social/model/directories/post_repo.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ChatViewModel extends ChangeNotifier {
  Chat? chatResponse = Chat();
  ChatRepo chatReo = ChatRepo();

  ChatViewModel({this.chatResponse});

  List<Chat?> _chat = [];
  List<Chat?> get getAllMessages => _chat;

  ApiResponse fetchAllMessageResponse=ApiResponse();
  ApiResponse get getAllMessagesStatus => fetchAllMessageResponse;

  void setAllMessages(List<Chat> ch) {
    _chat = ch;
    notifyListeners();
  }

  Future fetchAllMessages(dynamic data, String token) async {
    print(data);
    ApiResponse _fetchAllMessageResponse=ApiResponse.loading('Fetching chat messages list');

    fetchAllMessageResponse = _fetchAllMessageResponse;
    final response = await chatReo.getAllMessage(data, token);
    try{
      List<Chat?> chat = [];
      response['data']['messages'].forEach((item) {
        print(item);
        item['created_at'] = NpDateTime.fromJson(item['created_at']);
        chat.add(Chat.fromJson(item));
      });
      _chat=chat;

      _fetchAllMessageResponse = ApiResponse.completed(_chat);
      fetchAllMessageResponse = _fetchAllMessageResponse;

      notifyListeners();
    }catch(e){
      Utils.toastMessage('${response['message']}');

      _fetchAllMessageResponse = ApiResponse.error('Please try again.!');
      fetchAllMessageResponse = _fetchAllMessageResponse;

    }
  }

  Future storeMessage(dynamic data, String token) async {
    try {
      final response = await chatReo.storeMessage(data, token);
      return response['data'];
    } catch (e) {
      print(e);
    }
  }
}
