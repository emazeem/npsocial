import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';

class GroupRequests {
  int? id;
  int? groupId;
  int? userId;
  String? type;
  int? from;
  String? status;
  Groups? group;
  User? user;
  User? fromUser;

  GroupRequests({
    this.id,
    this.groupId,
    this.userId,
    this.type,
    this.from,
    this.status,
    this.group,
    this.user,
    this.fromUser,
  });

  factory GroupRequests.fromJson(Map<String, dynamic> json){

    return GroupRequests(
      id: json["id"] as int?,
      groupId: json["group_id"] as int?,
      userId: json["user_id"] as int?,
      type: json["type"] as String?,
      from: json["from"] as int?,
      status: json["status"] as String?,
      group: Groups.fromJson(json["group"]) as Groups?,
      user: User.fromJson(json["user"]) as User?,
      fromUser: (json["from_user"].toString() == '[]')?User(): User.fromJson(json["from_user"]),
    );
  }
}
