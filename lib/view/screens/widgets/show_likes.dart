import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/Like.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view_model/like_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:np_social/model/Comment.dart';

class ShowLikeCard extends StatefulWidget {
  final Post? post;

  const ShowLikeCard(this.post);

  @override
  State<ShowLikeCard> createState() => _ShowLikeCardState();
}

class _ShowLikeCardState extends State<ShowLikeCard> {

  List<Comment> comment = [];
  List<Like> like = [];
  var totalComment = 0;
  final _commentTxtController = TextEditingController();

  String? authToken;
  int? AuthId;

  


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      Provider.of<UserViewModel>(context, listen: false).getUserDetails({'id': '${AuthId}'}, '${authToken}');

      
      var likeData = {'post': '${widget.post?.id}'};
      Provider.of<LikeViewModel>(context, listen: false).fetchAllLikes(likeData, '${authToken}');

    });
  }

  @override
  Widget build(BuildContext context) {
    User? authUser = Provider.of<UserViewModel>(context).getUser;
    List<Like?> likes = Provider.of<LikeViewModel>(context).getAllLikes;

    

    return Scaffold(
      appBar: AppBar(leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
        backgroundColor: Colors.black,
        title: Text('NP Social'),
      ),
      body: Container(
        child: Material(
          child: Container(
            color: Constants.np_bg_clr,
            child: Padding(
              padding: EdgeInsets.only(left: Constants.np_padding_only,
                  right: Constants.np_padding_only,
                  top: Constants.np_padding_only),
              child: Card(
                shadowColor: Colors.black12,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  height: double.infinity,
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'All Likes',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Divider(),
                      for(var c in likes) popupLike(c!)
                    ],
                  ),
                ),
              ),
            ),
          ),

        ),
      ),
    );
  }

  Widget popupLike(Like like) {
    return Padding(padding: EdgeInsets.all(10),
      child: Row(
        children: [
          InkWell(
            onTap: ()=>{
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OtherProfileScreen(like.user?.id)))
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network('${Constants.profileImage(like.user)}', width: 30, height: 30,fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Constants.defaultImage(30.0);
                  },
                )
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: ()=>{
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OtherProfileScreen(like.user?.id)))
                    },
                    child: Text('${like.user?.fname} ${like.user?.lname}',style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
