import 'package:flutter/material.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/chatbox.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/res/routes.dart' as route;
import 'package:np_social/view/screens/profile.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ProfileFriendCard extends StatefulWidget {
  final User? user;

  const ProfileFriendCard(this.user);

  @override
  State<ProfileFriendCard> createState() => _ProfileFriendCardState();
}

class _ProfileFriendCardState extends State<ProfileFriendCard> {
  var authToken;
  var authId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
    });
  }

  @override
  Widget build(BuildContext context) {
    unfriend(user) async {
      UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
      dynamic response = await _userViewModel.unfriend({'from': '${authId}', 'to': '${user}'}, '${authToken}');
      if (response['success'] == true) {
        Utils.toastMessage(response['message']);
      } else {
        Utils.toastMessage('Some error occurred.!');
      }
    }

    void handleClick(int item) async {
      switch (item) {
        case 0:
          await unfriend(widget.user?.id);
          break;
        case 1:
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatBoxScreen(widget.user)));
          break;
      }
    }

    return InkWell(
      onTap: () {
        if (widget.user?.id == authId) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NPLayout(currentIndex: 4)));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => OtherProfileScreen(widget.user?.id)));
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width/3.61,
          height: MediaQuery.of(context).size.width/3.61+20,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/image-placeholder.png',
                image:'${Constants.profileImage(widget.user)}',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.width/3.61,
                width: MediaQuery.of(context).size.width/3.61,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Constants.defaultImage(MediaQuery.of(context).size.width/3.61);
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 3),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  '${widget.user?.fname} ${widget.user?.lname}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            /*InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatBoxScreen(widget.user)));
                },
                child: Text(
                  'Send message',
                  style: TextStyle(fontSize: 11),
                ),
              )
              */
          ],
        )
      ),
    );
  }
}
