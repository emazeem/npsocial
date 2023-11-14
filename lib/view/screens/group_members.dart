import 'package:flutter/material.dart';
import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../utils/Utils.dart';

class GroupMembersScreen extends StatefulWidget {
  final Groups? group;
  const GroupMembersScreen(this.group);

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  var authId;
  bool? isAdmin = false;
  Future<void> _pullUsers() async {

    Map data = {'group_id': '${widget.group?.id}'};
    Provider.of<GroupsViewModel>(context, listen: false)
        .fetchGroupMembers(data);
  }

  @override
  void initState() {
    _pullUsers();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authId = await AppSharedPref.getAuthId();
      if (widget.group?.created_by == authId) {
        isAdmin = true;
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GroupsViewModel groupsViewModel = Provider.of<GroupsViewModel>(context);

    List<User?>? members = groupsViewModel.getGroupUsers;

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
      body: RefreshIndicator(
        onRefresh: ()async{
          _pullUsers();
        },
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    'Admin',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      '${Constants.profileImage(widget.group?.user!)}',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object exception,
                        StackTrace? stackTrace) {
                          return Constants.defaultImage(40.0);
                          },
                      ),
                    ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${widget.group?.user!.fname} ${widget.group?.user!.lname}',
                      style: TextStyle(fontSize: 18),
                      ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text( 
                          'Admin', 
                          textAlign: TextAlign.center, 
                          style:TextStyle(fontSize: 13), 
                          ),
                  ), 
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    'All Members',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            groupsViewModel.getStatus.status == Status.BUSY
                ? Center(child: Utils.LoadingIndictorWidtet())
                : SizedBox(),
            groupsViewModel.getStatus.status == Status.ERROR
                ? Center(child: Text('Something went wrong'))
                : SizedBox(),
            groupsViewModel.getStatus.status == Status.IDLE
                ? (members.length == 0)
                    ? Center(child: Text('No member'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            return Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Image.network(
                                      '${Constants.profileImage(members![index])}',
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Constants.defaultImage(40.0);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${members[index]?.fname} ${members[index]?.lname}',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                  //Remove member button for admin
                                  (isAdmin == true)
                                      ? TextButton(
                                          onPressed: () async {
                                            var data = {
                                              'group_id': '${widget.group?.id!}',
                                              'user_id': '${members[index]?.id!}'
                                            };

                                            await groupsViewModel
                                                .removeMember(data);
                                            await _pullUsers();
                                          },
                                          child: Text('Remove',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
