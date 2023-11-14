import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/account_verification.dart';
import 'package:np_social/view/screens/product/add_product.dart';
import 'package:np_social/view/screens/chat.dart';
import 'package:np_social/view/screens/chatbox.dart';
import 'package:np_social/view/screens/create_post.dart';
import 'package:np_social/view/screens/forgot_password.dart';
import 'package:np_social/view/screens/friends.dart';
import 'package:np_social/view/screens/home.dart';
import 'package:np_social/view/screens/landing.dart';
import 'package:np_social/view/screens/licenses.dart';
import 'package:np_social/view/screens/login.dart';
import 'package:np_social/view/screens/product/market_place.dart';
import 'package:np_social/view/screens/mygallery.dart';
import 'package:np_social/view/screens/notification.dart';
import 'package:np_social/view/screens/product/product_details.dart';
import 'package:np_social/view/screens/profile.dart';
import 'package:np_social/view/screens/register.dart';
import 'package:np_social/view/screens/register/register_step_1.dart';
import 'package:np_social/view/screens/requests.dart';
import 'package:np_social/view/screens/search.dart';
import 'package:np_social/view/screens/settings/settings.dart';
import 'package:np_social/view/screens/splash.dart';
import 'package:np_social/view/screens/video_thumbnail.dart';
import 'package:np_social/view/screens/widgets/drawer_info.dart';
import 'package:np_social/view_model/ConferenceViewModel.dart';
import 'package:np_social/view_model/UserDeviceViewModel.dart';
import 'package:np_social/view_model/ads_view_model.dart'; 
import 'package:np_social/view_model/auth_token_view_model.dart';
import 'package:np_social/view_model/auth_view_model.dart';
import 'package:np_social/view_model/case_study_view_model.dart';
import 'package:np_social/view_model/chat_view_model.dart';
import 'package:np_social/view_model/comment_view_model.dart';
import 'package:np_social/view_model/friend_view_model.dart';
import 'package:np_social/view_model/gallery_view_model.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/job_view_model.dart';
import 'package:np_social/view_model/license_view_model.dart';
import 'package:np_social/view_model/like_view_model.dart';
import 'package:np_social/view_model/notification_view_model.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/privacy_view_model.dart';
import 'package:np_social/view_model/product_category_view_model.dart';
import 'package:np_social/view_model/products_view_model.dart';
import 'package:np_social/view_model/role_view_model.dart';
import 'package:np_social/view_model/search_view_model.dart';
import 'package:np_social/view_model/u_details_view_model.dart';
import 'package:np_social/view_model/user_near_me_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_mentions/flutter_mentions.dart' as mentions;
import 'package:flutter/foundation.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClientx(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = new MyHttpOverrides();
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    initOneSignal(context);
    super.initState();
  }

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

    // The promptForPushNotificationsWithUserResponse function will show the iOS push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
    await OneSignal.shared.promptUserForPushNotificationPermission(
      fallbackToSettings: true,
    );

    /// Calls when foreground notification arrives.
    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (handleForegroundNotifications) {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(create: (context) {
          return AuthViewModel();
        }),
        ChangeNotifierProvider<UserViewModel>(create: (context) {
          return UserViewModel();
        }),
        ChangeNotifierProvider<AuthTokenViewModel>(create: (context) {
          return AuthTokenViewModel();
        }),
        ChangeNotifierProvider<PostViewModel>(create: (context) {
          return PostViewModel();
        }),
        ChangeNotifierProvider<CommentViewModel>(create: (context) {
          return CommentViewModel();
        }),
        ChangeNotifierProvider<MyPostViewModel>(create: (context) {
          return MyPostViewModel();
        }),
        ChangeNotifierProvider<GalleryViewModel>(create: (context) {
          return GalleryViewModel();
        }),
        ChangeNotifierProvider<NotificationViewModal>(create: (context) {
          return NotificationViewModal();
        }),
        ChangeNotifierProvider<UserDetailsViewModel>(create: (context) {
          return UserDetailsViewModel();
        }),
        ChangeNotifierProvider<LikeViewModel>(create: (context) {
          return LikeViewModel();
        }),
        ChangeNotifierProvider<ChatViewModel>(create: (context) {
          return ChatViewModel();
        }),
        ChangeNotifierProvider<OtherUserDetailsViewModel>(create: (context) {
          return OtherUserDetailsViewModel();
        }),
        ChangeNotifierProvider<FriendViewModel>(create: (context) {
          return FriendViewModel();
        }),
        ChangeNotifierProvider<OtherUserViewModel>(create: (context) {
          return OtherUserViewModel();
        }),
        ChangeNotifierProvider<UserDeviceViewModel>(create: (context) {
          return UserDeviceViewModel();
        }),
        ChangeNotifierProvider<PrivacyViewModel>(create: (context) {
          return PrivacyViewModel();
        }),
        ChangeNotifierProvider<LicenseViewModel>(create: (context) {
          return LicenseViewModel();
        }),
        ChangeNotifierProvider<ProductViewModel>(create: (context) {
          return ProductViewModel();
        }),
        ChangeNotifierProvider<ProductCategoryViewModel>(create: (context) {
          return ProductCategoryViewModel();
        }),
        ChangeNotifierProvider<UserNearmeViewModel>(create: (context) {
          return UserNearmeViewModel();
        }),
        ChangeNotifierProvider<CaseStudyViewModel>(create: (context) {
          return CaseStudyViewModel();
        }),
        ChangeNotifierProvider<SearchViewModel>(create: (context) {
          return SearchViewModel();
        }),
        ChangeNotifierProvider<GroupsViewModel>(create: (context) {
          return GroupsViewModel();
        }),
        ChangeNotifierProvider<ConferenceViewModel>(create: (context) {
          return ConferenceViewModel();
        }),
        ChangeNotifierProvider<RoleViewModel>(create: (context) {
          return RoleViewModel();
        }),
        ChangeNotifierProvider<AdsViewModel>(create: (context) {
          return AdsViewModel();
        }),
        ChangeNotifierProvider<JobViewModel>(create: (context) {
          return JobViewModel();
        }),
        ChangeNotifierProvider<DrawerStateInfo>(create :(context) {
          return DrawerStateInfo();
        }),
           
      ],
      child: MaterialApp(
        builder: (_, child) => mentions.Portal(child: child!),
        debugShowCheckedModeBanner: false,
        title: 'NP Social',
        theme: ThemeData(
          appBarTheme: AppBarTheme(),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor:
                Constants.np_yellow, // Set the color of the input cursor
            selectionColor: Colors
                .grey.shade300, // Set the color of the text selection handles
          ),
          inputDecorationTheme: InputDecorationTheme(
            suffixIconColor: Colors.black54,
            prefixIconColor: Colors.black54,
            iconColor: Colors.grey,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Constants.np_yellow),
            ),
            labelStyle: TextStyle(color: Colors.black54),
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
          ),
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all<Color>(
                Constants.np_yellow), // Set the thumb color
            // trackColor: MaterialStateProperty.all<Color>(Colors.red), // Set the track color
          ),
        ),
        initialRoute: Constants.landingPage,
        routes: {
          Constants.landingPage: (context) => LandingPage(),
          Constants.loginPage: (context) => LoginScreen(),
          Constants.registerPage: (context) => RegisterScreen(),
          Constants.homePage: (context) => HomeScreen(),
          Constants.friendPage: (context) => FriendScreen(0),
          Constants.profilePage: (context) => ProfileScreen(),
          Constants.licensePage: (context) => LicenseScreen(),
          Constants.marketPlacePage: (context) => MarketPlaceScreen(),
          Constants.productDetailsPage: (context) => ProductDetailsScreen(ModalRoute.of(context)?.settings.arguments as ScreenArguments),
          Constants.addProductPage: (context) => AddProductScreen(),
          Constants.settingPage: (context) => SettingScreen(),
          Constants.notificationPage: (context) => NotificationScreen(),
          Constants.myGalleryPage: (context) => MyGalleryScreen(0),
          Constants.searchPage: (context) => SearchScreen(),
          Constants.chatPage: (context) => ChatScreen(),
          Constants.forgotPasswordPage: (context) => ForgotPasswordScreen(),
          Constants.accountVerificationPage: (context) => AccountVerificationScreen(),
          Constants.chatBoxPage: (context) => ChatBoxScreen(User()),
          Constants.createPostPage: (context) => CreatePostScreen('simple', 0),
          Constants.register_step1: (context) => RegisterStep1Screen(role: Role.User),
          Constants.splashScreen: (context) => SplashScreen(),
          Constants.friendRequest: (context) => RequestScreen(),
          'video-thumbnail': (context) => HomePage(title: 'Homepage'),
        },
      ),
    );
  }
}
