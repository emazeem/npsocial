import 'package:flutter/material.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/groupJoinRequests.dart';
import 'package:np_social/view/screens/groups_details.dart';
import 'package:np_social/view/screens/jobposting/job_detail.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/requests.dart';
import 'package:np_social/view/screens/single_post.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/notification_view_model.dart';
import 'package:np_social/model/Notification.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:np_social/res/routes.dart' as route;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  var authToken;
  int? authId;
  Future<void> _pullRefresh(ctx) async {
    Map data = {'id': '${authId}'};
    Provider.of<NotificationViewModal>(context, listen: false).fetchNotifications(data, '${authToken}');
    Provider.of<NotificationViewModal>(context, listen: false).allNotificationsMarkAsRead(data, '${authToken}');
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Provider.of<NotificationViewModal>(context, listen: false).setMyNotification([]);
      _pullRefresh(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    NotificationViewModal notificationViewModal = Provider.of<NotificationViewModal>(context);
    List<Notifications?> notifications = notificationViewModal.getMyNotification;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Constants.titleImage(),
        leading: GestureDetector(
          child: Icon( Icons.arrow_back_ios),
          onTap: () async{
            authToken = await AppSharedPref.getAuthToken();
            authId = await AppSharedPref.getAuthId();
            Provider.of<UserViewModel>(context, listen: false).setUser(User());
            Provider.of<UserViewModel>(context, listen: false).getUserDetails({'id': '${authId}'}, '${authToken}');
            Navigator.pop(context);
          } ,
        ),
      ),
      body: Container(
          color: Constants.np_bg_clr,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: RefreshIndicator(
                onRefresh:()async{
                  _pullRefresh(context);
                },
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'All Notifications',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Divider(),
                    if (notificationViewModal.getNotificationStatus.status == Status.IDLE) ...[
                      if (notifications.length == 0) ...[
                        Card(
                          child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(Constants.np_padding),
                            child: Text('No notification'),
                          ),
                        )
                      ] else ...[
                        for (var notification in notifications)
                          notificationCard(notification),
                      ]
                    ] else if (notificationViewModal.getNotificationStatus.status == Status.BUSY) ...[
                      Utils.LoadingIndictorWidtet(),
                    ],
                  ],
                ),
              )
          )),
      backgroundColor: Colors.white,
    );






  }

  Widget notificationCard(Notifications? notification) {
    return InkWell(
      onTap: (){

        if(notification?.url == 'friend'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileScreen(notification?.data_id)));
        }
        if(notification?.url == 'post'){
          print(notification?.data_id);
          Navigator.push(context, MaterialPageRoute(builder: (context) => SinglePostScreen(notification?.data_id)));
        }
        if(notification?.url == 'chat'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => NPLayout(currentIndex: 3)));
        }
        if(notification?.url == 'group-request'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => RequestScreen(initialIndex: 1,)));
        }
        if(notification?.url == 'admin-group-requests'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupJoinRequests(notification?.data_id)));
        }
        if(notification?.url == 'group'){
          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDetailsScreen(notification?.data_id)));
        }
       
        if(notification?.url == 'job'){
          print(notification);
          print ('job id : ${notification?.data_id}');
          print('1111111');
          if (notification?.data_id != null) {
            print('22222222');
            Navigator.push(context, MaterialPageRoute(builder: (context) => JobDetailScreen(jobId:notification?.data_id)));
          }
        }
      },
      child: Card(
        color: (notification?.read_at == null) ? Colors.grey.shade100 : Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  '${Constants.profileImage(notification?.from)}',
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${notification?.from?.fname} ',style: const TextStyle(fontWeight: FontWeight.bold),),
                        const Padding(
                            padding:EdgeInsets.only(left:3)
                        ),
                        Text('${notification?.from?.lname} ' ,style: const TextStyle(fontWeight: FontWeight.bold),),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width-100,
                      child:Text('${notification?.msg}',overflow: TextOverflow.ellipsis,maxLines: 3,),
                    ),
                    Text('${notification?.created_at?.h}:${notification?.created_at?.i} ${notification?.created_at?.A} ${notification?.created_at?.m}-${notification?.created_at?.d}-${notification?.created_at?.Y}',style: TextStyle(color: Colors.grey,fontSize: 11),),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
