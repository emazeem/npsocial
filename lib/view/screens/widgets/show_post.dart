import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:np_social/model/Comment.dart';
import 'package:np_social/model/Like.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/webview/audio.dart';
import 'package:np_social/view/screens/webview/video.dart';
import 'package:np_social/view/screens/widgets/drawer_info.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view/screens/widgets/report_post.dart';
import 'package:np_social/view/screens/widgets/show_comments.dart';
import 'package:np_social/view_model/comment_view_model.dart';
import 'package:np_social/view_model/like_view_model.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/role_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class ShowPostCard extends StatefulWidget {
  final Post? post;
  final List<Map<String,dynamic>>? _mentionList;
  bool inGroup = false;
  final GlobalKey<FlutterMentionsState> mentionKey;

   ShowPostCard(this.post, this._mentionList, this.mentionKey,
      {this.inGroup = false});

  @override
  State<ShowPostCard> createState() => _ShowPostCardState();
}

class _ShowPostCardState extends State<ShowPostCard>
    with WidgetsBindingObserver {
  String audioURL = '';
  String videoURL = '';
  List<Comment> comment = [];
  List<Like> like = [];
  int? totalComment = 0;
  int? totalLikes = 0;
  final _commentTxtController = TextEditingController();
  String? authToken;
  int? AuthId;
  Color likeColor = Colors.black;
  bool _isVisible = true;
  String fileName = '';
  bool colorHelper = false;
  Future<void>? _launched;
  String _commentText = '';
  List<String> mentionedUsers = [];
  FocusNode _focusNode = FocusNode();

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Implement your desired functionality here
      print("Clicked outside the input field!");
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {


      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      Provider.of<UserViewModel>(context, listen: false)
          .getUserDetails({'id': '${AuthId}'}, '${authToken}');
      /*Provider.of<CommentViewModel>(context, listen: false).setAllComments([]);
      var data = {'id': '${widget.post?.id}'};
      Provider.of<CommentViewModel>(context, listen: false).fetchAllComments(data, '${authToken}');
      */
      await Provider.of<UserViewModel>(context, listen: false) .fetchAllUsers(); 
      var likeData = {'post': '${widget.post?.id}'};
      Provider.of<LikeViewModel>(context, listen: false)
          .fetchAllLikes(likeData, '${authToken}');
          
    });
    Provider.of<PostViewModel>(context, listen: false);
    totalLikes = widget.post?.likes;
    totalComment = widget.post?.comments;
    likeColor =
        (widget.post?.is_liked == 1) ? Constants.np_yellow : Colors.black;
    //_getImage();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  deletePost(id) async {
    await Provider.of<PostViewModel>(context, listen: false)
        .deletePost({'id': '${id}'}, '${authToken}');
  }
  handleMentionUser(data){
    print('handleMentionUser $data'); 
    String adduser = '@${data['id']}'+'#'+data['full_name']+ '#';
    mentionedUsers.add(adduser);
    print('mentionedUsers added $mentionedUsers');
    }

  reportPost(id) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => ReportPost(widget.post?.id)));
  }
   String replaceUsernames(String inputString) {
     var usersList = Provider.of<UserViewModel>(context, listen: false).getAllUsers;
     for(User? user in usersList){
       inputString = inputString.replaceAll('@${user!.fname} ${user.lname}', '@${user.id}#${user!.fname} ${user.lname}#');
     }
      return inputString;
    } 

  Future<void> _launchInBrowser(Uri url) async {
    if (Platform.isAndroid) {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    } else {
      final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
      if (await launcher.canLaunch(url.toString())) {
        await launcher.launch(
          url.toString(),
          useSafariVC: true,
          useWebView: true,
          enableJavaScript: true,
          enableDomStorage: false,
          universalLinksOnly: false,
          headers: <String, String>{'my_header_key': 'my_header_value'},
        );
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _commentTxtController.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {
    UserViewModel? _userViewModel = Provider.of<UserViewModel>(context);
    User? _user = _userViewModel.getUser;
    CommentViewModel _commentViewModal = Provider.of<CommentViewModel>(context);
    LikeViewModel _likeViewModal = Provider.of<LikeViewModel>(context);
    sendRequest(to) async {
      dynamic response = await _userViewModel.sendFriendRequest(
          {'from': '${AuthId}', 'to': '${to}'}, '${authToken}');
      if (response['success'] == true) {
        setState(() {
          _isVisible = false;
        });
        Utils.toastMessage(response['message']);
      } else {
        Utils.toastMessage(response['message']);
      }
    }

    return Container(
      color: Constants.np_bg_clr,
      child: Padding(
        padding: EdgeInsets.only(
            left: Constants.np_padding_only,
            right: Constants.np_padding_only,
            top: Constants.np_padding_only),
        child: Card(
          shadowColor: Colors.black12,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            children: [
              InkWell(
                child: Padding(
                  padding: EdgeInsets.all(Constants.np_padding_only),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:widget.post!.group_id==null?Colors.black:Colors.blue.shade400,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(50)
                            ),
                            width: 40,
                            height: 40,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: (widget.post == null)
                                    ? Utils.LoadingIndictorWidtet()
                                    : Image.network(
                                        '${Constants.profileImage(widget.post?.user)}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Constants.defaultImage(40.0);
                                        },
                                      )),
                          ),
                          Container(
                            height: 50,
                            margin: EdgeInsets.only(left: 10, top: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${widget.post?.user?.fname} ${widget.post?.user?.role == Role.User ? widget.post?.user?.lname : ''}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          if (widget.post?.user?.role ==
                                              Role.Organization)
                                            Image.asset(
                                              Constants.orgBadgeImage,
                                              width: 20,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '${widget.post?.created_at?.m}-${widget.post?.created_at?.d}-${widget.post?.created_at?.Y} ${widget.post?.created_at?.h}:${widget.post?.created_at?.i} ${widget.post?.created_at?.A} ',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    Image.asset(
                                      'assets/images/${widget.post?.privacy}.png',
                                      width: 20,
                                      height: 20,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Constants.defaultImage(20.0);
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                          children: [
                            if (widget.post?.user_id != AuthId) ...[
                              if (widget.post?.is_requested == 0 &&
                                  widget.post?.user?.role == Role.User &&
                                  context.watch<RoleViewModel>().getAuthRole ==
                                      Role.User) ...[
                                InkWell(
                                  child: Container(
                                    width: 40,
                                    child: Image.asset(
                                      'assets/images/add.png',
                                      width: 20,
                                      height: 20,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Constants.defaultImage(20.0);
                                      },
                                    ),
                                  ),
                                  onTap: () async {
                                    if (widget.post?.is_requested == 0) {
                                      await sendRequest(widget.post?.user_id);
                                    }
                                  },
                                ),
                              ]
                            ],
                            Theme(
                              data: Theme.of(context).copyWith(
                                cardColor: Colors.white,
                              ),
                              child: new PopupMenuButton<int>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: Colors.black,
                                ),
                                color: Colors.white,
                                onSelected: (item) async {
                                  if (item == 0) {
                                    await deletePost(widget.post?.id);
                                  }
                                  if (item == 1) {
                                    reportPost(widget.post?.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  (widget.post?.user_id == AuthId)
                                      ? PopupMenuItem<int>(
                                          value: 0,
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                        )
                                      : PopupMenuItem<int>(
                                          value: 1,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.flag,
                                                color: Colors.red,
                                              ),
                                              Text('Report'),
                                            ],
                                          ),
                                        ),
                                ],
                              ),
                            ),

                            // PopupScreen(),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                onTap: () {
                  if (widget.post?.user?.id != AuthId) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OtherProfileScreen(widget.post?.user?.id)));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NPLayout(
                                  currentIndex: 4,
                                )));
                  }
                },
              ),
              Container(color: Constants.np_bg_clr, height: 1),
              if (widget.post?.details != null) ...[
                Container(
                  alignment: Alignment.topLeft,
                  child: Padding(
                      padding: EdgeInsets.all(Constants.np_padding_only),
                      child: Linkify(
                        onOpen: (url) {
                          setState(() {
                            _launched = _launchInBrowser(Uri.parse(url.url));
                          });
                          FutureBuilder<void>(
                              future: _launched,
                              builder: (BuildContext context,
                                  AsyncSnapshot<void> snapshot) {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return const Text('');
                                }
                              });
                        },
                        text: "${widget.post?.details}",
                      )),
                ),
                Constants.horizontalLine(),
              ],
              if (widget.post != null) ...[
                if (widget.post?.assets?.type == 'image') ...[
                  InkWell(
                    child: Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey.shade100,
                      child: (widget.post == null)
                          ? Utils.LoadingIndictorWidtet()
                          : CachedNetworkImage(
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                              fit: BoxFit.contain,
                              imageUrl:
                                  "${Constants.postImage(widget.post?.assets)}",
                              placeholder: (context, url) =>
                                  Utils.LoadingIndictorWidtet(),
                              errorWidget: (context, url, error) => Image.asset(
                                'assets/images/image-placeholder.png',
                                width: 300,
                                height: 300,
                              ),
                            ),
                    ),
                    onTap: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => ShowImage('${Constants.postImage(widget.post?.assets)}')));
                    },
                  ),
                  Container(color: Constants.np_bg_clr, height: 1),
                ],
                if (widget.post?.assets?.type == 'audio') ...[
                  Container(
                    width: double.infinity,
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AudioScreen(
                                audioUrl:
                                    "${AppUrl.url}storage/a/posts/${widget.post?.assets?.file}",
                              ),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/audio-thumbnail.png',
                          fit: BoxFit.cover,
                        )),
                  ),
                  Divider(),
                ],
                if (widget.post?.assets?.type == 'video') ...[
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoScreen(
                            videoUrl:
                                "${AppUrl.url}storage/a/posts/${widget.post?.assets?.file}",
                          ),
                        ),
                      );
                    },
                    /*child: Container(
                      width: double.infinity,
                      color: Colors.grey.shade400,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 110),
                        child: Icon(
                          Icons.play_circle_outline,
                          size: 70,
                          color: Color(0x8A00000
                          0),
                        ),
                      ),
                    ),
                    */
                    child: Stack(
                      children: <Widget>[
                        Container(
                          decoration: new BoxDecoration(color: Colors.white),
                          alignment: Alignment.center,
                          height: 280,
                          child: FadeInImage(
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: AssetImage(
                                'assets/images/videoplaceholder.png'),
                            image: CachedNetworkImageProvider(
                                '${AppUrl.url}storage/a/posts/thumbnail-${widget.post?.assets?.file?.split(".")[0]}.png'),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                  'assets/images/videoplaceholder.png',
                                  fit: BoxFit.fitWidth);
                            },
                          ),
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 280,
                              child: Icon(
                                Icons.play_circle_outline,
                                size: 70,
                                color: Color(0x8A000000),
                              ),
                            ))
                      ],
                    ),
                  ),
                  Divider(),
                ]
              ],
              Container(
                child: Row(
                  children: [
                    InkWell(
                      child: Container(
                        width: 40,
                        height: 50,
                        child: Icon(
                            likeColor != Constants.np_yellow
                                ? Icons.thumb_up_alt_outlined
                                : Icons.thumb_up,
                            color: likeColor),
                      ),
                      onTap: () async {
                        Map likeStoreData = {
                          'post': '${widget.post?.id}',
                          'user': '${AuthId}',
                        };
                        try {
                          if (likeColor.value == 4278190080) {
                            setState(() {
                              likeColor = Constants.np_yellow;
                              totalLikes = totalLikes! + 1;
                            });
                          } else {
                            setState(
                              () {
                                likeColor = Colors.black;
                                totalLikes = totalLikes! - 1;
                              },
                            );
                          }
                          Map likeResponse = await _likeViewModal.storeLike(
                              likeStoreData, '${authToken}');
                          if (likeResponse['response']['data']['like'] ==
                              true) {
                          } else {}
                        } catch (e) {}
                        //commentStore(widget.post.id);
                      },
                    ),
                    Container(
                      width: 10,
                      height: 50,
                      child: Center(
                        child: Text(
                          '${totalLikes}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    Container(width: 20),
                    InkWell(
                      onTap: () {
                       widget.inGroup ==true ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ShowCommentCard(widget.post,fromGroup: true,))): Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ShowCommentCard(widget.post,fromGroup: false,)));
                      },
                      child: Row(
                        children: [
                          Container(
                            height: 50,
                            child: Icon(Icons.comment_outlined),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${totalComment}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(color: Constants.np_bg_clr, height: 1),
              Container(
                child: Padding(
                  padding: EdgeInsets.all(Constants.np_padding_only),
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: (widget.post?.user_id.toString() == null)
                              ? Utils.LoadingIndictorWidtet()
                              : Image.network(
                                  '${Constants.profileImage(_user)}',
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return Constants.defaultImage(40.0);
                                  },
                                ),
                        ),
                      ),
                       Flexible(
                         
                        child: SizedBox(
                          height: 50,
                          child: Focus(
                            onFocusChange: (hasFocus) {
                            DrawerStateInfo drawerStateInfo = Provider.of<DrawerStateInfo>(context,listen: false);
                     if(drawerStateInfo.getCurrentDrawer == 0){
                      print ('drawerStateInfo.getCurrentDrawer : ${drawerStateInfo.getCurrentDrawer}');
                     }else{
                      widget.mentionKey.currentState!.showSuggestions.value = false;
                     }
                            },
                            child: FlutterMentions(
                              suggestionListHeight: 300,
                              onMentionAdd: (data){
                                handleMentionUser(data);
                              },
                             onChanged: (value) {
                               if (value.isEmpty){
                                  mentionedUsers.clear();
                                }  _commentTxtController.text = value; 
                                
                             },
                             
                             suggestionPosition:widget.inGroup ?SuggestionPosition.Top: SuggestionPosition.Bottom,
                              decoration: const InputDecoration(
                                  hintText: 'Write something',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 17, vertical: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(25),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(25.0)),
                                    borderSide: BorderSide(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  )),
                              key: widget.mentionKey,
                              suggestionListDecoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1,
                                ),
                              ),
                              mentions: [
                                Mention(
                                  trigger: '@',
                                  data: widget._mentionList!,
                                  matchAll: false,
                                  suggestionBuilder: (data) {
                                    return SizedBox(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 10),
                                        width: 50,
                                        decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color: Colors.grey.shade300)),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: 10,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Image.network(
                                                  data['photo'],
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (BuildContext
                                                          context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                    return Constants.defaultImage(
                                                        30.0);
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  data['full_name'],
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  style: TextStyle(
                                    color: Constants.np_yellow,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                              
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.black,
                          tooltip: 'Add Comment',
                          onPressed: () async {
                            if (_commentTxtController.text.isEmpty) {
                              Utils.toastMessage('Comment is required');
                            } else {
                              print( mentionedUsers.toString());
                              print (_commentTxtController.text);
                              String formattedText = replaceUsernames(_commentTxtController.text); 
                              print ('formattedtext' + formattedText);
                              Map commentStoreData = {
                                'comment': formattedText,
                                'post_id': '${widget.post?.id}',
                                'user_id': '${AuthId}',
                              };
                              setState(() {
                                totalComment = totalComment! + 1;
                                _commentTxtController.text = '';
                              });
                              Map response =
                                  await _commentViewModal.storeComments(
                                      commentStoreData, '${authToken}');
                              if (response['success'] == true) {
                                Utils.toastMessage(
                                    'Your comment has been added');
                                widget.mentionKey.currentState!.controller!
                                    .clear();
                                        mentionedUsers.clear();
                              } else {
                                setState(() {
                                  totalComment = totalComment! - 1;
                                });
                                Utils.toastMessage('Something went wrong');
                              }
                            }
                            //commentStore(widget.post.id);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
