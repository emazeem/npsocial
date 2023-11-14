import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';

class Comment {
  final int? id;
  final int? user_id;
  final int? post_id;
  final String? text;
  final int? parentId;
  final NpDateTime? created_at;
  final NpDateTime? updated_at;
  final User? user;
  List<Comment> replies = [];
  bool isReplyOpen = false;
  bool isReplyLoading = false;
  int? replies_count;

  void setReplies() {
    replies = [
      Comment(
          id: 1,
          post_id: 1,
          text: 'asdas',
          user: User(id: 1, fname: 'asd', lname: '123')),
      Comment(
          id: 1,
          post_id: 1,
          text: 'sdfsdf',
          user: User(id: 1, fname: '234', lname: 'asd')),
      Comment(
          id: 1,
          post_id: 1,
          text: 'sdf',
          user: User(id: 1, fname: '346', lname: 'asd')),
    ];
  }

  Comment({
    this.id,
    this.user_id,
    this.post_id,
    this.parentId,
    this.text,
    this.created_at,
    this.updated_at,
    this.user,
    this.replies_count,
  });
  factory Comment.fromJson(Map<dynamic, dynamic> json) {
    return Comment(
      id: json['id'] as int?,
      parentId: json['parent_id'] as int?,
      user_id: json['user_id'] as int?,
      post_id: json['post_id'] as int?,
      text: json['text'] as String?,
      created_at: json['created_at'] as NpDateTime,
      updated_at: json['updated_at'] as NpDateTime,
      user: json['user'] as User?,
      replies_count: json['replies_count'] as int?,
    );
  }
}
