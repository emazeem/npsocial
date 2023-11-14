import 'package:flutter/material.dart';
import 'package:np_social/model/CaseStudy.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/view/screens/account_verification.dart';
import 'package:np_social/view/screens/block_list.dart';
import 'package:np_social/view/screens/chat.dart';
import 'package:np_social/view/screens/conferences.dart';

import 'package:np_social/view/screens/create_post.dart';
import 'package:np_social/view/screens/forgot_password.dart';
import 'package:np_social/view/screens/groups.dart';
import 'package:np_social/view/screens/licenses.dart';
import 'package:np_social/view/screens/login.dart';
import 'package:np_social/view/screens/mygallery.dart';
import 'package:np_social/view/screens/near-me.dart';
import 'package:np_social/view/screens/notification.dart';
import 'package:np_social/view/screens/product/market_place.dart';
import 'package:np_social/view/screens/profile.dart';
import 'package:np_social/view/screens/register.dart';
import 'package:np_social/view/screens/register/register_step_1.dart';
import 'package:np_social/view/screens/requests.dart';
import 'package:np_social/view/screens/search.dart';
import 'package:np_social/view/screens/settings/settings.dart';
import 'package:np_social/view/screens/show_case_study.dart';

import '../view/screens/product/product_details.dart';

const String landingPage = 'landing';
const String loginPage = 'login';
const String registerPage = 'register';
const String homePage = 'home';
const String profilePage = 'profile';
const String caseStudy = 'case-study';
const String forgotPasswordPage = 'forgot-password';
const String notificationPage = 'notification';
const String friendRequestPage = 'friend-requests';
const String searchPage = 'search';
const String settingPage = 'setting';
const String friendPage = 'friend';
const String myGalleryPage = 'my-gallery';
const String chatPage = 'chat';
const String splashScreenPage = 'splash';
const String createPostPage = 'create-post';
const String accountVerificationPage = 'account-verification';
const String register_step1 = 'register-step-1';
const String conferenceScreen = 'conferences';
const String groups = 'groups';
const String nearMe = 'near-me';
const String block = 'blocklist';
const String licenses = 'licenses';
const String marketPlace = 'market-place';

Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case loginPage:
      return MaterialPageRoute(builder: (context) => LoginScreen());
    case registerPage:
      return MaterialPageRoute(builder: (context) => RegisterScreen());
    case settingPage:
      return MaterialPageRoute(builder: (context) => SettingScreen());
    case notificationPage:
      return MaterialPageRoute(builder: (context) => NotificationScreen());
    case myGalleryPage:
      return MaterialPageRoute(builder: (context) => MyGalleryScreen(0));
    case searchPage:
      return MaterialPageRoute(builder: (context) => SearchScreen());
    case chatPage:
      return MaterialPageRoute(builder: (context) => ChatScreen());
    case forgotPasswordPage:
      return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());
    case accountVerificationPage:
      return MaterialPageRoute(
          builder: (context) => AccountVerificationScreen());
    case register_step1:
      return MaterialPageRoute(
          builder: (context) => RegisterStep1Screen(
                role: Role.User,
              ));
    case friendRequestPage:
      return MaterialPageRoute(builder: (context) => RequestScreen());
    case conferenceScreen:
      return MaterialPageRoute(builder: (context) => ConferenceScreen());
    case groups:
      return MaterialPageRoute(builder: (context) => GroupsScreen());
    case nearMe:
      return MaterialPageRoute(builder: (context) => NearmeScreen());
    case block:
      return MaterialPageRoute(builder: (context) => BlockScreen());
    case licenses:
      return MaterialPageRoute(builder: (context) => LicenseScreen());
    case caseStudy:
      return MaterialPageRoute(builder: (context) => ShowCaseStudyScreen());
    case marketPlace:
      return MaterialPageRoute(builder: (context) => MarketPlaceScreen());
    case createPostPage:
      return MaterialPageRoute(
          builder: (context) => CreatePostScreen('simple', 0));
    default:
      throw ('This route name does not exists.');
  }
}
