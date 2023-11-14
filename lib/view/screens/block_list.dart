import 'package:flutter/material.dart';
import 'package:np_social/model/Gallery.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/widgets/show_post.dart';
import 'package:np_social/view_model/gallery_view_model.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen();
  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  var authId;
  String? authToken;

  Future<void> _pullRefresh(ctx) async {
    Map data = {'user_id': '${authId}'};
    Provider.of<UserViewModel>(context, listen: false)
        .setBlockedUserResponse([]);
    Provider.of<UserViewModel>(context, listen: false)
        .blockedUsers(data, '${authToken}');
  }

  unblockUser(id) async {
    dynamic response = await Provider.of<PostViewModel>(context, listen: false)
        .unblockUser(
            {'auth_id': '${authId}', 'user_id': '${id}'}, '${authToken}');
    _pullRefresh(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      _pullRefresh(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    List<User?> users = _userViewModel.getBlockedUsers;

    return Scaffold(
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
      body: Consumer(
        builder: (context, UserViewModel _userViewModel, child) => Container(
          color: Constants.np_bg_clr,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: RefreshIndicator(
              onRefresh: () async {
                _pullRefresh(context);
              },
              child: Card(
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'Blocked Users',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Divider(),
                        if (_userViewModel.getBlocklistStatus.status ==
                            Status.IDLE) ...[
                          if (users.length == 0) ...[
                            Container(
                              color: Colors.white,
                              padding: EdgeInsets.all(10),
                              child: Text('No Blocked Users'),
                            )
                          ] else ...[
                            for (var user in users) userCard(user),
                          ]
                        ] else if (_userViewModel.getBlocklistStatus.status ==
                            Status.BUSY) ...[
                          //print user list length

                          // Text(users.length.toString()),

                          Utils.LoadingIndictorWidtet(),
                        ]
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget userCard(User? user) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  '${Constants.profileImage(user)}',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Constants.defaultImage(40.0);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(children: [
                  Row(
                    children: [
                      Text(
                        '${user?.fname}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Padding(padding: EdgeInsets.only(left: 3)),
                      Text(
                        '${user?.lname}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ]),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              unblockUser(user?.id);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              child: Text(
                'Unblock',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
