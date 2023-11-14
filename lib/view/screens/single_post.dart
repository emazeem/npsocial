import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:np_social/model/Gallery.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/widgets/show_post.dart';
import 'package:np_social/view_model/gallery_view_model.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SinglePostScreen extends StatefulWidget {
  final int? postId;
  const SinglePostScreen(this.postId);

  @override
  State<SinglePostScreen> createState() => _SinglePostScreenState();
}

class _SinglePostScreenState extends State<SinglePostScreen> {
  var authId;
  String? authToken;
  final GlobalKey<FlutterMentionsState> uniqueKey = GlobalKey<FlutterMentionsState>();
  List<Map<String,dynamic>>? _mentionList = [];
  int? groupId;
  bool fetchingMentionUser=true;

   Future<void> _pulTaggingMembers() async {
     print('group_id from post : ${groupId}');
     print('groupId!=null : ${groupId!=null}');
        Map data = {'group_id': '${groupId}'};
        await Provider.of<GroupsViewModel>(context, listen: false).fetchGroupMembersForTagging(data);
        if (groupId!=null) {
          setState((){
            _mentionList = Provider.of<GroupsViewModel>(context, listen: false).getGroupTaggingUsers.map((e) => {
              'id': '${e?.id}',
              'display': "${e?.fname} ${e?.lname } ",
              'full_name': "${e?.fname} ${e?.lname}",
              'photo':"${AppUrl.url}storage/profile/${e?.email}/50x50${e?.profile} }"
            }).toList();
            fetchingMentionUser=false;
          });
          print('user length group: ${_mentionList!.length}');
        }else{
          setState((){
            _mentionList = Provider.of<UserViewModel>(context, listen: false).getFriends.map((e) => {
              'id': '${e?.id}',
              'display': "${e?.fname} ${e?.lname } ",
              'full_name': "${e?.fname} ${e?.lname}",
              'photo':"${AppUrl.url}storage/profile/${e?.email}/50x50${e?.profile} }"
            }) .toList();
            fetchingMentionUser=false;
          });
          print('user length simple: ${_mentionList!.length}');
        }
   }


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Provider.of<PostViewModel>(context, listen: false).setSinglePost(Post());
      await _pullPost();
      print ('groupId : ${groupId}');

      Map dataForFriends = {'id': '${authId}'};
      await Provider.of<UserViewModel>(context, listen: false).fetchFriends(dataForFriends, '${authToken}');
      await _pulTaggingMembers();

    });
    super.initState();
  }

  Future<void> _pullPost() async {
    Map data = {'id': '${widget.postId}'};
    Provider.of<PostViewModel>(context, listen: false).setSinglePost(Post());
    await Provider.of<PostViewModel>(context, listen: false).fetchSinglePost(data, '${authToken}');
    groupId = Provider.of<PostViewModel>(context, listen: false).getSinglePost?.group_id;
  }

  @override
  Widget build(BuildContext context) {
    PostViewModel _postViewModel = Provider.of<PostViewModel>(context);
    Post? post = _postViewModel.getSinglePost;


    Widget _child = Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
        Center(
          child: Utils.LoadingIndictorWidtet(),
        ),
      ],
    );

    if (_postViewModel.getStatus.status == Status.IDLE) {
      if(_postViewModel.getNoPost){
        _child =Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2,),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Image.network(
                  '${Constants.noPostImage}',
                  width: 200,
                  height: 200,
                )
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
            Text( 'This post is no longer available.',style: TextStyle(fontSize: 20,color: Colors.black45),
            ),
          ],
        );
      }else{
        if(fetchingMentionUser==false){
          _child = ShowPostCard(post, _mentionList!, uniqueKey,inGroup: groupId!=null);
          //_child = Text('${Provider.of<PostViewModel>(context).getSinglePost?.id}');
        }else{
          _child = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
              Center(
                child: Utils.LoadingIndictorWidtet(),
              ),
            ],
          );
        }
      }
      
    } else if (_postViewModel.getStatus.status == Status.BUSY) {
      _child = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.4,),
          Center(
            child: Utils.LoadingIndictorWidtet(),
          ),
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
      centerTitle: true,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
      title: Constants.titleImage(),
      leading: IconButton(
        onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
        ),
        backgroundColor: Constants.np_bg_clr,
        body: RefreshIndicator(
            child: ListView(
              children: [_child],
            ),
            onRefresh: _pullPost
        )
    );
  }
}
