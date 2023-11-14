import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/account_verification.dart';
import 'package:np_social/view/screens/home.dart';
import 'package:np_social/view/screens/login.dart';
import 'package:np_social/view/screens/splash.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'routes.dart' as route;

class Constants {
  static var authToken = 'token';
  static var registerOtp = 'six-digit-register-otp';
  static var userKey = 'user';
  static var authRole = 'authRole';
  static var email_verified = 'email_verified';

  static var user_device_id = 'user_device_id';
  static var isStoredUserDeviceId = 'is_store_user_device';

  static String avatarImage = 'assets/images/avatar.jpg';
  static String defaultCover = 'assets/images/cover.jpg';
  static String noPostImage = AppUrl.url+'main-assets/images/post-deleted.png';

  static String splashScreen = '/';
  static String landingPage = 'landing';
  static String loginPage = 'login';
  static String registerPage = 'register';
  static String homePage = 'home';
  static String profilePage = 'profile';
  static String notificationPage = 'notification';
  static String searchPage = 'search';
  static String settingPage = 'setting';
  static String friendPage = 'friend';
  static String myGalleryPage = 'my-gallery';
  static String chatPage = 'chat';
  static String chatBoxPage = 'chat-box';
  static String forgotPasswordPage = 'forgot-password';
  static String createPostPage = 'create-post';
  static String accountVerificationPage = 'account-verification';
  static String register_step1 = 'register-step-1';
  static String friendRequest = 'friend-requests';
  static String licensePage = 'license';
  static String marketPlacePage = 'market-place';
  static String productDetailsPage = 'product-details';
  static String addProductPage = 'add-product';
  static String orgBadgeImage = 'assets/images/org_bade.png';

  static double np_padding = 5;
  static double np_padding_only = 10;
  var np_bg = 0XFF41494b;
  static Color np_yellow = const Color(0XFFd8b04e);
  static Color np_bg_clr = const Color(0XFFe5e7e2);
  TextStyle np_heading = new TextStyle(
    fontSize: 20,
  );
  static horizontalLine() {
    return Container(color: Constants.np_bg_clr, height: 1);
  }

  static profileImage(user) {
    String profile =
        '${AppUrl.url}storage/profile/${user?.email}/50x50${user?.profile}';
    return profile.toString();
  }

  static coverPhoto(id, path) {
    String profile = '${AppUrl.url}storage/a/covers/${id}/${path}';
    return profile.toString();
  }

  static defaultImage(size) {
    return Image.asset(
      '${Constants.avatarImage}',
      fit: BoxFit.cover,
      width: size,
      height: size,
    );
  }

  static postImage(galleryImage) {
    String image = '${AppUrl.url}storage/a/posts/${galleryImage?.file}';
    return image.toString();
  }

  static postImagecasestudy(galleryImage) {
    String image = '${AppUrl.url}storage/${galleryImage}';
    return image.toString();
  }

  static titleImage() {
    return Image.asset(
      'assets/images/logo.png',
      width: 50,
      height: 50,
    );
  }

  static checkToken(context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(Constants.authToken);
    if (token != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SplashScreen()));
      });
    }
  }

  static authNavigation(context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(Constants.authToken);
    String? nav;
    if (token == null) {
      nav = 'login';
    } else {
      var authId = await AppSharedPref.getAuthId();
      Map datum = {'id': '${authId}'};
      Provider.of<UserDetailsViewModel>(context, listen: false).getUserDetails(datum, token);
      nav = 'home';
    }
    return nav;
  }

  static checkVerificationStatus(context, data) async {
    if (data['email'] == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => AccountVerificationScreen()),
          (Route<dynamic> route) => false);
    }
  }

  static redirectToLoginIfNotAuthUser(context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString(Constants.authToken);
    if (token == null) {
      //user is not login
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false);
    }
  }

  static changeProfile(token, id, file, path, api, input) async {
    var stream = new http.ByteStream(DelegatingStream.typed(file.openRead()));
    var length = await file.length();
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer " + token
    };

    var uri = Uri.parse(api);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFileSign = new http.MultipartFile(
        input.toString().toLowerCase(), stream, length,
        filename: basename(path));
    request.files.add(multipartFileSign);
    request.headers.addAll(headers);
    request.fields['id'] = '${id}';
    var response = await request.send();
    if (response.statusCode == 200) {
      Utils.toastMessage('Your ${input} photo has been updated');
      return {'success': true, 'response': response};
    } else {
      return {'success': false, 'response': response};
    }
  }

  static List networkList() {
    List networks = [];
    networks.add({'title': 'Public', 'key': 'public'});
    networks.add({'title': 'Friends', 'key': 'friends'});
    networks.add({'title': 'Only me', 'key': 'only-me'});
    return networks;
  }
}
