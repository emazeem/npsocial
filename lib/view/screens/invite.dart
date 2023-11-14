import 'package:flutter/material.dart';
import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

import '../../utils/Utils.dart';

class InviteScreen extends StatefulWidget {
  final Groups? group;

  const InviteScreen(this.group);

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  Future<void> _pullUsers() async {
    Provider.of<UserViewModel>(context, listen: false).fetchAllUsers();
  }

  List<int?> _checkedUsers = [];
  int countCheckedUser = 0;
  String? key;

  @override
  void initState() {
    _pullUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    List<User?> users = _userViewModel.getAllUsers;

    GroupsViewModel groupsViewModel = Provider.of<GroupsViewModel>(context);
    TextEditingController _searchController = TextEditingController();

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
        actions: [
          Center(
            child: InkWell(
              onTap: ()async{
                if(_checkedUsers.length>0){
                  Map data = {
                    'group_id': '${widget.group?.id}',
                    'users': _checkedUsers.join(','),
                    'type': '2'
                  };
                  await groupsViewModel.sendInvitation(data);
                  Navigator.of(context).pop();
                 Utils.toastMessage('Invited Successfully');

                }else{
                  Utils.toastMessage('Select users to invite!');
                }
              },
              child:Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text('Done',style: TextStyle(color: Colors.black),),
              )
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                style: TextStyle(color: Colors.black),
                controller: _searchController,
                onFieldSubmitted: (value) async {
                  setState(() {
                    key=value.length>0?value:null;
                  });
                  await _userViewModel.searchAllUsers(value);
                  setState(() {
                    _searchController.text= key!;
                  });
                },
                decoration: InputDecoration(
                  hintText: key==null?'Search Users to Invite':'Results of ${key}',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 10,top: 5,left: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: (){
                      setState(() {
                        _checkedUsers.clear();
                        for(int i=0;i<users.length;i++){
                          _checkedUsers.add(users[i]?.id);
                        }
                      });
                    },
                    child: Text('Select All',style: TextStyle(fontWeight: FontWeight.bold),)
                ),
                _checkedUsers.length>0?
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_checkedUsers.length < 100? _checkedUsers.length.toString(): '99+',style: TextStyle(fontWeight: FontWeight.bold),),
                    Text(' user${_checkedUsers.length>1?'s':''} selected',style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ):Container(),
                _checkedUsers.length>0?
                InkWell(
                  onTap: (){
                    setState(() {
                      _checkedUsers.clear();
                    });
                  },
                    child: Text('Clear',style: TextStyle(fontWeight: FontWeight.bold),)
                ):Container(),


              ],
            ),
          ),
          Divider(),
          _userViewModel.getStatus.status == Status.BUSY
              ? Center(child: Utils.LoadingIndictorWidtet())
              : SizedBox(),
          _userViewModel.getStatus.status == Status.ERROR
              ? Center(child: Text('Something went wrong'))
              : SizedBox(),
          _userViewModel.getStatus.status == Status.IDLE
              ? (users.length == 0)
                  ? Center(child: Utils.LoadingIndictorWidtet())
                  : Expanded(
                      child: ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          return (users[index]?.id!=widget.group?.created_by) ? ListTile(
                            onTap: () {
                              setState(() {
                                if (_checkedUsers.contains(users[index]?.id)) {
                                  _checkedUsers.remove(users[index]?.id);
                                } else {
                                  _checkedUsers.add(users[index]?.id);
                                }
                              });
                            },
                            title: Text(
                              '${users[index]!.fname} ${users[index]!.lname}',
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: _checkedUsers.contains(users[index]?.id)
                                ? Icon(Icons.check_box)
                                : Icon(Icons.check_box_outline_blank),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                '${Constants.profileImage(users[index])}',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Constants.defaultImage(40.0);
                                },
                              ),
                            ),
                          ):Container();
                        },
                      ),
                    )
              : SizedBox(),
        ],
      ),
    );
  }
}
