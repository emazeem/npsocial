import 'package:flutter/material.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/chatbox.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:np_social/model/apis/api_response.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController editingController = TextEditingController();

  var authToken;
  List<User?> friends = [];
  List<User?> allFriends = [];

  List<User?> marketPlaceFriends = [];
  List<User?> allMarketFriends = [];

  bool isShowMarketChat = true;

  int? authId;
  Future<void> _pullRefresh() async {
    Provider.of<UserViewModel>(context, listen: false).setChatFriends([]);
    Provider.of<UserViewModel>(context, listen: false).fetchChatFriends();
    Provider.of<UserViewModel>(context, listen: false).setFriendsOfMarketPlace([]);
    Map data = {'id': '${authId}'};
    Provider.of<UserViewModel>(context, listen: false).fetchMarketPlaceFriends(data, '${authToken}');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      _pullRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    List<User?> friends = _userViewModel.getChatFriends;
    List<User?> marketPlaceFriends = _userViewModel.getMarketFriends;
    _userViewModel.getUser;
    return Container(
      color: Constants.np_bg_clr,
      height: MediaQuery.of(context).size.height,
      child: DefaultTabController(
        length: isShowMarketChat ? 2 : 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 50,
                child: AppBar(
                  backgroundColor: Colors.white,
                  leading: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_ios_outlined),
                            ),
                  bottom: TabBar(
                    indicatorColor: isShowMarketChat
                        ? Constants.np_yellow
                        : Colors.transparent,
                    physics: isShowMarketChat
                        ? AlwaysScrollableScrollPhysics()
                        : NeverScrollableScrollPhysics(),
                    isScrollable: isShowMarketChat ? false : true,
                    labelPadding: EdgeInsets.only(left: 0, right: 0),
                    tabs: [
                      Tab(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border(
                                  right:
                                      BorderSide(color: Colors.grey.shade200))),
                          child: Center(
                            child: Text(
                              'Chat',
                              style: Constants()
                                  .np_heading
                                  .copyWith(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      isShowMarketChat
                          ? Tab(
                              child: Text('Marketplace',
                                  style: Constants()
                                      .np_heading
                                      .copyWith(color: Colors.black)),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
              // create widgets for each tab bar here
              Expanded(
                child: TabBarView(
                  physics: isShowMarketChat
                      ? AlwaysScrollableScrollPhysics()
                      : NeverScrollableScrollPhysics(),
                  children: [
                    // first tab bar view widget
                    Container(
                      color: Colors.white,
                      height: double.infinity,
                      child: Column(
                        children: [
                          // Divider(),
                          if (_userViewModel.getStatus.status == Status.IDLE) ...[
                            if (friends.length == 0) ...[
                              Padding(
                                padding:
                                    EdgeInsets.all(Constants.np_padding_only),
                                child: Text('No Recent Chats'),
                              )
                            ] else ...[
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: () async {
                                    _pullRefresh();
                                  },
                                  child: ListView.builder(
                                    itemCount: friends.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return chatUsersCard(friends[index]);
                                    },
                                  ),
                                ),
                              ),
                              // for (var friend in friends)
                              //     chatUsersCard(friend),
                            ]
                          ] else if (_userViewModel.getStatus.status == Status.BUSY) ...[
                            Container(
                              height: 70,
                              child: Utils.LoadingIndictorWidtet(size: 30.0),
                            ),
                          ],
                        ],
                      ),
                    ),

                    isShowMarketChat
                        ? Container(
                            color: Colors.white,
                            height: double.infinity,
                            child: Column(
                              children: [
                                // Divider(),
                                if (_userViewModel
                                        .getFetchFriendStatus.status ==
                                    Status.IDLE) ...[
                                  if (friends.length == 0) ...[
                                    Padding(
                                      padding: EdgeInsets.all(
                                          Constants.np_padding_only),
                                      child: Text('No Recent Chats'),
                                    )
                                  ] else ...[
                                    Expanded(
                                      child: RefreshIndicator(
                                        onRefresh: () async {
                                          _pullRefresh();
                                        },
                                        child: ListView.builder(
                                          itemCount: marketPlaceFriends.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return chatUsersCard(
                                                marketPlaceFriends[index],
                                                isMarketPlace: true);
                                          },
                                        ),
                                      ),
                                    ),
                                    // for (var friend in friends)
                                    //     chatUsersCard(friend),
                                  ]
                                ] else if (_userViewModel
                                        .getFetchFriendStatus.status ==
                                    Status.BUSY) ...[
                                  Container(
                                    height: 70,
                                    child:
                                        Utils.LoadingIndictorWidtet(size: 30.0),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget chatUsersCard(User? friend, {bool isMarketPlace = false}) {
    return InkWell(
      onTap: () => {
        setState(() {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatBoxScreen(friend, isMarketChat: isMarketPlace)))
              .then((value) => _pullRefresh());
        })
      },
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(width: 1, color: Constants.np_bg_clr),
        )),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.network(
                Constants.profileImage(friend),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Constants.defaultImage(50.0);
                },
              ),
            ),
            Container(
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
                                width: MediaQuery.of(context).size.width - 140,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${friend?.fname} ${friend?.role == Role.User ? friend?.lname : ''}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      (friend?.unread_msg == 0)
                                          ? Container()
                                          : Container(
                                              width: 20,
                                              height: 20,
                                              margin: EdgeInsets.only(left: 10),
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  color: Constants.np_bg_clr,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              child: Text(
                                                '${friend?.unread_msg}',
                                                style: TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )))
          ],
        ),
      ),
    );
  }
}
