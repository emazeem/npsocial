import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:np_social/model/CheckPrivacy.dart';
import 'package:np_social/model/Gallery.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/license.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/chatbox.dart';
import 'package:np_social/view/screens/followers.dart';
import 'package:np_social/view/screens/friends.dart';
import 'package:np_social/view/screens/licenses.dart';
import 'package:np_social/view/screens/mygallery.dart';
import 'package:np_social/view/screens/settings/practice_location.dart';
import 'package:np_social/view/screens/widgets/image.dart';
import 'package:np_social/view/screens/widgets/profile_friends_card.dart';
import 'package:np_social/view/screens/widgets/report_user.dart';
import 'package:np_social/view/screens/widgets/show_post.dart';
import 'package:np_social/view_model/friend_view_model.dart';
import 'package:np_social/view_model/gallery_view_model.dart';
import 'package:np_social/view_model/license_view_model.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/privacy_view_model.dart';
import 'package:np_social/view_model/role_view_model.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class OtherProfileScreen extends StatefulWidget {
  final int? id;
  const OtherProfileScreen(this.id, {Key? key}) : super(key: key);

  @override
  State<OtherProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<OtherProfileScreen> {
  List<User> friends = [];
  bool? showAboutWidget = false;
  String? authToken;
  String? description;
  bool? authUser = false;
  var authId;
  Map data = {};
  bool showlicense = true;
  bool showMoreBtnFlag = true;
  int showMoreCounter = 0;
  Widget _showMoreBtn = Container();
  bool _allPostsFetched = false;
  bool _isLoadingMore = false;
  List<Post?> myPosts = [];
  bool? _followStatus;
  int followers = 0;
  List<Map<String, dynamic>> _mentionList = [];
  LicenseViewModel licenseViewModel = LicenseViewModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    data = {'id': '${widget.id}'};

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Provider.of<UserViewModel>(context, listen: false)
          .fetchFollowers({'user_id': '${widget.id}'});

      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Map postParam = {'id': '${widget.id}', 'number': '0'};

      Provider.of<OtherUserDetailsViewModel>(context, listen: false)
          .setDetailsResponse(UserDetail());

      Provider.of<OtherUserViewModel>(context, listen: false)
          .otherUserResponseSetter(User());
     await Provider.of<UserViewModel>(context, listen: false) .fetchAllUsers(); 
      setState(() {
        _mentionList = Provider.of<UserViewModel>(context, listen: false)
            .getAllUsers
            .map((e) => {
              'id': '${e!.id}',
              'display': "${e.fname} ${e.lname } ",
              'full_name': "${e.fname} ${e.lname}",
              'photo':"${AppUrl.url}storage/profile/${e.email}/50x50${e.profile} }"
                })
            .toList();
      });
      Provider.of<OtherUserDetailsViewModel>(context, listen: false)
          .getOtherUserDetail(
              {'id': '${widget.id}', 'auth_id': '${authId}'}, '${authToken}');
      Provider.of<OtherUserViewModel>(context, listen: false)
          .getOtherUserDetails(data, '${authToken}');
      Provider.of<UserViewModel>(context, listen: false)
          .fetchFriends(data, '${authToken}');

      Provider.of<MyPostViewModel>(context, listen: false).setMyPosts([]);
      Provider.of<MyPostViewModel>(context, listen: false)
          .fetchMyPosts(postParam, '${authToken}');
      Provider.of<GalleryViewModel>(context, listen: false)
          .fetchMygalleryImages(data, '${authToken}');

      Provider.of<PrivacyViewModel>(context, listen: false)
          .setCheckPrivacy(CheckPrivacy());
      Provider.of<PrivacyViewModel>(context, listen: false)
          .checkPrivacy(data, '${authToken}');
      _pullActionButtonStatus(context);
      licenseViewModel = Provider.of<LicenseViewModel>(context, listen: false);
      License _license = License(auth_id: widget.id);
      licenseViewModel.fetchLicense(_license, authToken!);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    licenseViewModel.disposeData();
    super.dispose();
  }

  Future<void> _pullActionButtonStatus(ctx) async {
    _removeActionButtonStatus(ctx);
    await Provider.of<FriendViewModel>(context, listen: false)
        .fetchActionButtonStatus(
            {'auth_user': '${authId}', 'other_user': '${widget.id}'},
            '${authToken}');
  }

  void _removeActionButtonStatus(ctx) {
    Provider.of<FriendViewModel>(context, listen: false)
        .setActionButtonStatus(new ActionButtonStatus());
  }

  Widget build(BuildContext context) {
    followers = Provider.of<UserViewModel>(context).getFollowers.length;

    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    OtherUserViewModel _otherUserViewModel =
        Provider.of<OtherUserViewModel>(context);
    User? _user = _otherUserViewModel.getOtherUser;

    List<User?> friends = Provider.of<UserViewModel>(context).getFriends;
    myPosts = Provider.of<MyPostViewModel>(context).getMyPosts;

    GalleryViewModel galleryViewModel = Provider.of<GalleryViewModel>(context);
    List<Gallery?> galleryImages = galleryViewModel.getGalleryImages;
    UserDetail? userDetail =
        Provider.of<OtherUserDetailsViewModel>(context).getOtherUserDetails;
    ActionButtonStatus? _actionBtnStatus =
        Provider.of<FriendViewModel>(context).getActionButtonStatus;

    PrivacyViewModel privacyViewModel = Provider.of<PrivacyViewModel>(context);
    CheckPrivacy? checkPrivacy = privacyViewModel.getCheckPrivacy;

    acceptOrRejectFriendRequest(status, is_cancel_request) async {
      _removeActionButtonStatus(context);
      dynamic response = await _userViewModel.acceptOrRejectFriendRequest(
          {'id': '${_user?.id}', 'auth_id': '${authId}', 'status': status},
          '${authToken}');
      if (response['success'] == true) {
        if (is_cancel_request == 1) {
          Utils.toastMessage('Request cancelled successfully!');
        } else {
          Utils.toastMessage(response['message']);
        }
      } else {
        Utils.toastMessage('Some error occurred.!');
      }
      _pullActionButtonStatus(context);
    }

    sendRequest() async {
      _removeActionButtonStatus(context);
      dynamic response = await _userViewModel.sendFriendRequest(
          {'from': '${authId}', 'to': '${_user?.id}'}, '${authToken}');
      if (response['success'] == true) {
        _pullActionButtonStatus(context);
        Utils.toastMessage(response['message']);
      } else {
        Utils.toastMessage('Some error occurred.!');
      }
      _pullActionButtonStatus(context);
    }

    followRequest() async {
      _pullActionButtonStatus(context);
      dynamic response =
          await _userViewModel.followRequest({'user_id': '${_user?.id}'});
      if (response['data'] == true) {
        Utils.toastMessage(response['message']);
      } else {
        Utils.toastMessage('Some error occurred.!');
      }
      _pullActionButtonStatus(context);
    }

    unfollowRequest() async {
      _pullActionButtonStatus(context);
      dynamic response = await _userViewModel.unfollowRequest(
          {'organization_id': '${_user?.id}', 'user_id': '${authId}'});

      if (response['data'] == true) {
        Utils.toastMessage(response['message']);
      } else {
        Utils.toastMessage('Some error occurred.!');
      }
      _pullActionButtonStatus(context);
    }

    blockUser() async {
      dynamic response = await _userViewModel.blockUser(
          {'auth_id': '${authId}', 'user_id': '${widget.id}'}, '${authToken}');
      Navigator.of(context).pop();
      if (response['success'] == true) {
        if (_user!.role == Role.User) {
          Utils.toastMessage('User blocked successfully!');
        } else if (_user.role == Role.Organization) {
          Utils.toastMessage('Organization blocked successfully!');
        } else {
          Utils.toastMessage(response['message']);
        }
      } else {
        Utils.toastMessage('Some error occurred.!');
      }
    }

    reportUser() async {
      dynamic response = await _userViewModel.reportUser(
          {'auth_id': '${authId}', 'user_id': '${widget.id}'},
          '${authToken}',
          '${description}');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportUser(_user?.id),
          ));
    }

    if (_user?.role == Role.User) {
      if (checkPrivacy?.about == true && userDetail?.about != null) {
        setState(() {
          showAboutWidget = true;
        });
      }
    }
    print('about ${userDetail?.about}');
    if (_user?.role == Role.Organization && userDetail?.about != null) {
      print('i am here');
      setState(() {
        showAboutWidget = true;
      });
    }
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
        child: ListView(
          children: [
            Stack(
              children: <Widget>[
                Container(
                  color: Colors.white,
                  height: 200,
                  width: double.infinity,
                  child: Image.network(
                      '${Constants.coverPhoto(_user?.id, userDetail?.cover_photo)}',
                      fit: BoxFit.cover, errorBuilder: (BuildContext context,
                          Object exception, StackTrace? stackTrace) {
                    return Image.asset(
                      '${Constants.defaultCover}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    );
                  }),
                ),
              ],
            ),
            Container(
                constraints: BoxConstraints.loose(Size.fromHeight(40)),
                child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -70.0,
                        child: Container(
                            child: ClipOval(
                          child: SizedBox.fromSize(
                              size: Size.fromRadius(60),
                              child: Image.network(
                                  '${Constants.profileImage(_user)}',
                                  fit: BoxFit.cover, errorBuilder:
                                      (BuildContext context, Object exception,
                                          StackTrace? stackTrace) {
                                return Constants.defaultImage(60.0);
                              })),
                        )),
                      )
                    ])),
            Container(
              margin: EdgeInsets.only(top: 20, bottom: 10),
              width: double.infinity,
              child: Center(
                child: (_user?.fname == null)
                    ? Utils.LoadingIndictorWidtet()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_user?.fname} ${_user?.role == Role.User ? _user?.lname : ''} ',
                            style: Constants().np_heading,
                          ),
                          _user?.role == Role.Organization
                              ? Image.asset(
                                  Constants.orgBadgeImage,
                                  width: 20,
                                )
                              : Container(),
                        ],
                      ),
              ),
            ),

            _user?.role == Role.Organization
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 3),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FollowScreen(widget.id)));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${followers}',
                            style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Followers',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),

            (userDetail?.speciality?.title != null &&
                    userDetail?.speciality?.status == 1)
                ? Container(
                    margin: EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: _user?.role == Role.User
                              ? Text('${userDetail?.speciality?.title}',
                                  overflow: TextOverflow.visible,
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black54))
                              : Container(),
                        ),
                      ],
                    ),
                  )
                : Container(),

            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        (_actionBtnStatus?.showFollowBtn == true)
                            ? InkWell(
                                onTap: followRequest,
                                child: controlContainerText('Follow'),
                              )
                            : Container(),
                        (_actionBtnStatus?.showUnFollowBtn == true)
                            ? InkWell(
                                onTap: unfollowRequest,
                                child: controlContainerText('Unfollow'),
                              )
                            : Container(),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ChatBoxScreen(_user)));
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 5, right: 5),
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Icon(
                                Icons.message,
                                color: Colors.white,
                                size: 15,
                              ),
                            )),
                      ],
                    ),
                    _user?.role == Role.User
                        ? Row(
                            children: [
                              (_actionBtnStatus?.showSendRequestBtn == true)
                                  ? InkWell(
                                      onTap: sendRequest,
                                      child: controlContainerText('Add Friend'),
                                    )
                                  : Container(),
                              (_actionBtnStatus?.showAcceptRejectBtn == true)
                                  ? InkWell(
                                      onTap: () async {
                                        await acceptOrRejectFriendRequest(
                                            '1', 0);
                                      },
                                      child: controlContainerText(
                                          'Accept Request'),
                                    )
                                  : Container(),
                              Container(
                                padding: EdgeInsets.all(5),
                              ),
                              (_actionBtnStatus?.showAcceptRejectBtn == true)
                                  ? InkWell(
                                      onTap: () async {
                                        await acceptOrRejectFriendRequest(
                                            '2', 0);
                                      },
                                      child: controlContainerText(
                                          'Reject Request'),
                                    )
                                  : Container(),
                              (_actionBtnStatus?.showUnfriendBtn == true)
                                  ? InkWell(
                                      onTap: () async {
                                        dynamic response = await _userViewModel
                                            .unfriend({
                                          'from': '${authId}',
                                          'to': '${_user?.id}'
                                        }, '${authToken}');
                                        if (response['success'] == true) {
                                          Utils.toastMessage(
                                              response['message']);
                                        } else {
                                          Utils.toastMessage(
                                              'Some error occurred.!');
                                        }
                                      },
                                      child: controlContainerText('Unfriend'),
                                    )
                                  : Container(),
                              (_actionBtnStatus?.showCancelFriendRequestBtn ==
                                      true)
                                  ? InkWell(
                                      onTap: () async {
                                        await acceptOrRejectFriendRequest(
                                            '2', 1);
                                      },
                                      child: controlContainerText(
                                          'Cancel Request'),
                                    )
                                  : Container(),
                            ],
                          )
                        : Container(),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        margin: EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: InkWell(
                          child: Text(
                            'Block',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onTap: blockUser,
                        )),
                    SizedBox(
                      width: 6,
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                        margin: EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: InkWell(
                          child: Text(
                            'Report',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            reportUser();
                          },
                        )),
                  ],
                ),
              ),
            ),
            if (showAboutWidget == true) ...[
              Padding(
                padding: EdgeInsets.only(
                    left: Constants.np_padding_only,
                    right: Constants.np_padding_only,
                    top: 20),
                child: Card(
                  shadowColor: Colors.black12,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => context
                            .read<OtherUserViewModel>()
                            .setAboutVisible(),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text(
                                'About',
                                style: TextStyle(fontSize: 18),
                              ),
                              Spacer(),
                              Icon(
                                context.read<OtherUserViewModel>().aboutVisible
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                size: 17,
                              )
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            context.read<OtherUserViewModel>().aboutVisible,
                        child: Column(
                          children: [
                            Divider(),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text('${userDetail?.about}')),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
            _user?.role == Role.User
                ? Padding(
                    padding: EdgeInsets.only(
                        left: Constants.np_padding_only,
                        right: Constants.np_padding_only,
                        top: 10),
                    child: Card(
                      shadowColor: Colors.black12,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => context
                                .read<OtherUserViewModel>()
                                .setSocialInfoVisible(),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Text(
                                    'Social Information',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      context
                                          .read<OtherUserViewModel>()
                                          .setSocialInfoVisible();
                                    },
                                    child: Icon(
                                      context
                                              .read<OtherUserViewModel>()
                                              .sInfoVisible
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible:
                                context.read<OtherUserViewModel>().sInfoVisible,
                            child: Column(
                              children: [
                                Divider(),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        (checkPrivacy?.email == true)
                                            ? Utils.socialInformation(
                                                'Email', '${_user?.email}')
                                            : Container(),
                                        (checkPrivacy?.phone == true &&
                                                _user?.phone != null)
                                            ? Utils.socialInformation(
                                                'Mobile Number',
                                                '${_user?.phone}')
                                            : Container(),
                                        (checkPrivacy?.gender == true &&
                                                _user?.gender != null)
                                            ? Utils.socialInformation(
                                                'Gender', '${_user?.gender}')
                                            : Container(),
                                        (checkPrivacy?.joining == true)
                                            ? Utils.socialInformation(
                                                'Date of joining',
                                                '${userDetail?.created_at?.m}-${userDetail?.created_at?.d}-${userDetail?.created_at?.Y}')
                                            : Container(),
                                        (checkPrivacy?.university == true &&
                                                userDetail?.high_school != null)
                                            ? Utils.socialInformation(
                                                'University',
                                                '${userDetail?.high_school}')
                                            : Container(),
                                        (checkPrivacy?.hobbies == true &&
                                                userDetail?.hobbies != null)
                                            ? Utils.socialInformation('Hobbies',
                                                '${userDetail?.hobbies}')
                                            : Container(),
                                        (checkPrivacy?.city == true &&
                                                userDetail?.city != null)
                                            ? Utils.socialInformation(
                                                'City', '${userDetail?.city}')
                                            : Container(),
                                        (checkPrivacy?.state == true &&
                                                userDetail?.state != null)
                                            ? Utils.socialInformation(
                                                'State', '${userDetail?.state}')
                                            : Container(),
                                        (checkPrivacy?.country == true &&
                                                userDetail?.country != null)
                                            ? Utils.socialInformation('Country',
                                                '${userDetail?.country}')
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),
            _user?.role == Role.Organization
                ? Padding(
                    padding: EdgeInsets.only(
                        left: Constants.np_padding_only,
                        right: Constants.np_padding_only,
                        top: 10),
                    child: Card(
                      shadowColor: Colors.black12,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => context
                                .read<UserViewModel>()
                                .setSocialInfoVisible(),
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Text(
                                    'Organization Information',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () {
                                      context
                                          .read<UserViewModel>()
                                          .setSocialInfoVisible();
                                    },
                                    child: Icon(
                                      context.read<UserViewModel>().sInfoVisible
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      size: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: context.read<UserViewModel>().sInfoVisible,
                            child: Column(
                              children: [
                                Divider(),
                                Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    child: Column(
                                      children: [
                                        Utils.socialInformation(
                                            'Email', '${_user?.email}'),
                                        Utils.socialInformation(
                                            'EIN', '${_user?.username}'),
                                        Utils.socialInformation(
                                            'Contact Number',
                                            '+1${_user?.phone}'),
                                        Utils.socialInformation(
                                          'Date of joining',
                                          '${userDetail?.created_at?.m}-${userDetail?.created_at?.d}-${userDetail?.created_at?.Y}',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),

            Padding(
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
                        onTap: () =>
                            context.read<UserViewModel>().setWorkPlaceVisible(),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: _user?.role == Role.User
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Workplace Information',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        context
                                            .read<UserViewModel>()
                                            .setWorkPlaceVisible();
                                      },
                                      child: Icon(
                                        context
                                                .read<UserViewModel>()
                                                .wInfoVisible
                                            ? Icons.keyboard_arrow_up
                                            : Icons.keyboard_arrow_down,
                                        size: 17,
                                      ),
                                    ),
                                  ],
                                )
                              : _user?.role == Role.Organization
                                  ? Row(
                                      children: [
                                        Text(
                                          'Organization Location',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Spacer(),
                                        InkWell(
                                          onTap: () {
                                            context
                                                .read<UserViewModel>()
                                                .setWorkPlaceVisible();
                                          },
                                          child: Icon(
                                            context
                                                    .read<UserViewModel>()
                                                    .wInfoVisible
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            size: 17,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                        ),
                      ),
                      Visibility(
                        visible: context.watch<UserViewModel>().wInfoVisible,
                        maintainState: true,
                        child: Column(
                          children: <Widget>[
                            Divider(),
                            _user?.role == Role.User
                                ? (userDetail?.workplace == null)
                                    ? Container()
                                    : Utils.socialInformation(
                                        'Workplace', '${userDetail?.workplace}')
                                : Container(),
                            _user?.role == Role.Organization
                                ? (userDetail?.workplace == null)
                                    ? Container()
                                    : Utils.socialInformation(
                                        'Location', '${userDetail?.workplace}')
                                : Container(),
                            (userDetail?.fax == null)
                                ? Container()
                                : Utils.socialInformation(
                                    'Fax', '${userDetail?.fax}'),
                            /*(userDetail?.workplace_longitude == null)
                            ? Container()
                            :InkWell(
                          onTap:(){
                            Utils.openMap(double.tryParse('${userDetail?.workplace_latitude}'),double.tryParse('${userDetail?.longitude    }'));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text('Get direction',style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                          )
                        ),
                        */
                            ///
                            (userDetail?.workplace_longitude == null)
                                ? Container()
                                : Utils.showMapWithLongLat(
                                    double.tryParse(
                                        '${userDetail?.workplace_longitude}'),
                                    double.tryParse(
                                        '${userDetail?.workplace_latitude}'),
                                    300.0)
                          ],
                        ),
                      ),
                      // Divider(),
                      // (userDetail?.workplace == null) ? Container() : Utils.socialInformation('Workplace', '${userDetail?.workplace}'),
                      // (userDetail?.fax == null) ? Container() : Utils.socialInformation('Fax', '${userDetail?.fax}'),
                      // /*(userDetail?.workplace_longitude == null)
                      //     ? Container()
                      //     :InkWell(
                      //   onTap:(){
                      //     Utils.openMap(double.tryParse('${userDetail?.workplace_latitude}'),double.tryParse('${userDetail?.longitude}'),'${userDetail?.workplace}');
                      //   },
                      //   child: Container(
                      //     padding: EdgeInsets.symmetric(horizontal: 10),
                      //     child: Align(
                      //       alignment: Alignment.centerRight,
                      //       child: Text('Get direction',style: TextStyle(fontWeight: FontWeight.bold),),
                      //     ),
                      //   )
                      // ),*/
                      // (userDetail?.workplace_longitude == null)
                      //     ? Container()
                      //     : Utils.showMapWithLongLat(
                      //     double.tryParse('${userDetail?.workplace_longitude}'),
                      //     double.tryParse('${userDetail?.workplace_latitude}'),
                      //     300.0
                      // ),
                    ],
                  ),
                )),

            //TODO: Add License List
            if (licenseViewModel.licenseList.isEmpty)
              SizedBox()
            else
              Padding(
                padding: EdgeInsets.only(
                    left: Constants.np_padding_only,
                    right: Constants.np_padding_only,
                    top: 10),
                child: Card(
                  shadowColor: Colors.black12,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Visibility(
                    visible: showlicense,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () =>
                              context.read<UserViewModel>().setLicenseVisible(),
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Text(
                                  'License',
                                  style: TextStyle(fontSize: 18),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              context.read<UserViewModel>().isLicenseVisible,
                          child: Column(
                            children: [
                              Divider(),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Container(
                                  height: licenseViewModel.licenseList.isEmpty
                                      ? 100
                                      : 200,
                                  alignment: Alignment.centerLeft,
                                  child: Consumer<LicenseViewModel>(
                                    builder: (context, provider, child) {
                                      final isLoading =
                                          licenseViewModel.isLicenseDataLoading;
                                      List<License> _licenseList =
                                          licenseViewModel.licenseList;
                                      return isLoading
                                          ? Utils.LoadingIndictorWidtet()
                                          : _licenseList.isEmpty
                                              ? Center(
                                                  child: Text('No Licences'))
                                              : ListView.separated(
                                                  itemCount:
                                                      _licenseList.length,
                                                  separatorBuilder:
                                                      (BuildContext context,
                                                              int index) =>
                                                          const Divider(
                                                    height: 2,
                                                  ),
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return ListTile(
                                                      dense: true,
                                                      title: Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.75,
                                                            child:
                                                                SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              child: Text(
                                                                _licenseList[
                                                                            index]
                                                                        .title ??
                                                                    "",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          // Row(
                                                          //   children: [
                                                          //     IconButton(
                                                          //         onPressed: () {
                                                          //           if (!licenseViewModel
                                                          //               .isOpen) {
                                                          //             licenseViewModel
                                                          //                 .isAddOpen();
                                                          //           }
                                                          //           context
                                                          //               .read<LicenseViewModel>()
                                                          //               .setEditValue(
                                                          //               _licenseList[index],
                                                          //               isUpdatingData: true);
                                                          //         },
                                                          //         icon: Icon(Icons.edit)),
                                                          //     IconButton(
                                                          //         onPressed: () {
                                                          //           License _license = License(
                                                          //             id: _licenseList[index].id,
                                                          //           );
                                                          //           _licenseList.removeAt(index);
                                                          //           context
                                                          //               .read<LicenseViewModel>()
                                                          //               .deleteLicense(
                                                          //               _license, authToken!)
                                                          //               .then((value) {});
                                                          //         },
                                                          //         icon: Icon(Icons.delete)),
                                                          //   ],
                                                          // ),
                                                        ],
                                                      ),
                                                      subtitle: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(_licenseList[
                                                                      index]
                                                                  .number ??
                                                              ""),
                                                          Spacer(),
                                                          Text(Utils.changeDateType(
                                                              _licenseList[
                                                                          index]
                                                                      .expiry_date ??
                                                                  "")),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            Padding(
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
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Gallery', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    Container(color: Constants.np_bg_clr, height: 1),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          if (galleryViewModel.getGalleryStatus.status ==
                              Status.IDLE) ...[
                            if (galleryImages.length == 0) ...[
                              Padding(
                                padding:
                                    EdgeInsets.all(Constants.np_padding_only),
                                child: Center(
                                  child: Text(
                                    'No images',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            ] else ...[
                              Utils.galleryImageWidget(
                                  context, galleryImages[0]),
                              (galleryImages.length > 1)
                                  ? Utils.galleryImageWidget(
                                      context, galleryImages[1])
                                  : Container(),
                              (galleryImages.length > 2)
                                  ? Utils.galleryImageWidget(
                                      context, galleryImages[2])
                                  : Container(),
                            ]
                          ] else if (galleryViewModel.getGalleryStatus.status ==
                              Status.BUSY) ...[
                            Utils.LoadingIndictorWidtet(),
                          ]
                        ],
                      ),
                    ),
                    Container(color: Constants.np_bg_clr, height: 1),
                    InkWell(
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MyGalleryScreen(_user?.id)))
                      },
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(Constants.np_padding_only),
                          child: Text('Show all'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _user?.role == Role.Organization
                ? Container()
                : Padding(
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
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Friends',
                                  style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          Container(color: Constants.np_bg_clr, height: 1),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.start,
                              spacing: 5,
                              runSpacing: 5,
                              children: <Widget>[
                                if (_userViewModel
                                        .getFetchFriendStatus.status ==
                                    Status.IDLE) ...[
                                  if (friends.length == 0) ...[
                                    Container(
                                      padding: EdgeInsets.all(
                                          Constants.np_padding_only),
                                      margin: EdgeInsets.only(top: 5),
                                      child: Center(
                                        child: Text(
                                          'No friend',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                                    )
                                  ] else ...[
                                    ProfileFriendCard(friends[0]),
                                    (friends.length > 1)
                                        ? ProfileFriendCard(friends[1])
                                        : Container(),
                                    (friends.length > 2)
                                        ? ProfileFriendCard(friends[2])
                                        : Container(),
                                  ]
                                ] else if (_userViewModel
                                        .getFetchFriendStatus.status ==
                                    Status.IDLE) ...[
                                  Utils.LoadingIndictorWidtet(),
                                ],
                              ],
                            ),
                          ),
                          Container(color: Constants.np_bg_clr, height: 1),
                          InkWell(
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          FriendScreen(_user?.id)))
                            },
                            child: Center(
                              child: Padding(
                                  padding:
                                      EdgeInsets.all(Constants.np_padding_only),
                                  child: Text('Show all')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            LoadPostsForProfile(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget controlContainerText(text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '${text}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget LoadPostsForProfile() {
    showTwoMorePosts() async {
      if (_isLoadingMore == false) {
        if (!mounted) return;
        setState(() {
          _isLoadingMore = true;
          showMoreCounter = showMoreCounter + 7;
        });
        Map data = {'id': '${widget.id}', 'number': '${showMoreCounter}'};
        List<Post?> twoMorePost =
            await Provider.of<MyPostViewModel>(context, listen: false)
                .fetchMyMorePosts(data, '${authToken}');
        if (twoMorePost.length == 0) {
          _allPostsFetched = true;
        }
        if (!mounted) return;
        setState(() {
          _isLoadingMore = false;
          myPosts.addAll(twoMorePost);
        });
      }
    }

    _showMoreBtn = (_allPostsFetched)
        ? Container()
        : InkWell(
            onTap: () {
              showTwoMorePosts();
            },
            child: Container(
                width: 120,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                    color: _isLoadingMore
                        ? Colors.black.withOpacity(0.8)
                        : Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !_isLoadingMore
                        ? Text(
                            'Show more',
                            style: TextStyle(color: Colors.white),
                          )
                        : Text(
                            'Processing',
                            style: TextStyle(color: Colors.white),
                          ),
                    SizedBox(
                      width: 4,
                    ),
                    _isLoadingMore
                        ? Utils.LoadingIndictorWidtet(size: 10.0)
                        : Text('')
                  ],
                )));

    Widget _child = SingleChildScrollView(
      physics: ScrollPhysics(),
      child: Column(
        children: <Widget>[
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: myPosts.length,
              itemBuilder: (context, index) {
                final GlobalKey<FlutterMentionsState> uniqueKey = GlobalKey<FlutterMentionsState>();

                return ShowPostCard(myPosts[index], _mentionList, uniqueKey);
              }),
          _showMoreBtn,
        ],
      ),
    );

    return Container(
      color: Constants.np_bg_clr,
      child: _child,
    );
  }
}
