import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:np_social/model/Gallery.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/UDetails.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/license.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/res/routes.dart' as route;
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/crop_cover.dart';
import 'package:np_social/view/screens/crop_profile.dart';
import 'package:np_social/view/screens/followers.dart';
import 'package:np_social/view/screens/friends.dart';
import 'package:np_social/view/screens/licenses.dart';
import 'package:np_social/view/screens/mygallery.dart';
import 'package:np_social/view/screens/settings/org_information.dart';
import 'package:np_social/view/screens/settings/practice_location.dart';
import 'package:np_social/view/screens/settings/social_information.dart';
import 'package:np_social/view/screens/settings/update_speciality.dart';
import 'package:np_social/view/screens/widgets/profile_friends_card.dart';
import 'package:np_social/view/screens/widgets/show_post.dart';
import 'package:np_social/view_model/gallery_view_model.dart';
import 'package:np_social/view_model/license_view_model.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/role_view_model.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen();

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<User> friends = [];
  List<Gallery?> galleryImages = [];
  List<Gallery?> gallerySubList = [];
  String? authToken;
  var authId;

  bool profileSelected = false;
  File? profile;
  File? cover;
  int galleryStartIndex = 0;
  bool coverSelected = false;

  bool showMoreBtnFlag = true;
  int showMoreCounter = 0;
  Widget _showMoreBtn = Container();
  bool _allPostsFetched = false;
  bool _isLoadingMore = false;
  List<Post?> myPosts = [];

  bool? isSelectedFile;
  bool showlicense = true;
  int followers = 0;
  List<Map<String, dynamic>> _mentionList = [];

  getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    File file = File(image!.path);
    double temp = file.lengthSync() / (1024 * 1024);
    setState(() {
      isSelectedFile = true;
    });
    if (temp >= 10) {
      Utils.toastMessage('Profile should be less than 10MB.');
      setState(() {
        isSelectedFile = false;
      });
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CropProfile(image),
      ));
    }
  }

  getCover() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => CropCover(image),
    ));
    /*--------------------------------------------*/
    /*File file = File(image!.path);
    setState(() {
      coverSelected = true;
      cover = file;
    });
    await Constants.changeProfile(authToken, authId, file, image.path,
        AppUrl.changeCoverPicture, 'Cover');
    */
  }

  LicenseViewModel licenseViewModel = LicenseViewModel();

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Map data = {'id': '${authId}'};

      Provider.of<UserViewModel>(context, listen: false)
          .fetchFriends(data, '${authToken}');
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
      Map postParam = {'id': '${authId}', 'number': '0'};
      Provider.of<MyPostViewModel>(context, listen: false)
          .fetchMyPosts(postParam, '${authToken}');

      Provider.of<GalleryViewModel>(context, listen: false)
          .fetchMygalleryImages(data, '${authToken}');
      Provider.of<UserDetailsViewModel>(context, listen: false)
          .getUserDetails(data, '${authToken}');
      licenseViewModel = Provider.of<LicenseViewModel>(context, listen: false);
      License _license = License(auth_id: authId);
      licenseViewModel.fetchLicense(_license, authToken!);
      await Provider.of<UserViewModel>(context, listen: false)
          .fetchFollowers({'user_id': '${authId}'});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    licenseViewModel.disposeData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<User?> friends = Provider.of<UserViewModel>(context).getFriends;
    UserViewModel _userViewModel =
        Provider.of<UserViewModel>(context, listen: false);
    User? _user = _userViewModel.getUser;

    myPosts = Provider.of<MyPostViewModel>(context).getMyPosts;
    GalleryViewModel galleryViewModel = Provider.of<GalleryViewModel>(context);
    galleryImages = galleryViewModel.getGalleryImages;
    UserDetail? userDetail =
        Provider.of<UserDetailsViewModel>(context).getDetails;
    followers = Provider.of<UserViewModel>(context).getFollowers.length;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Constants.np_bg_clr,
        child: ListView(
          children: [
            Stack(
              children: [
                Container(
                  color: Colors.white,
                  height: 200,
                  width: double.infinity,
                  child: (coverSelected == false)
                      ? CachedNetworkImage(
                          imageUrl:
                              "${Constants.coverPhoto(authId, userDetail?.cover_photo)}",
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          placeholder: (context, url) =>
                              Utils.LoadingIndictorWidtet(),
                          errorWidget: (context, url, error) => Image.asset(
                            '${Constants.defaultCover}',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.file(cover!, fit: BoxFit.cover),
                ),
                InkWell(
                  onTap: () {
                    getCover();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Constants.np_yellow,
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width - 30),
                    child: Icon(
                      Icons.edit,
                      color: Colors.black,
                      size: 14,
                    ),
                  ),
                )
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
                          child: (profileSelected == false)
                              ? CachedNetworkImage(
                                  placeholder: (context, url) =>
                                      Utils.LoadingIndictorWidtet(),
                                  errorWidget: (context, url, error) =>
                                      Constants.defaultImage(60.0),
                                  imageUrl: "${Constants.profileImage(_user)}",
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : Image.file(
                                  profile!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      getImage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Constants.np_yellow,
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          )),
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(left: 120),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  )
                ],
              ),
            ),

            context.watch<RoleViewModel>().getAuthRole == Role.User
                ? Container(
                    margin: EdgeInsets.only(top: 40),
                    width: MediaQuery.of(context).size.width / 2,
                    child: Center(
                      child: Text(
                        '${_user?.fname} ${_user?.lname}',
                        maxLines: 1,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  )
                : Container(),
            context.watch<RoleViewModel>().getAuthRole == Role.Organization
                ? Container(
                    margin: EdgeInsets.only(top: 40),
                    width: double.infinity,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              '${_user?.fname}',
                              maxLines: 1,
                              //  overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          Image.asset(
                            Constants.orgBadgeImage,
                            width: 20,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),

            context.watch<RoleViewModel>().getAuthRole == Role.Organization
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 3),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => FollowScreen(authId)));
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

            //speciality
            context.watch<RoleViewModel>().getAuthRole == Role.User
                ? Padding(
                    padding: EdgeInsets.zero,
                    child: Container(
                      margin: EdgeInsets.only(top: 10),
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              (userDetail?.speciality?.title == null)
                                  ? 'Add Speciality'
                                  : '${userDetail?.speciality?.title}',
                              overflow: TextOverflow.visible,
                              softWrap: true,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54),
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UpdateSpecialityScreen(userDetail
                                                ?.speciality
                                                ?.id))).then((value) {
                                  Provider.of<UserDetailsViewModel>(context,
                                          listen: false)
                                      .setDetailsResponse(UserDetail());
                                  Provider.of<UserDetailsViewModel>(context,
                                          listen: false)
                                      .getUserDetails(
                                          {'id': '${authId}'}, '${authToken}');
                                });
                              },
                              child: Icon(Icons.edit,
                                  size: 17, color: Colors.black54)),
                        ],
                      ),
                    ),
                  )
                : Container(),

            //about
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
                      onTap: () =>
                          context.read<UserViewModel>().setAboutVisible(),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Text(
                              'About',
                              style: TextStyle(fontSize: 18),
                            ),
                            Spacer(),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => context
                                                      .watch<RoleViewModel>()
                                                      .getAuthRole ==
                                                  Role.User
                                              ? SocialInformationScreen()
                                              : OrgInformationScreen())).then(
                                      (value) {
                                    Provider.of<UserDetailsViewModel>(context,
                                            listen: false)
                                        .setDetailsResponse(UserDetail());
                                    Provider.of<UserDetailsViewModel>(context,
                                            listen: false)
                                        .getUserDetails({'id': '${authId}'},
                                            '${authToken}');
                                  });
                                },
                                child: Icon(
                                  Icons.edit,
                                  size: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: context.read<UserViewModel>().aboutVisible,
                      child: Column(
                        children: [
                          Divider(),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: (userDetail?.about == null)
                                  ? Container()
                                  : Text('${userDetail?.about}'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            //social information
            context.watch<RoleViewModel>().getAuthRole == Role.User
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
                                    'Social Information',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  Spacer(),
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SocialInformationScreen()));
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size: 17,
                                      ))
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
                                        (_user?.phone == null)
                                            ? Container()
                                            : Utils.socialInformation(
                                                'Mobile Number',
                                                '+1${_user?.phone}'),
                                        (_user?.gender == null)
                                            ? Container()
                                            : Utils.socialInformation(
                                                'Gender', '${_user?.gender}'),

                                        Utils.socialInformation(
                                          'Date of joining',
                                          '${userDetail?.created_at?.m}-${userDetail?.created_at?.d}-${userDetail?.created_at?.Y}',
                                        ),
                                        (userDetail?.high_school == null)
                                            ? Container()
                                            : Utils.socialInformation(
                                                'University',
                                                '${userDetail?.high_school}'),
                                        (userDetail?.hobbies == null)
                                            ? Container()
                                            : Utils.socialInformation('Hobbies',
                                                '${userDetail?.hobbies}'),

                                        (userDetail?.city == null)
                                            ? Container()
                                            : Utils.socialInformation(
                                                'City', '${userDetail?.city}'),
                                        (userDetail?.state == null)
                                            ? Container()
                                            : Utils.socialInformation(
                                                'Current State',
                                                '${userDetail?.state}'),
                                        (userDetail?.country == null)
                                            ? Container()
                                            : Utils.socialInformation('Country',
                                                '${userDetail?.country}'),
                                        //(userDetail?.address == null) ? Container() : Utils.socialInformation('Address', '${userDetail?.address}'),
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

            //organization information
            context.watch<RoleViewModel>().getAuthRole == Role.Organization
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
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrgInformationScreen()))
                                            .then((value) {
                                          setState(() {
                                            Provider.of<UserDetailsViewModel>(
                                                    context,
                                                    listen: false)
                                                .setDetailsResponse(
                                                    UserDetail());
                                            Provider.of<UserDetailsViewModel>(
                                                    context,
                                                    listen: false)
                                                .getUserDetails(
                                                    {'id': '${authId}'},
                                                    '${authToken}');
                                          });
                                        });
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        size: 17,
                                      ))
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

            //workplace information
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
                          child: Row(
                            children: [
                              context.watch<RoleViewModel>().getAuthRole ==
                                      Role.User
                                  ? Text(
                                      'Workplace Information',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : Container(),
                              context.watch<RoleViewModel>().getAuthRole ==
                                      Role.Organization
                                  ? Text(
                                      'Organization Location',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : Container(),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PracticeLocationScreen()));
                                },
                                child: Icon(
                                  Icons.edit,
                                  size: 17,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: context.watch<UserViewModel>().wInfoVisible,
                        maintainState: true,
                        child: Column(
                          children: <Widget>[
                            Divider(),
                            context.watch<RoleViewModel>().getAuthRole ==
                                    Role.User
                                ? (userDetail?.workplace == null)
                                    ? Container()
                                    : Utils.socialInformation(
                                        'Workplace', '${userDetail?.workplace}')
                                : Container(),
                            context.watch<RoleViewModel>().getAuthRole ==
                                    Role.Organization
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

            context.watch<RoleViewModel>().getAuthRole == Role.User
                ? licenseViewModel.licenseList.isEmpty
                    ? SizedBox()
                    : Padding(
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
                              Visibility(
                                visible: showlicense,
                                child: InkWell(
                                  onTap: () => context
                                      .read<UserViewModel>()
                                      .setLicenseVisible(),
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Text(
                                          'License',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        Spacer(),
                                        InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              LicenseScreen()))
                                                  .then((value) {
                                                License _license =
                                                    License(auth_id: authId);
                                                licenseViewModel.fetchLicense(
                                                    _license, authToken!);
                                              });
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              size: 17,
                                            ))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: context
                                    .read<UserViewModel>()
                                    .isLicenseVisible,
                                child: Column(
                                  children: [
                                    Divider(),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Container(
                                        height:
                                            licenseViewModel.licenseList.isEmpty
                                                ? 100
                                                : 200,
                                        alignment: Alignment.centerLeft,
                                        child: Consumer<LicenseViewModel>(
                                          builder: (context, provider, child) {
                                            final isLoading = licenseViewModel
                                                .isLicenseDataLoading;
                                            List<License> _licenseList =
                                                licenseViewModel.licenseList;
                                            return isLoading
                                                ? Utils.LoadingIndictorWidtet()
                                                : _licenseList.isEmpty
                                                    ? Center(
                                                        child:
                                                            Text('No Licences'))
                                                    : ListView.separated(
                                                        itemCount:
                                                            _licenseList.length,
                                                        separatorBuilder:
                                                            (BuildContext
                                                                        context,
                                                                    int index) =>
                                                                const Divider(
                                                          height: 2,
                                                        ),
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
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
                                                                      _licenseList[index]
                                                                              .title ??
                                                                          "",
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold,
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
                                                                    _licenseList[index]
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
                        spacing: 5,
                        runSpacing: 5,
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

            context.watch<RoleViewModel>().getAuthRole == Role.User
                ? Padding(
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
                  )
                : Container(),

            LoadPostsForProfile(),
          ],
        ),
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
        Map data = {'id': '${authId}', 'number': '${showMoreCounter}'};
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
                final GlobalKey<FlutterMentionsState> uniqueKey =  GlobalKey<FlutterMentionsState>();
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
