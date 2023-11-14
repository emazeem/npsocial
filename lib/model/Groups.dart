import 'package:np_social/model/User.dart';

class Groups {
  final int? id;
  final String? title;
  final String? description;
  final String? thumbnail;
  final User? user;
  final int? created_by;
  final bool? isMember;
  final bool? isRequested;

  Groups({
    this.id,
    this.user,
    this.created_by,
    this.title,
    this.description,
    this.thumbnail,
    this.isMember,
    this.isRequested,
  });

  factory Groups.fromJson(Map<String, dynamic> json) {

    return Groups(
      id: json['id'] as int?,
      user: User.fromJson(json['admin']) as User?,
      created_by: json['created_by'] as int,
      title: json['title'],
      description: json['description'],
      thumbnail: json['image'],
      isMember: json['is_member'],
      isRequested: json['is_requested'],
    );
    
  }
}
