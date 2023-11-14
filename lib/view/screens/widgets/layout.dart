import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:np_social/model/CaseStudy.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/res/routes.dart' as route;
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/ads.dart';
import 'package:np_social/view/screens/chat.dart';
import 'package:np_social/view/screens/conferences.dart';
import 'package:np_social/view/screens/create_case_study.dart';
import 'package:np_social/view/screens/create_conferences.dart';
import 'package:np_social/view/screens/create_post.dart';
import 'package:np_social/view/screens/followers.dart';
import 'package:np_social/view/screens/friends.dart';
import 'package:np_social/view/screens/groups.dart';
import 'package:np_social/view/screens/home.dart';
import 'package:np_social/view/screens/jobposting/create_job.dart';
import 'package:np_social/view/screens/jobposting/job_detail.dart';
import 'package:np_social/view/screens/jobposting/show_jobs.dart';
import 'package:np_social/view/screens/licenses.dart';

import 'package:np_social/view/screens/near-me.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/profile.dart';
import 'package:np_social/view/screens/search.dart';
import 'package:np_social/view/screens/settings/home_location.dart';
import 'package:np_social/view/screens/settings/practice_location.dart';
import 'package:np_social/view/screens/show_case_study.dart';
import 'package:np_social/view/screens/single_post.dart';
import 'package:np_social/view/screens/widgets/drawer_info.dart';
import 'package:np_social/view_model/UserDeviceViewModel.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/role_view_model.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class NPLayout extends StatefulWidget {
  final int currentIndex;

  const NPLayout({this.currentIndex = 0});

  @override
  State<NPLayout> createState() => _NPLayoutState();
}

class _NPLayoutState extends State<NPLayout> {
  var authToken;
  var authId;
  String? email_verified_at;
  int _currentIndex = 0;
  @override
  Widget _currentWidget = HomeScreen();
  bool _showsecond = true;

  Future<void> initOneSignal(BuildContext context) async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId('104ef78f-aa9e-4316-84fd-b311f7b94fd8');
    OneSignal.shared.promptUserForPushNotificationPermission().then(
      (accepted) {
        print('Accepted permission $accepted');
      },
    );
    final status = await OneSignal.shared.getDeviceState();
    final String? osUserID = status?.userId;
    await AppSharedPref.saveDeviceId(osUserID);

    // The promptForPushNotificationsWithUserResponnction will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared.promptUserForPushNotificationPermission(
      fallbackToSettings: true,
    );

    OneSignal.shared.setNotificationOpenedHandler(
        (OSNotificationOpenedResult result) async {
      dynamic response =  result.notification.additionalData;
      print('response note ' + response.toString());

      String url = response['url'];
      print ('url is $url');

      var data_id = response['data'];
      var d_id = response['id'];

      if (url == 'post') {
        print ('post url');
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => SinglePostScreen(d_id)));
      }
      if (url == 'friend') {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OtherProfileScreen(data_id)));
      }
      if (url == 'chat') {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => NPLayout(currentIndex: 3)));
      }
      if (url == 'job') {
       
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => JobDetailScreen(jobId: d_id!)));
      }
      
    });
  }

  Future<void> _removeDevices(ctx) async {
    bool isOnline = await Utils.hasNetwork();
    if (isOnline) {
      Map userDeviceParams = {'user_id': '${authId}'};
      await Provider.of<UserDeviceViewModel>(context, listen: false)
          .removeDeviceId(userDeviceParams, '${authToken}');
      AppSharedPref.logout(context);
    } else {
      Utils.toastMessage('No internet connection!');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    initOneSignal(context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      Provider.of<RoleViewModel>(context, listen: false).setRole(0);
      Provider.of<RoleViewModel>(context, listen: false).getRole();
      _currentIndex = widget.currentIndex;
      _currentWidget = _navScreens().elementAt(_currentIndex);

      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      await Constants.redirectToLoginIfNotAuthUser(context);
      Map datum = {'id': '${authId}'};
      Provider.of<UserViewModel>(context, listen: false)
          .getUserDetails(datum, '${authToken}');

      final status = await OneSignal.shared.getDeviceState();
      await AppSharedPref.saveDeviceId(status?.userId);

      final String? osUserID = await AppSharedPref.getUserDeviceId();
      final int? isDeviceIdStored = await AppSharedPref.isStoredDeviceId();

      Provider.of<UserDetailsViewModel>(context, listen: false)
          .getUserDetails(datum, '${authToken}');

      if (isDeviceIdStored != 1) {
        Map userDeviceParams = {
          'user_id': '${authId}',
          'device_id': '${osUserID}'
        };
        Provider.of<UserDeviceViewModel>(context, listen: false)
            .storeDeviceId(userDeviceParams, '${authToken}');
      }
    });
  }

  List<Widget> _navScreens() {
    return [
      HomeScreen(),
      Container(),
      Container(),
      ChatScreen(),
      ProfileScreen(),
      SearchScreen(),
    ];
  }

  navigateToNextScreen(index) {
    setState(() {
      if (index.runtimeType == int) {
        _currentWidget = _navScreens().elementAt(index);
        _currentIndex = index;
      } else {
        if (index == 'conferences') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ConferenceScreen()));
        }
        if (index == 'followers') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => FollowScreen(authId)));
        }

        if (index == 'search') {
          Navigator.pushNamed(context, route.searchPage);
        }
        if (index == 'friend-requests') {
          Navigator.pushNamed(context, route.friendRequestPage);
        }
        if (index == 'notifications') {
          Navigator.pushNamed(context, route.notificationPage);
        }
        if (index == 'settings') {
          Navigator.pushNamed(context, route.settingPage);
        }
        if (index == 'case-study') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ShowCaseStudyScreen()));
        }
        if (index == 'marketplace') {
          Navigator.pushNamed(context, route.marketPlace);
        }
        if (index == 'licenses') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => LicenseScreen()));
        }
        if (index == 'blocklist') {
          Navigator.pushNamed(context, route.block);
        }
        if (index == 'near-me') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NearmeScreen()));
        }
        if (index == 'groups') {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => GroupsScreen()));
        }
        if (index == 'job-posting') {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ShowJobsScreen()));
        }
      }
    });
  }

  void _onItemTapped(int index) async {
    switch (index) {
      case 1:
        showModalBottomSheet(
            backgroundColor: Colors.black.withOpacity(0.8),
            context: context,
            isScrollControlled: true,
            builder: (context) {
              return FractionallySizedBox(
                heightFactor: 1,
                child: Container(
                  //color: Color(0XFF000000).withOpacity(0.6),
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height + 500,
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: InkWell(
                                  onTap: () => {
                                    Navigator.pop(context),
                                  },
                                  child: Container(
                                    color: Colors.white,
                                    width: 50,
                                    height: 50,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (context.watch<RoleViewModel>().getAuthRole ==
                            Role.Organization) ...[
                          InkWell(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FollowScreen(authId)))
                            },
                            child: bottomNavBarPopupItem(
                                Icons.checklist_rounded, 'Followers'),
                          ),
                        ],
                        if (context.watch<RoleViewModel>().getAuthRole ==
                            Role.User) ...[
                          InkWell(
                            onTap: () => {
                              Navigator.pushNamed(
                                  context, Constants.marketPlacePage)
                            },
                            child: bottomNavBarPopupItem(
                                Icons.shopping_bag_outlined, 'Marketplace'),
                          ),
                          InkWell(
                            onTap: () => {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowCaseStudyScreen(),
                                  ))
                            },
                            child: bottomNavBarPopupItem(
                                Icons.library_books_outlined, 'Case Study'),
                          ),
                          InkWell(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => GroupsScreen()))
                            },
                            child: bottomNavBarPopupItem(
                                Icons.group_rounded, 'Groups'),
                          ),
                          InkWell(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FriendScreen(authId)))
                            },
                            child: bottomNavBarPopupItem(
                                Icons.supervised_user_circle_sharp, 'Friends'),
                          ),
                        ],
                        InkWell(
                          onTap: () =>
                              {Navigator.pushNamed(context, route.searchPage)},
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 50),
                            child:
                                bottomNavBarPopupItem(Icons.search, 'Search'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
        break;
      case 2:
        showModalBottomSheet(
            backgroundColor: Colors.black.withOpacity(0.8),
            isScrollControlled: true,
            context: context,
            builder: (context) {
              PostViewModel postViewModel =
                  Provider.of<PostViewModel>(context, listen: false);
              return Container(
                //color: Color(0XFF000000).withOpacity(0.6),
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: InkWell(
                                onTap: () => {
                                  Navigator.pop(context),
                                },
                                child: Container(
                                  color: Colors.white,
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*InkWell(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CreatePostScreen('audio')))
                            },
                            child: bottomNavBarPopupItem(
                                Icons.audiotrack, 'Upload Audio'),
                          ),
                          InkWell(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CreatePostScreen('video')))
                            },
                            child: bottomNavBarPopupItem(
                                Icons.video_library_outlined, 'Upload Video'),
                          ),
                          */
                      //Case Study
                      if (context.watch<RoleViewModel>().getAuthRole ==
                          Role.User) ...[
                        InkWell(
                          onTap: () => {
                            Navigator.pop(context),
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateCaseStudyScreen(),
                              ),
                            ),
                          },
                          child: bottomNavBarPopupItem(
                              Icons.library_books, 'Add Case Study'),
                        ),
                      ],
                      if (context.watch<RoleViewModel>().getAuthRole ==
                          Role.Organization) ...[
                        InkWell(
                          onTap: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateConferences(),
                              ),
                            )
                          },
                          child: bottomNavBarPopupItem(
                              Icons.calendar_month, 'Add Conference'),
                        ),
                      ],

                      InkWell(
                        onTap: () => {
                          Navigator.pop(context),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CreatePostScreen('video', 0))),
                        },
                        child: bottomNavBarPopupItem(
                            Icons.video_collection_sharp, 'Upload Video'),
                      ),
                      InkWell(
                        onTap: () => {
                          Navigator.pop(context),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CreatePostScreen('audio', 0))),
                        },
                        child: bottomNavBarPopupItem(
                          Icons.audiotrack,
                          'Upload Audio',
                        ),
                      ),

                      InkWell(
                        onTap: () => {
                          Navigator.pop(context),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CreatePostScreen('image', 0))),
                        },
                        child: bottomNavBarPopupItem(
                            Icons.photo, 'Upload Picture'),
                      ),
                      InkWell(
                        onTap: () => {
                          Navigator.pop(context),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CreatePostScreen('simple', 0))),
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 50),
                          child:
                              bottomNavBarPopupItem(Icons.text_fields, 'Post'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
        break;
      default:
        setState(() {
          navigateToNextScreen(index);
        });
        break;
    }
  }

  Widget build(BuildContext context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    User? user = _userViewModel.getUser;

    Constants.checkVerificationStatus(
        context, {'email': '${user?.email_verified_at}'});

    UserDetail? userDetail =
        Provider.of<UserDetailsViewModel>(context).getDetails;

    return WillPopScope(
      onWillPop: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return Future.value(true);
        }
        return Future.value(false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          title: Constants.titleImage(),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, route.searchPage);
              },
              child: Icon(
                Icons.search,
                color: Colors.black,
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 14, left: 5),
              child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, route.notificationPage);
                  },
                  child: (user?.anyUnreadNotification == 0)
                      ? Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.black,
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 14.0),
                          child: badges.Badge(
                            position: badges.BadgePosition.topEnd(
                              top: -2,
                              end: -1,
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                            ),
                          ),
                        )),
            )
          ],
        ),
        body: _currentWidget,
        backgroundColor: Colors.white,
        floatingActionButton: (_currentIndex == 0 &&
                ((userDetail?.longitude == null && user?.role == Role.User) ||
                    (userDetail?.workplace_latitude == null &&
                        user?.role == Role.Organization)))
            ? SizedBox(
                width: 45,
                height: 45,
                child: FloatingActionButton(
                  onPressed: () {
                    user?.role == Role.Organization
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PracticeLocationScreen(),
                            ))
                        : Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeLocationScreen()))
                            .then((value) {
                            Map data = {'id': '${authId}'};
                            Provider.of<UserViewModel>(context, listen: false)
                                .getUserDetails(data, '${authToken}');
                            Provider.of<UserDetailsViewModel>(context,
                                    listen: false)
                                .getUserDetails(data, '${authToken}');
                          });
                  },
                  backgroundColor: Colors.white,
                  tooltip: 'Set your location',
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.black,
                    size: 35,
                  ),
                ),
              )
            : SizedBox(),
            onDrawerChanged: (isOpened) {
              if (isOpened) {
               Provider.of<DrawerStateInfo>(context,listen: false).setCurrentDrawer(1);
              } else {
                Provider.of<DrawerStateInfo>(context,listen: false).setCurrentDrawer(0);
              }
               
            },
        drawer: Drawer(
          child: ListView(padding: EdgeInsets.zero, children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey, shape: BoxShape.circle),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        child: ClipOval(
                          child: SizedBox.fromSize(
                              size: Size.fromRadius(40),
                              child: (user != null)
                                  /*? Image.network('${Constants.profileImage(user!)}',
                                      fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {return Constants.defaultImage(60.0);}

                                  )*/
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          "${Constants.profileImage(user)}",
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
                                          Constants.defaultImage(60.0),
                                    )
                                  : Utils.LoadingIndictorWidtet()),
                        ),
                      ),
                    ),
                    context.watch<RoleViewModel>().getAuthRole == Role.User
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Text(
                                    '${user?.fname} ${user?.lname}',
                                    style: TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    context.watch<RoleViewModel>().getAuthRole ==
                            Role.Organization
                        ? SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  Text(
                                    '${user?.fname}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Image.asset(
                                    Constants.orgBadgeImage,
                                    width: 20,
                                  )
                                ],
                              ),
                            ),
                          )
                        : Container(),
                    if (userDetail?.speciality?.title != null) ...[
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          child: Text(
                            '${userDetail?.speciality?.title}',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      )
                    ],
                  ],
                ),
              ),
              decoration: BoxDecoration(color: Constants.np_bg_clr),
            ),
            sideBarMenu("Feed", Icons.home_outlined, "home"),
            sideBarMenu("Search", Icons.search, 'search'),
            if (context.watch<RoleViewModel>().getAuthRole == Role.User) ...[
              sideBarMenu(
                  "Requests", Icons.group_add_outlined, 'friend-requests'),
              sideBarMenu(
                  "Friends", Icons.supervised_user_circle_outlined, 'friends'),
              sideBarMenu("Groups", Icons.group_outlined, 'groups'),
            ],
            if (context.watch<RoleViewModel>().getAuthRole ==
                Role.Organization) ...[
              sideBarMenu("Followers", Icons.checklist_rtl, 'followers'),
            ],
            sideBarMenu(
                "Marketplace", Icons.shopping_bag_outlined, 'marketplace'),
            sideBarMenu(
                "Conferences", Icons.calendar_month_outlined, 'conferences'),
            sideBarMenu(
                "Messages",
                (user?.anyUnreadMessage == 0 || user?.anyUnreadMessage == null)
                    ? Icons.chat_bubble_outline
                    : Icons.chat_outlined,
                'chat'),
            if (context.watch<RoleViewModel>().getAuthRole == Role.User) ...[
              sideBarMenu(
                  "Case Study", Icons.library_books_outlined, 'case-study'),
            ],
            sideBarMenu("Near me", Icons.location_on_outlined, 'near-me'),
            if (context.watch<RoleViewModel>().getAuthRole == Role.User) ...[
              sideBarMenu("Licenses", Icons.book_outlined, 'licenses'),
            ],
            sideBarMenu("Job Portal", Icons.work_outline, 'job-posting'),
            sideBarMenu(
                "Notifications", Icons.notifications_none, "notifications"),
            sideBarMenu("Settings", Icons.settings_outlined, 'settings'),
            sideBarMenu("Logout", Icons.logout, 'logout'),
          ]),
        ),
        bottomNavigationBar: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Container(
            color: Colors.white,
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage('assets/images/home.png'),
                    color: Color(0xFF000000),
                    size: 30,
                  ),
                  tooltip: 'Home',
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage('assets/images/explore.png'),
                    color: Color(0xFF000000),
                    size: 32,
                  ),
                  tooltip: 'Add Friends',
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage('assets/images/plus.png'),
                    color: Color(0xFF343232),
                    size: 50,
                  ),
                  tooltip: 'Add',
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    margin: EdgeInsets.only(top: 5),
                    child: ImageIcon(
                      AssetImage((user?.anyUnreadMessage == 0 ||
                              user?.anyUnreadMessage == null)
                          ? 'assets/images/message.png'
                          : 'assets/images/message-red.png'),
                      color: Color(0xFF000003),
                      size: 41,
                    ),
                  ),
                  tooltip: 'Chat',
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: (user == null)
                          ? Utils.LoadingIndictorWidtet()
                          : CachedNetworkImage(
                              placeholder: (context, url) =>
                                  Utils.LoadingIndictorWidtet(),
                              errorWidget: (context, url, error) =>
                                  Constants.defaultImage(40.0),
                              imageUrl: "${Constants.profileImage(user)}",
                              width: 40,
                              height: 40,
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )),
                  tooltip: 'Profile',
                  label: '',
                ),
              ],
              currentIndex: _currentIndex,
              onTap: _onItemTapped,
              showUnselectedLabels: true,
              //unselectedItemColor: Color(0XFFffffff).withOpacity(0.5),
              unselectedLabelStyle: TextStyle(
                fontSize: 14,
              ),
              selectedLabelStyle: TextStyle(
                fontSize: 12,
              ),
              //selectedItemColor: Color(0XFFffffff).withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }

  Widget sideBarMenu(String title, IconData icon, String page) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        setState(() {
          switch (page) {
            case 'home':
              _onItemTapped(0);
              break;
            case 'job-posting':
              navigateToNextScreen(page);
              break;
            case 'chat':
              _onItemTapped(3);
              break;
            case 'friends':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FriendScreen(authId)));
              break;

            case 'logout':
              showAlertDialog(context);
              break;

            default:
              navigateToNextScreen(page);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Colors.grey.shade300,
          )),
        ),
        child: Row(
          children: [
            Expanded(
              child: Icon(icon, size: 25, color: Colors.black),
            ),
            Expanded(
              flex: 4,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? showAlertDialog(BuildContext context) {
    // set up the button
    Widget yesButton = InkWell(
      child: Container(
        width: 70,
        height: 20,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            "Yes",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ),
      onTap: () {
        _removeDevices(context);
      },
    );
    Widget noButton = InkWell(
      child: Container(
        width: 70,
        height: 20,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            "No",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(
        "Are you sure to Logout?",
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      title: Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 60,
      ),
      actions: [
        noButton,
        yesButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

class bottomNavBarPopupItem extends StatelessWidget {
  final IconData ico;
  final String title;

  const bottomNavBarPopupItem(this.ico, this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
              child: Icon(this.ico, size: 30),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                this.title,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
