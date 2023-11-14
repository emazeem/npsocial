import 'package:flutter/material.dart';
import 'package:np_social/model/CaseStudy.dart';
import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/groups_details.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/single_post.dart';
import 'package:np_social/view/screens/widgets/case_study_details.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/search_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../view_model/role_view_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int? authId;
  String _searchType = 'all';
  var userRole;
  final _searchTxtController = TextEditingController();

  Widget noResults = Padding(
    padding: EdgeInsets.only(top: 30),
    child: Text(
      'No results',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.grey),
    ),
  );

  var authToken;
  var selectedIndex = 0;
  List<Widget> searchResults = [];
  List<User> searchedData = [];
  // Groups should to be always on last index!
  List<String> numbers = ['All', 'Users', "Post", 'Case Study', 'Groups'];  
  int totalResults = 0;
  getType(String number) {
    if (number == 'All') {
      return 'all';
    }
    if (number == 'Users') {
      return 'users';
    }
    if (number == 'Post') {
      return 'posts';
    }
    if (number == 'Case Study') {
      return 'case-studies';
    }
    if (number == 'Groups') {
      return 'groups';
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authId = await AppSharedPref.getAuthId();
      authToken = await AppSharedPref.getAuthToken();
      Provider.of<UserViewModel>(context, listen: false);
      Provider.of<SearchViewModel>(context, listen: false);
    });
    searchResults.add(noResults);
  }

  @override
  void dispose() {
    _searchTxtController.dispose();
    super.dispose();
  }

  Future<void> search() async {
    if (_searchTxtController.text == '') {
      Utils.toastMessage('Enter key to search users.');
      setState(() {
          searchResults = [];
          searchResults.add(noResults);
        });
    } else {
      setState(() {
        searchResults = [
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            child: Utils.LoadingIndictorWidtet(),
          )
        ];
      });
      Map data = {'search': _searchTxtController.text, 'type': _searchType};
      dynamic ApiResponse = await Provider.of<SearchViewModel>(context, listen: false).search(data, authToken);
      print('ApiResponse ${ApiResponse}');
      setState(() {
        totalResults = ApiResponse?.length;
      });
      if (ApiResponse?.length == 0) {
        setState(() {
          searchResults = [];
          searchResults.add(noResults);
        });
      } else {
        setState(() {
          searchResults = [];
          if (_searchType == 'users' || _searchType == 'all') {
            ApiResponse.forEach((element) async {
              if(element is User){
                String profile = await Constants.profileImage(element);
                searchResults.add(usersCard(element, profile));
              }
            });
          }
          if (_searchType == 'posts' || _searchType == 'all') {
            ApiResponse.forEach((element) async {
              if(element is Post){
                searchResults.add(postsCard(element));
              }
            });
          }
          if (_searchType == 'groups' || _searchType == 'all') {
            ApiResponse.forEach((element) async {
              if(element is Groups) {
                searchResults.add(groupsCard(element));
              }
            });
          }
          if (_searchType == 'case-studies' || _searchType == 'all') {
            ApiResponse.forEach((element) async {
              if(element is CaseStudy) {
                searchResults.add(caseStudyCard(element));
              }
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final w=MediaQuery.of(context).size.width;
    final userRole = context.watch<RoleViewModel>().getAuthRole;
    final userViewModel = Provider.of<UserViewModel>(context);
    final searchViewModel = Provider.of<SearchViewModel>(context);

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
      backgroundColor: Constants.np_bg_clr,
      body: Container(
        padding: EdgeInsets.all(10),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(top: 5,right: 10,bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    totalResults == 0
                        ? Container()
                        : Text(
                      '${totalResults} Results',
                      style: TextStyle(fontWeight: FontWeight.w500,fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                child: TextField(
                  autofocus: true,
                  onSubmitted: (value) async {
                    await search();
                  },
                  controller: _searchTxtController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.0),
                      ),
                      labelText: " Search $_searchType",
                      suffixIcon: Icon(Icons.search),
                      suffixIconColor: Colors.black,
                      labelStyle: TextStyle(color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                ),
              ),
              Container(
                height: 20,
                padding: EdgeInsets.only(left: 10),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: context.watch<RoleViewModel>().getAuthRole ==
                      Role.User
                      ? numbers.length
                      : numbers.length - 2,
                  itemBuilder: (BuildContext context, int index) { 
                    return InkWell(
                          onTap: () async {
                            setState(() {
                            selectedIndex = index;
                            _searchType = getType(numbers[index]); 
                            }); 
                            await search(); 
                          }, 
                          child: Container( 
                            decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? Colors.black
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: Colors.grey, width: 1 / 2)),
                        margin: EdgeInsets.only(right: 10),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Center(
                          child: Text(
                            '${numbers[index]}',
                            style: TextStyle(
                                fontSize: 14,
                                color: selectedIndex == index
                                    ? Colors.white
                                    : Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 6,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                    color: Colors.black12,
                  ))),
                  child: ListView(
                    children: searchResults,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget usersCard(User user, String profile) {
    final w=MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtherProfileScreen(user.id)));
      },
      child: Container(
        height: 70,
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade100),
        )),
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      '${profile}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (BuildContext context, Object exception,
                          StackTrace? stackTrace) {
                        return Constants.defaultImage(40.0);
                      },
                    ),
                  ),
                  Flexible(
                    child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Text(
                              '${user.fname} ${user.role==Role.User?user.lname:''}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            user.role == Role.Organization ?
                            Image.asset(Constants.orgBadgeImage,width: 20,):Container(), 
                            ],
                        )),
                  ),
                  
                ],
              ),
            ), 
            Padding(padding: EdgeInsets.only(right: 10),
            child: user.role == Role.Organization ? 
                        Icon(Icons.corporate_fare,color: Colors.black,size: 20,) 
                        :Image.asset(
                          'assets/images/users.png',
                          width: 20,
                        ),) 
          ],
        ),
      ),
    );
  }

  Widget postsCard(Post post) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SinglePostScreen(post.id)));
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade100),
        )),
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      '${Constants.profileImage(post.user!)}',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${post.user!.fname} ${post.user?.role==Role.User?post.user!.lname:''}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width-150,
                          child: Text(
                            '${post.details}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: TextStyle(fontSize: 15),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
             Padding(
               padding: EdgeInsets.only(right: 10),
               child: Image.asset('assets/images/posts.png', width: 20),
             ),
          ],
        ),
      ),
    );
  }

  Widget caseStudyCard(CaseStudy caseStudy) {
    return InkWell(
      onTap: () {
        Navigator.push(context,MaterialPageRoute(
                builder: (context) => CaseStudyDetailsScreen(caseStudy: caseStudy), ),);
      },
      child: Container(
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey.shade100),
        )),
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                '${caseStudy.user!.profile}',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Constants.defaultImage(40.0);
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${caseStudy.user!.fname} ${caseStudy.user!.lname}',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${caseStudy.title}',
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 15),
                              ),
                              /*Text(
                                '${caseStudy.body}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 15),
                              ),*/
                            ],
                          ),
                        ),
                        Image.asset(
                          'assets/images/case-study.png',
                          width: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget groupsCard(Groups? group) {
    GroupsViewModel groupsViewModel =
        Provider.of<GroupsViewModel>(context, listen: false);

    joinGroup() async {
      Map data = {
        'user_id': '${authId}',
        'group_id': '${group!.id}',
      };
      dynamic response = await groupsViewModel.join(data);
      if (response == true) {
        // _pullRefresh();
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
        // _pullRefresh();
      }
    }

    return InkWell(
      onTap: () {
        if (group.isMember == true) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDetailsScreen(group.id!)));
        } else {
          Utils.toastMessage('You are not a member of this group');
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(05.0),
                child: Image.network(
                  '${AppUrl.url}storage/${group?.thumbnail}',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Constants.defaultImage(40.0);
                  },
                ),
              ),
              Expanded(
                  child:Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width:MediaQuery.of(context).size.width-160,
                                child: Text(
                                  '${group?.title}',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width:MediaQuery.of(context).size.width-160,
                                child: Text(
                                  '${group?.description}',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ),

              group!.created_by == authId
                  ? Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Admin',
                      style: TextStyle(fontSize: 11),
                    ),
                    Icon(
                      Icons.gpp_good,
                      color: Colors.green[600],
                      size: 11,
                    ),
                  ],
                ),
              )
                  : (group.isMember == true)
                  ? Text(
                'Member',
                style: TextStyle(fontSize: 11),
              )
                  : (group.isRequested == true)
                  ? InkWell(
                  onTap: cancelRequest,
                  child: Text(
                    'Requested',
                    style: TextStyle(fontSize: 11),
                  ))
                  : InkWell(
                onTap: joinGroup,
                child: Text(
                  'Join Group',
                  style: TextStyle(fontSize: 11),
                ),
              ) 
              ],
          )),
    );
  }
}
