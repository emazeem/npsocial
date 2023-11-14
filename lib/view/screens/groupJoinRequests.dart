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

class GroupJoinRequests extends StatefulWidget {


  final int? id;
  const GroupJoinRequests(this.id);

  @override
  State<GroupJoinRequests> createState() => _GroupJoinRequestsState();
}

class _GroupJoinRequestsState extends State<GroupJoinRequests> {
  bool? authUser = false;
  int? authId;
  Map data = {};
  List<User> friends = [];
  String? authToken;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      _pullGroupRequests();
    });
    super.initState();
  }

  Future<void> _pullGroupRequests() async {
    Provider.of<GroupsViewModel>(context, listen: false).setGroupJoinRequests([]);
    Provider.of<GroupsViewModel>(context, listen: false).fetchGroupJoinRequests({'group_id':'${widget.id}'});
  }

  @override
  Widget build(BuildContext context) {

    GroupsViewModel _groupViewModel = Provider.of<GroupsViewModel>(context);
    List<GroupRequests?> groupRequests = _groupViewModel.getGroupRequests;

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.white,
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
          body: RefreshIndicator(
              child: Card(
                child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          'Group Join Requests',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Divider(),
                      if (_groupViewModel.getStatus.status == Status.IDLE) ...[
                        if (groupRequests.length == 0) ...[
                          Center(
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text('No Requests.'),
                            ),
                          )
                        ] else ...[
                          for (var groupRequest in groupRequests)
                            Column(
                              children: [
                                groupRequestWidget(groupRequest!, context),
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
        ),
      ),
    );
  }

  Widget groupRequestWidget(GroupRequests groupRequests, BuildContext context) {
    GroupsViewModel groupsViewModel = Provider.of<GroupsViewModel>(context);
    groupRequestAction(String action)async{
      Map data={
        'user_id': '${groupRequests.userId}',
        'group_id': '${groupRequests.group!.id}',
        'action': action
      };
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
          children: [
            InkWell(
              onTap: (){
                // Navigator.push(
                //     context, MaterialPageRoute(builder: (context) => GroupDetailsScreen(groupRequests.group)));
              },
              child: Container(
                margin: EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Image.network(
                    '${Constants.profileImage(groupRequests.user)}',
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
                  width: MediaQuery.of(context).size.width / 1.5,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          '${groupRequests.user?.fname} ${groupRequests.user?.lname} ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          'requested to follow this group.',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 4,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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

              ],
            )
          ],
        ),
      ),
    );
  }
}
