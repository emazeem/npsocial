import 'dart:io'; 
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_social/model/GroupUser.dart';
import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/create_post.dart';
import 'package:np_social/view/screens/groupJoinRequests.dart';
import 'package:np_social/view/screens/group_members.dart';
import 'package:np_social/view/screens/invite.dart';
import 'package:np_social/view/screens/update_group.dart';
import 'package:np_social/view/screens/widgets/show_post.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:readmore/readmore.dart';
import 'package:path/path.dart' as path1;

class GroupDetailsScreen extends StatefulWidget {
  final int? groupId;
  const GroupDetailsScreen(this.groupId);

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  File? postImage;
  XFile? imagePath;
  bool isSelectedFile = false;
  String? authToken;
  int _isUploading = 0;
  var authId;
  Dio dio = Dio();
  String? postType;
  int? group_id;
  bool? isAdmin;
  bool editTitle = false;
  TextEditingController _titleController = TextEditingController();
  File? groupImage;
  bool _isLoading = false;
  int? adminIDfromGroupDetails;
  List<Map<String, dynamic>> _mentionList = [];
  List< GlobalKey<FlutterMentionsState> > _keys = [];

  Future<void> _pullGroupRequests() async {
    Provider.of<GroupsViewModel>(context, listen: false) .setGroupJoinRequests([]);
    Provider.of<GroupsViewModel>(context, listen: false).fetchGroupJoinRequests({'group_id': '${widget.groupId}'});
  }

  Future<dynamic> getImage(String type) async {
    final ImagePicker _picker = ImagePicker();
    imagePath = await _picker.pickImage(
      source: (type == 'gallery') ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 100, 
      maxHeight:1000 ,
    );
    if (imagePath != null) {
      File file = File(imagePath!.path);
      double temp = file.lengthSync() / (1024 * 1024);
      setState(() {
        isSelectedFile = true;
        groupImage = file;
      });
      postImage = file;
      uploadFile(context);
    } else {
      setState(() {
        isSelectedFile = false;
      });
      Utils.toastMessage('Image not selected!');
    }
  }

  void removeAttachment() {
    postImage = null;
    setState(() {
      isSelectedFile = false;
    });
  }

  Future _showImagePicker(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop(); // Close the bottom sheet
                getImage('gallery');
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_camera),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.of(context).pop(); // Close the bottom sheet
                getImage('camera');
              },
            ),
          ],
        ),
      ),
    );
  }

  TypePostNavigator() {
    Navigator.push( 
      context,MaterialPageRoute(builder: (context) => CreatePostScreen(postType, widget.groupId),
        )).then((value) {
      _pullPosts();
    });
  }

  _pullgroupbyId() async {
    Provider.of<GroupsViewModel>(context, listen: false)
        .setGroupDetails(Groups());
    var data = {'id': '${widget.groupId}'};
    authToken = await AppSharedPref.getAuthToken();
    await Provider.of<GroupsViewModel>(context, listen: false)
        .fetchGroupDetails(data, authToken!);
  }

  Future<void> _pulMembers() async {
    Map data = {'group_id': '${widget.groupId}'};
    Provider.of<GroupsViewModel>(context, listen: false)
        .fetchGroupMembers(data);
  }
Future<void> _pulTaggingMembers() async {
    Map data = {'group_id': '${widget.groupId}'};
    await Provider.of<GroupsViewModel>(context, listen: false)
        .fetchGroupMembersForTagging(data);
  }
  Future<void> _pullPosts() async {
    Map data = {'group_id': '${widget.groupId}'};
    Provider.of<PostViewModel>(context, listen: false).setGroupPost([]);
    await Provider.of<PostViewModel>(context, listen: false).fetchGroupPost(data);
    var posts = Provider.of<PostViewModel>(context, listen: false).getGroupPosts;
    _keys.clear();
    for (var i = 0; i < posts.length; i++) {
      _keys.add(GlobalKey<FlutterMentionsState>());
    }
    
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      setState(() {
        _isLoading = true;
      });
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      await _pullgroupbyId();
      await _pulTaggingMembers();

      adminIDfromGroupDetails = await Provider.of<GroupsViewModel>(context, listen: false).getGroupDetails.user!.id;

      isAdmin = await Provider.of<GroupsViewModel>(context, listen: false)
              .getGroupDetails
              .user!
              .id ==
          authId;
      Map dataforriends = {'id': '${authId}'};
      await Provider.of<UserViewModel>(context, listen: false)
          .fetchFriends(dataforriends, '${authToken}');

      setState(() {
        _mentionList = Provider.of<GroupsViewModel>(context, listen: false)
            .getGroupTaggingUsers
            .map((e) => {
                  'id': '${e!.id}',
                 'display': "${e.fname} ${e.lname } ",
                 'full_name': "${e.fname} ${e.lname}",
                  'photo':"${AppUrl.url}storage/profile/${e.email}/50x50${e.profile} }"
                })
            .toList();
      });
      print('is admin $isAdmin');
      setState(() {
        _isLoading = false;
      });
    });

    _pullPosts();
    _pulMembers();
    _pullGroupRequests();

    super.initState();
  }

  @override
  Widget build(BuildContext context) { 
    List<User?> _groupMembers =
        Provider.of<GroupsViewModel>(context).getGroupUsers;
    Groups? group = Provider.of<GroupsViewModel>(context).getGroupDetails;
    PostViewModel postViewModel = Provider.of<PostViewModel>(context); 
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    UserViewModel _userViewModel =
        Provider.of<UserViewModel>(context, listen: false);

    GroupsViewModel _groupViewModel = Provider.of<GroupsViewModel>(context);
    List<GroupRequests?> groupRequests = _groupViewModel.getGroupRequests;
    List<Post?> posts = postViewModel.getGroupPosts; 

    return Scaffold(
      resizeToAvoidBottomInset: true,
        floatingActionButton: group.isMember == true
            ? SpeedDial(
                //Speed dial menu
                // marginBottom: 10, //margin bottom
                child: Padding(
                  padding: EdgeInsets.all(h * .009),
                  child: Icon(Icons.add),
                ), //icon on Floating action button
                activeIcon: Icons.close, //icon when menu is expanded on button
                backgroundColor: Colors.black, //background color of button
                foregroundColor:
                    Colors.white, //font color, icon color in button
                activeBackgroundColor: Colors.black54,
                activeForegroundColor: Colors.white,
                // buttonSize: 56.0, //button size
                visible: true,
                closeManually: false,
                curve: Curves.bounceIn,
                overlayColor: Colors.black,
                overlayOpacity: 0.5,
                onOpen: () => print('OPENING DIAL'), // action when menu opens
                onClose: () {
                  setState(() {});
                }, //action when menu closes

                elevation: 8.0, //shadow elevation of button
                shape: CircleBorder(), //shape of button

                children: [
                  SpeedDialChild(
                    child: Icon(Icons.text_fields_rounded),
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromARGB(255, 25, 25, 25),
                    label: 'Simple Post',
                    labelStyle: TextStyle(fontSize: 18.0),
                    onTap: () {
                      setState(() {
                        postType = 'simple';
                        group_id = group.id;
                      });
                      TypePostNavigator();
                    },
                  ),
                  SpeedDialChild(
                    //speed dial child
                    child: Icon(Icons.image),
                    backgroundColor: Color.fromARGB(255, 0, 0, 0),
                    foregroundColor: Colors.white,
                    label: 'Image Post',
                    labelStyle: TextStyle(fontSize: 18.0),
                    onTap: () {
                      setState(() {
                        postType = 'image';
                        group_id = group.id;
                      });
                      TypePostNavigator();
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.slow_motion_video_outlined),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    label: 'Video Post',
                    labelStyle: TextStyle(fontSize: 18.0),
                    onTap: () {
                      setState(() {
                        postType = 'video';
                        group_id = group.id;
                      });
                      TypePostNavigator();
                    },
                  ),
                  SpeedDialChild(
                    child: Icon(Icons.keyboard_voice),
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    label: 'Audio Post',
                    labelStyle: TextStyle(fontSize: 18.0),
                    onTap: () {
                      setState(() {
                        postType = 'audio';
                        group_id = group.id;
                      });
                      TypePostNavigator();
                    },
                  ),
                ],
              )
            : Container(),
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
          actions: [],
        ),
        backgroundColor: Constants.np_bg_clr,
        body: _isLoading == true
            ? Utils.LoadingIndictorWidtet()
            : Container(
                height: MediaQuery.of(context).size.height,
                child: RefreshIndicator(
                  onRefresh: () async {
                    _pullPosts();
                    _pulMembers();
                    _pullGroupRequests();
                  },
                  child: ListView(
                    children: [
                      if (group.isMember == true) ...[
                        Container(
                            color: Colors.white,
                            height: 200,
                            width: double.infinity,
                            child: Stack(children: [
                              isSelectedFile == true
                                  ? Container(
                                      height: 200,
                                      width: double.infinity,
                                      child: Image.file(
                                        groupImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl:
                                          '${AppUrl.url}storage/${group.thumbnail}',
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          Utils.LoadingIndictorWidtet(),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        '${Constants.defaultCover}',
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                              Container(
                                margin: EdgeInsets.only(right: 5, top: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    isAdmin == true
                                        ? InkWell(
                                            onTap: () {
                                              _showImagePicker(context);
                                            },
                                            child: Container(
                                              width: w / 7,
                                              decoration: BoxDecoration(
                                                  color: Constants.np_yellow
                                                      .withOpacity(0.5),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(2),
                                                  )),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0,
                                                    bottom: 5,
                                                    top: 5,
                                                    right: 05),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.edit,
                                                      color: Colors.white,
                                                      size: 14,
                                                    ),
                                                    Text(
                                                      "Edit",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              )
                            ])),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        isAdmin == true
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdateGroupScreen(
                                                                group),
                                                      )).then((value) async {
                                                        await _pullgroupbyId(); 
                                                        });
                                                },
                                                child: Container(
                                                  width: w / 7,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                      color: Constants.np_yellow
                                                          .withOpacity(0.8),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                        Radius.circular(2),
                                                      )),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons.edit,
                                                        color: Colors.white,
                                                        size: 14,
                                                      ),
                                                      Text(
                                                        "Edit",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                            : Container(),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: w / 1.1,
                                          child: Text(
                                            '${group.title}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 20),
                                          ),
                                        ),
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: ReadMoreText(
                                            ' ${group.description}',
                                            trimLines: 2,
                                            colorClickableText: Colors.pink,
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'show more',
                                            trimExpandedText: ' show less',
                                            moreStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue),
                                            lessStyle: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                    (_groupMembers.length > 0)
                                        ? InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        GroupMembersScreen(
                                                            group),
                                                  ));
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(top: 10),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.lock_outline_rounded,
                                                    size: 14,
                                                  ),
                                                  Text(
                                                    'Closed Group. ${_groupMembers.length} Member${_groupMembers.length == 1 ? '' : 's'}',
                                                  ),
                                                ],
                                              ),
                                            ))
                                        : Container(),
                                    (_groupMembers.length > 0)
                                        ? Row(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 8),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    12,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: ListView.builder(
                                                  itemCount: _groupMembers ==
                                                          null
                                                      ? 0
                                                      : (_groupMembers.length >
                                                              5
                                                          ? 5
                                                          : _groupMembers
                                                              .length),
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Stack(children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                        child: Image.network(
                                                          '${Constants.profileImage(_groupMembers[index])}',
                                                          height: 30,
                                                          width: 30,
                                                          fit: BoxFit.cover,
                                                          errorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Object
                                                                      exception,
                                                                  StackTrace?
                                                                      stackTrace) {
                                                            return Constants
                                                                .defaultImage(
                                                                    30.0);
                                                          },
                                                        ),
                                                      ),
                                                    ]);
                                                  },
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    (isAdmin == true &&
                                            groupRequests.length > 0)
                                        ? InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          GroupJoinRequests(
                                                              group.id)));
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${groupRequests.length} Request${groupRequests.length == 1 ? '' : 's'}',
                                                  style: TextStyle(
                                                      color: Colors.blue),
                                                ),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        InviteScreen(group),
                                                  ));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 10),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.5,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Constants.np_yellow),
                                              child: Text(
                                                'Invite',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          (isAdmin == true)
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5,
                                                              vertical: 10),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.5,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          color: Colors
                                                              .grey.shade300),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            'Admin',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 13),
                                                          ),
                                                          Icon(
                                                            Icons.gpp_good,
                                                            color: Colors
                                                                .green[600],
                                                            size: 11,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : InkWell(
                                                  onTap: () async {
                                                    var data = {
                                                      'group_id':
                                                          '${group.id!}',
                                                      'user_id': '${authId}'
                                                    };
                                                    dynamic response =
                                                        await Provider.of<
                                                                    GroupsViewModel>(
                                                                context,
                                                                listen: false)
                                                            .removeMember(data);
                                                    if (response == true) {
                                                      Navigator.pop(context);
                                                    } else {
                                                      Utils.toastMessage(
                                                          'Something went wrong!');
                                                    }
                                                  },
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 10),
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.5,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Colors
                                                            .grey.shade300),
                                                    child: Text(
                                                      'Leave Group',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                           if (postViewModel.getStatus.status == Status.IDLE) ...[
                    if (postViewModel.getGroupPosts.length == 0) ...[
                      Container(
                        // color: Colors.white,
                        padding: EdgeInsets.all(Constants.np_padding),
                        child: Center(child: Text('No post yet')),
                      )
                    ] else ...[
                      for (var p in postViewModel.getGroupPosts)
                        ShowPostCard(p, _mentionList,_keys.elementAt(postViewModel.getGroupPosts.indexOf(p)) ,inGroup: true,),
                      SizedBox(height: 60,),
                    ]
                  ] else if (postViewModel.getStatus.status == Status.BUSY) ...[
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Utils.LoadingIndictorWidtet(),
                    )
                  ],
                ] else ...[
                  Container(
                      height: MediaQuery.of(context).size.height - 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            child: Text(
                              'Request to Join',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('${group.title}'),
                        ],
                      )),
                ]
              ],
                    
                  ),
                ),
              ));
  }

  uploadFile(context) async {
    setState(() {
      _isUploading = 1;
    });
    String uploadUrl = AppUrl.updateCover;
    final path = postImage!.path;
    var formData = FormData.fromMap(
      {
        'id': '${group_id}',
        'image':
            await MultipartFile.fromFile(path, filename: path1.basename(path)),
      },
    );
    Response response = await dio.post(
      uploadUrl,
      data: formData,
      options: Options(
        headers: {
          "Accept": "application/json",
          'Authorization': "Bearer " + authToken!
        },
        receiveTimeout: 200000,
        sendTimeout: 200000,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );
    setState(() {
      _isUploading = 0;
    });
    if (response.statusCode == 200) {
      Utils.toastMessage('Cover Photo Changed successfully!');
    } else {
      Utils.toastMessage('Something went wrong!');
    }
  }
}
