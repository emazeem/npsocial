import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/Like.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:np_social/model/Comment.dart';

class ShowImage extends StatefulWidget {
  final String? url;

  const ShowImage(this.url);

  @override
  State<ShowImage> createState() => _ShowImageState();
}

class _ShowImageState extends State<ShowImage> {


  bool appBarFlag=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: appBarFlag?Colors.white:Colors.black,
        iconTheme: IconThemeData(color: Colors.black),
        title: appBarFlag?Constants.titleImage():null,
        automaticallyImplyLeading: appBarFlag,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body:InkWell(
        onTap: (){
          setState(() {
            appBarFlag=!appBarFlag;
          });
        },
        child:  Container(
            color: Colors.black,
            height: double.infinity,
            child:
            PhotoView(
              imageProvider: NetworkImage('${widget.url}'),
            )
        ),
      ),
    );
  }
}
