import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_social/model/Groups.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/res/routes.dart' as route;
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/groups_details.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class UpdateGroupScreen extends StatefulWidget {
  final Groups? group;
   UpdateGroupScreen( this.group);

  @override
  State<UpdateGroupScreen> createState() => _UpdateGroupScreenState();
}

class _UpdateGroupScreenState extends State<UpdateGroupScreen> {
  var authToken;
  var authId;

  final _detailsTxtController = TextEditingController();
  final _titleTxtController = TextEditingController();

  String _privacy = 'public';

  File? postImage;
  XFile? imagePath;
  File? postAudio;
  File? postVideo;
  File? videThumbnail;
  int _isUploading = 0;


  bool? isSelectedFile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      _titleTxtController.text='${widget.group!.title.toString()}';
      _detailsTxtController.text='${widget.group!.description.toString()}';
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
        color: Constants.np_bg_clr,
        child: Card(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   
                    Container(
                      width: MediaQuery.of(context).size.width/1.1,
                      child: Text(
                       "Update group ${widget.group!.title.toString()}",
                          style: Constants().np_heading,
                          textAlign: TextAlign.left,
                        ),
                    ),
                    
                  ],
                ),
                Divider(),
                Container(
                    margin: EdgeInsets.all(10),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      maxLines: 1,
                      controller: _titleTxtController,
                      maxLength: 60,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        fillColor: Colors.grey[100],
                        
                        filled: true,
                        border: InputBorder.none,
                      ),
                    )),
                Container(
                    margin: EdgeInsets.all(10),
                    height: 5 * 24.0,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _detailsTxtController,
                      maxLines: 6,
                      maxLength: 250,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: InputBorder.none,
                      ),
                    )),
                Container(
                  height: postImage == null
                      ? 0
                      : MediaQuery.of(context).size.height / 5,
                  width: postImage == null
                      ? 0
                      : MediaQuery.of(context).size.width * 0.5,
                  child: postImage == null
                      ? Container()
                      : Image.file(
                          postImage!,
                          scale: 2,
                        ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: false,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(),
                              child: PopupMenuButton<String>(
                                  color: Colors.white,
                                  icon: Icon(Icons.arrow_drop_down),
                                  // Callback that sets the selected popup menu item.
                                  onSelected: (String pri) {
                                    setState(() {
                                      _privacy = pri;
                                    });
                                  },
                                  itemBuilder: (BuildContext context) => [
                                        PopupMenuItem<String>(
                                          value: 'public',
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/public.png',
                                                width: 20,
                                                height: 20,
                                                errorBuilder: (BuildContext
                                                        context,
                                                    Object exception,
                                                    StackTrace? stackTrace) {
                                                  return Constants.defaultImage(20.0);
                                                },
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10)),
                                              Text('Public'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'friends',
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                'assets/images/friends.png', width: 20, height: 20, 
                                                  errorBuilder: (BuildContextcontext,
                                                    Object exception,
                                                    StackTrace? stackTrace) {
                                                  return Constants.defaultImage(
                                                      20.0);
                                                },
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10)),
                                              Text('Friends'),
                                            ],
                                          ),
                                        ),
                                      ]),
                            ),
                            Text('${_privacy.toUpperCase()}'),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.black,
                        ),
                        child: (_isUploading == 0)
                            ? Text('Update group')
                            : Utils.LoadingIndictorWidtet(),
                        onPressed: () async {
                          if (_titleTxtController.text.isEmpty) {
                            Utils.toastMessage('Title is required');
                          } else if (_detailsTxtController.text.isEmpty) {
                            Utils.toastMessage('Description is required');
                          } else {
                            uploadFile(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Dio dio = new Dio();
  uploadFile(context) async {
    setState(() {
      _isUploading = 1;
    });
    String uploadUrl = AppUrl.groupUpdate;

    var formData = FormData.fromMap(
      {
        'id': widget.group!.id,
        'title': _titleTxtController.text,
        'description': _detailsTxtController.text,
      },
    );

    Response response = await dio.post(
      uploadUrl,
      data: formData,
      options: Options(
        headers: {
          "Accept": "application/json",
          'Authorization': "Bearer " + authToken
        },
        receiveTimeout: 200000,
        sendTimeout: 200000,
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
        
      ),
    );
    setState(() {
      _isUploading = 0;
    });
    if (response.statusCode == 200) {
      Utils.toastMessage('Group details updated successfully!'); 
      Navigator.pop(context);
      
    } else { 
      Utils.toastMessage('Something went wrong!');
    }

  }
}
