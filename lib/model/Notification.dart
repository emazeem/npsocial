import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/User.dart';

class Notifications {
  String? id;
  String? msg;
  String? read_at;
  String? url;
  int? data_id;
  /*String? url;
  int? data_id;*/
  NpDateTime? created_at;
  User? from;

  Notifications({this.id, this.msg,this.url, this.data_id,this.read_at, this.created_at, this.from});

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
        id :json['id'] as String,
        msg: json['msg'] as String,
        url : json['url']['url'] as String?,
        data_id : json['url']['data'] as int?,
        read_at : json['read_at'] as String?,
        created_at : json['created_at'] as NpDateTime,
        from : json['from'] != null ? User.fromJson(json['from']) : null,
    );
  }
}
