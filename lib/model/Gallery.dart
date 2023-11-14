import 'package:np_social/model/NpDateTime.dart';

class Gallery {
  int? id;
  int? post_id;
  String? type;
  String? file;
  NpDateTime? created_at;

  Gallery({this.id, this.post_id, this.type, this.file, this.created_at});

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      id: json['id'] as int,
      post_id: json['post_id'] as int,
      type: json['type'] as String,
      file: json['file'] as String,
      created_at: json['created_at'] as NpDateTime,
    );
  }
}
