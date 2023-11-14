import 'package:flutter/material.dart';
import 'package:np_social/model/GroupUser.dart';
import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/groups_details.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:np_social/model/apis/api_response.dart';

class RequestScreen extends StatefulWidget {

  final int? initialIndex;
  const RequestScreen({this.initialIndex});

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool? authUser = false;
  int? authId;
  Map data = {};
  List<User> friends = [];
  String? authToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      _pullfriendrequests();
      _pullGroupRequests();
    });
  }

  Future<void> _pullfriendrequests() async {
    data = {'id': '${authId}'};
    Provider.of<UserViewModel>(context, listen: false)
        .setFriendsRequestResponse([]);
    Provider.of<UserViewModel>(context, listen: false)
        .fetchFriendsRequest(data, '${authToken}');
  }

  Future<void> _pullGroupRequests() async {
    Provider.of<GroupsViewModel>(context, listen: false).setGroupRequests([]);
    Provider.of<GroupsViewModel>(context, listen: false)
        .fetchGroupRequests({}, '${authToken}');
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    List<User?> friends = _userViewModel.getFriendsRequest;

    GroupsViewModel _groupViewModel = Provider.of<GroupsViewModel>(context);
    List<GroupRequests?> groupRequests = _groupViewModel.getGroupRequests;

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        initialIndex: widget.initialIndex==null?0:1,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            title: Constants.titleImage(),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            bottom: TabBar(
              indicatorColor: Constants.np_yellow,
              tabs: [
                Tab(
                  child: Text(
                    'Friend Requests',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    'Group Requests',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              RefreshIndicator(
                  child: Card(
                    child: ListView(children: [
                      if (_userViewModel.getFetchFriendRequestStatus.status ==
                          Status.IDLE) ...[
                        if (friends.length == 0) ...[
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text('No friend requests.'),
                            ),
                          )
                        ] else ...[
                          for (var friend in friends)
                            Column(
                              children: [
                                friendRequestCard(friend!, context),
                              ],
                            ),
                        ]
                      ] else if (_userViewModel
                              .getFetchFriendRequestStatus.status ==
                          Status.BUSY) ...[
                        Utils.LoadingIndictorWidtet(),
                      ],
                    ]),
                  ),
                  onRefresh: () async {
                    _pullfriendrequests();
                  }),
              RefreshIndicator(
                  child: Card(
                    child: ListView(children: [
                      if (_groupViewModel.getStatus.status == Status.IDLE) ...[
                        if (groupRequests.length == 0) ...[
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text('No Group invites.'),
                            ),
                          )
                        ] else ...[
                          for (var groupRequest in groupRequests)
                            Column(
                              children: [
                                grouprequestWidget(groupRequest!, context),
                              ],
                            ),
                        ]
                      ] else if (_groupViewModel.getStatus.status == Status.BUSY) ...[
                        Utils.LoadingIndictorWidtet(),
                      ],
                    ]),
                  ),
                  onRefresh: () async {
                    _pullGroupRequests();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget friendRequestCard(User user, context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);

    acceptOrRejectFriendRequest(status, is_cancel_request) async {
      dynamic response = await _userViewModel.acceptOrRejectFriendRequest(
          {'id': '${user.id}', 'auth_id': '${authId}', 'status': '${status}'},
          '${authToken}');
      if (response['success'] == true) {
        Utils.toastMessage(response['message']);
      } else {
        Utils.toastMessage('Some error occurred.!');
      }
      _pullfriendrequests();
      return 0;
    }

    return InkWell(
      onTap: () => {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtherProfileScreen(user.id)))
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network('${Constants.profileImage(user)}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover, errorBuilder: (BuildContext context,
                      Object exception, StackTrace? stackTrace) {
                return Constants.defaultImage(50.0);
              }),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Container(
                  width: 150,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        '${user.fname} ${user.lname}',
                        style: TextStyle(fontSize: 16),
                      )),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  height: 30,
                  color: Constants.np_yellow,
                  child: InkWell(
                    onTap: () {
                      acceptOrRejectFriendRequest(1, 0);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 15, color: Colors.white),
                        Text(
                          'Accept',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.all(2)),
                Container(
                  height: 30,
                  color: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: InkWell(
                      onTap: () {
                        acceptOrRejectFriendRequest(2, 1);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.close, size: 15, color: Colors.white),
                          Text(
                            'Reject',
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget grouprequestWidget(GroupRequests groupRequests, BuildContext context) {
    GroupsViewModel groupsViewModel = Provider.of<GroupsViewModel>(context);
    groupRequestAction(String action)async{
      Map data={
        'user_id': '${authId}',
        'group_id': '${groupRequests.group!.id}',
        'action': action};
      dynamic response = await groupsViewModel.action(data);
      if (response == true) {
        _pullGroupRequests();
      }

    }
    return Container(
      color: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: (){
                //Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDetailsScreen(groupRequests.group)));
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(05.0),
                  child: Image.network(
                    '${AppUrl.url}storage/${groupRequests.group!.thumbnail}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Constants.defaultImage(40.0);
                    },
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    '${groupRequests.group!.title}',
                    style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Text(
                    '${groupRequests.group!.description}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        height: 30,
                        color: Constants.np_yellow,
                        child: InkWell(
                          onTap: () {
                            groupRequestAction('1');
                          },
                          child: Row(
                            children: [
                              Icon(Icons.check,
                                  size: 15, color: Colors.white),
                              Text(
                                'Accept',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        height: 30,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        color: Colors.black,
                        child: InkWell(
                          onTap: () {
                            groupRequestAction('0');
                          },
                          child: Row(
                            children: [
                              Icon(Icons.close,
                                  size: 15, color: Colors.white),
                              Text(
                                'Decline',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
