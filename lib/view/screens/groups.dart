import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/create_group.dart';
import 'package:np_social/view/screens/groups_details.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  var authToken;
  int? authId;
  bool searchBarHider = false;
  String searchType = 'all';
  String? searchKey;

  Future<void> _pullRefresh() async {
    setState(() { searchKey = null; });
    Map data = {};
    Provider.of<GroupsViewModel>(context, listen: false).setGroups([]);
    Provider.of<GroupsViewModel>(context, listen: false).fetchGroups(data, '${authToken}');
    Provider.of<GroupsViewModel>(context, listen: false).fetchJoinedGroups(data, '${authToken}');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      _pullRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    GroupsViewModel groupsViewModel = Provider.of<GroupsViewModel>(context);
    List<Groups?> groups = groupsViewModel.getGroups;
    List<Groups?> joinedGroups = groupsViewModel.joinedGroups;
    TextEditingController _searchController = TextEditingController();

    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateGroupScreen()))
                  .then((value) => _pullRefresh());
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.black,
          ),
          appBar: AppBar(
            
            actions: [
              AnimSearchBar(
                width: MediaQuery.of(context).size.width * 1,
                autoFocus: true,
                closeSearchOnSuffixTap: false,
                textController: _searchController,
                onSuffixTap: () {},
                onSubmitted: (value) {
                  setState(() async {
                    Map data = {};
                    _searchController.text = value;
                    searchKey = _searchController.text;
                    await groupsViewModel.searchGroups(
                        '${_searchController.text}',
                        '$searchType',
                        data,
                        '${authToken}');
                  });
                },
              )
            ],
            centerTitle: true,
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            title: Constants.titleImage(),
            leading: GestureDetector(
              child: Icon(Icons.arrow_back_ios),
              onTap: () async {
                authToken = await AppSharedPref.getAuthToken();
                authId = await AppSharedPref.getAuthId();
                Provider.of<UserViewModel>(context, listen: false)
                    .setUser(User());
                Provider.of<UserViewModel>(context, listen: false)
                    .getUserDetails({'id': '${authId}'}, '${authToken}');
                Navigator.pop(context);
              },
            ),
            bottom: TabBar(
              onTap: (index) {
              _pullRefresh();

                if (index == 0) {

                  setState(() {
                    searchKey = null;
                    searchType = 'all';
                  });
                } else {
                  setState(() {
                    searchKey = null;
                    searchType = 'my';
                  });
                }
              },
              indicatorColor: Constants.np_yellow,
              tabs: [
                Tab(
                  child: Text(
                    'All Groups',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Tab(
                  child: Text(
                    'My Group',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(physics: NeverScrollableScrollPhysics(), children: [
            Container(
              child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _pullRefresh();
                      },
                      child: Column(
                        children: [
                          searchKey?.trim() == null
                              ? Container()
                              : Container(
                                  child: Row(
                                  children: [
                                    Text(
                                      'Showing results for ',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                    Text(
                                      '${searchKey.toString()}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )),
                          Expanded(
                            child: ListView(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.3),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                  ),
                                ),
                                if (groupsViewModel.getGroupstatus.status ==
                                    Status.IDLE) ...[
                                  if (groups.length == 0) ...[
                                    Card(
                                      child: Container(
                                        color: Colors.white,
                                        padding: EdgeInsets.all(
                                            Constants.np_padding),
                                        child: Text('No Groups'),
                                      ),
                                    )
                                  ] else ...[
                                    for (var group in groups)
                                      groupWidget(group),
                                  ]
                                ] else if (groupsViewModel
                                        .getGroupstatus.status ==
                                    Status.BUSY) ...[
                                  Utils.LoadingIndictorWidtet(),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))),
            Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: RefreshIndicator(
                  onRefresh: () async {
                    _pullRefresh();
                  },
                  child: Column(
                    children: [
                      searchKey?.trim() == null 
                          ? Container()
                          : Container(
                              child: Row(
                              children: [
                                Text(
                                  'Showing results for ',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  '${searchKey.toString()}',
                                  style: TextStyle(fontSize: 18),
                                )
                              ],
                            )),
                      Expanded(
                        child: ListView(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                              ),
                            ),
                            if (groupsViewModel.getJoinedGroupstatus.status ==
                                Status.IDLE) ...[
                              if (joinedGroups.length == 0) ...[
                                Card(
                                  child: Container(
                                    color: Colors.white,
                                    padding:
                                        EdgeInsets.all(Constants.np_padding),
                                    child: Text('No Groups'),
                                  ),
                                )
                              ] else ...[
                                for (var group in joinedGroups)
                                  groupWidget(group),
                              ]
                            ] else if (groupsViewModel
                                    .getJoinedGroupstatus.status ==
                                Status.BUSY) ...[
                              Utils.LoadingIndictorWidtet(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget groupWidget(Groups? group) {
    GroupsViewModel groupsViewModel = Provider.of<GroupsViewModel>(context);
    joinGroup() async {
      Map data = {
        'user_id': '${authId}',
        'group_id': '${group!.id}',
      };
      dynamic response = await groupsViewModel.join(data);
      if (response == true) {
        _pullRefresh();
      }
    }

    cancelRequest() async {
      Map data = {
        'user_id': '${authId}',
        'group_id': '${group!.id}',
        'action': '0'
      };
      dynamic response = await groupsViewModel.action(data);
      if (response == true) {
        _pullRefresh();
      }
    }

    return InkWell(
      onTap: () {
        if (group?.created_by == authId || group?.isMember == true) {
          Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GroupDetailsScreen(group!.id!)))
              .then((value) => _pullRefresh());
        }
      },
      child: Padding(
  padding: const EdgeInsets.only(left: 10.0, right: 5, top: 10.0, bottom: 0.0),
  child: Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(05.0),
        child: Image.network(
          '${AppUrl.url}storage/${group?.thumbnail}',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Constants.defaultImage(40.0);
          },
        ),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity, // Occupy the available width
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            '${group?.title}',
                            style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        (group?.created_by == authId)
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Constants.np_yellow.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                        child: Text(
                                          'Admin',
                                          style: TextStyle(fontSize: 11, color: Constants.np_yellow),
                                        ),
                                      ),
                                      Icon(
                                        Icons.gpp_good,
                                        color: Colors.green[600],
                                        size: 11,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : (group?.isMember == true)
                                ? Container(
                                    decoration: BoxDecoration(
                                      color: Constants.np_yellow.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                      child: Text(
                                        'Member',
                                        style: TextStyle(fontSize: 11, color: Constants.np_yellow),
                                      ),
                                    ),
                                  )
                                : (group?.isRequested == true)
                                    ? InkWell(
                                        onTap: cancelRequest,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Constants.np_yellow.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                            child: Text(
                                              'Requested',
                                              style: TextStyle(fontSize: 11, color: Constants.np_yellow),
                                            ),
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: joinGroup,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Constants.np_yellow.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                            child: Text(
                                              'Join Group',
                                              style: TextStyle(fontSize: 11, color: Constants.np_yellow),
                                            ),
                                          ),
                                        ),
                                      ),
                      ],
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 3)),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.73, // Adjust the width as needed
                    child: Text(
                      '${group?.description}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  ),
)
,
    );
  }
}
