import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:provider/provider.dart';

class ReportUser extends StatefulWidget {
  final int? user;
  const ReportUser(this.user);
  @override
  State<ReportUser> createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  String? authToken;
  int? AuthId;
  bool _isLoading = false;
  final _detailsTxtController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
    });
  }

  ReportUser() async {
    setState(() {
      _isLoading = true;
    });
    dynamic response =
        await Provider.of<PostViewModel>(context, listen: false).reportUser({
      'authId': '${widget.user}',
      'userId': '${AuthId}',
      'description': '${_detailsTxtController.text}',
    }, '${authToken}');
    if (response['data'] == true) {
      Navigator.pop(context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
        child: Material(
          child: Container(
            color: Constants.np_bg_clr,
            child: Padding(
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
                child: Container(
                  height: double.infinity,
                  child: ListView(
                    children: [
                      Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: Text(
                          'Submit report',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          height: 8 * 24.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: _detailsTxtController,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Why do you want to report this user?',
                              fillColor: Colors.grey[100],
                              filled: true,
                              border: InputBorder.none,
                            ),
                          )),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.black,
                          ),
                          child: (_isLoading == false)
                              ? Text('Submit')
                              : Utils.LoadingIndictorWidtet(),
                          onPressed: () async {
                            if (_detailsTxtController.text.isEmpty) {
                              Utils.toastMessage(
                                  'Please enter details for reporting user.');
                            } else {
                              ReportUser();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
