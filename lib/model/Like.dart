
import 'package:np_social/model/User.dart';

class Like {
  final int? id;
  final int? user_id;
  final int? post_id;
  final User? user;

  Like({
    this.id,
    this.user_id,
    this.post_id,
    this.user,
  });
  factory Like.fromJson(Map<String, dynamic> json) {
    return Like(
      id:json['id'] as int?,
      user_id:json['user_id'] as int?,
      post_id:json['post_id'] as int?,
      user:json['user'] as User?,
    );
  }
}