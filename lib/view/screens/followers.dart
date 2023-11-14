import 'package:flutter/material.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/chatbox.dart';
import 'package:np_social/view/screens/requests.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class FollowScreen extends StatefulWidget {
  final int? user_id;
  const FollowScreen(this.user_id);

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  String? authToken;
  int? AuthId;
  bool? isAuth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      Provider.of<UserViewModel>(context, listen: false).setFriends([]);
      Provider.of<UserViewModel>(context, listen: false).ifUserIsAuth(widget.user_id);
      _pullRefresh(context);
    });

  }

  Future<void> _pullRefresh(ctx) async {
    Map data = {'user_id': '${widget.user_id}'};
    await Provider.of<UserViewModel>(ctx, listen: false).fetchFollowers(data);
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    List<User?> followers=_userViewModel.getFollowers;
    isAuth=Provider.of<UserViewModel>(context).isAuth;

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
      body: Container(
        color: Constants.np_bg_clr,
        child: Padding(
          padding: EdgeInsets.all(Constants.np_padding_only),
          child: RefreshIndicator(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          '${widget.user_id==AuthId?'My':''} Followers',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Divider(),

                      if (_userViewModel.getStatus.status == Status.IDLE) ...[
                        if (followers.length == 0) ...[
                          Padding(
                            padding: EdgeInsets.all(Constants.np_padding_only),
                            child: Center(
                              child: Text('No followers'),
                            ),
                          )
                        ] else ...[
                          Expanded(
                            //height: MediaQuery.of(context).size.height - 270,
                            child: ListView.builder(
                              itemCount: followers.length,
                              physics: AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return _FriendCard(followers[index]);
                              },
                            ),
                          )
                          //for (var friend in friends) FriendsCard(friend!)
                        ]
                      ] else if (_userViewModel.getStatus.status == Status.BUSY) ...[
                        Container(
                          height: 100,
                          child: Center(
                            child: Utils.LoadingIndictorWidtet(size: 40.0),
                          ),
                        )
                      ],

                    ]),
              ),
              //onRefresh:(context){ _pullRefresh(context) }
              onRefresh: () async {
                _pullRefresh(context);
              }),
        ),
      ),
      backgroundColor: Colors.white,
    );

  }
  Widget _FriendCard(User? user){
UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileScreen(user?.id))).then((value) => _pullRefresh(context));
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network('${Constants.profileImage(user)}',
                  width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    return Constants.defaultImage(50.0);
                  }),
            ),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 200,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Text(
                                    '${user?.fname} ${user?.lname}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        (AuthId==user?.id || widget.user_id==AuthId)?
                          InkWell(
                            onTap: () async {
                              dynamic response = await _userViewModel.unfollowRequest({'organization_id': '${AuthId}', 'user_id':'${user?.id}' });
                              if (response['data'] == true) {
                                Utils.toastMessage(response['message']);
                              } else {
                                Utils.toastMessage('Some error occurred.!');
                              }
                              _pullRefresh(context);
                            },
                            child: Text(AuthId==user?.id?'Unfollow':'Remove'),
                          ):Container(),

                      ],
                    )
                )
            )
          ],
        ),
      ),
    );
  }
}







