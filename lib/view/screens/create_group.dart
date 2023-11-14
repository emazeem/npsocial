import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/res/routes.dart' as route;
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen();

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
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

  CroppedFile? _croppedFile;

  bool? isSelectedFile = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
    });
  }

  Future<dynamic> getImage(String type) async {
    final ImagePicker _picker = ImagePicker();
    imagePath = await _picker.pickImage(
      source: (type == 'gallery') ? ImageSource.gallery : ImageSource.camera,
      // imageQuality: 100,
      maxHeight: 300,
    );
    if (imagePath != null) {
      File file = File(imagePath!.path);
      double temp = file.lengthSync() / (1024 * 1024);
      setState(() {
        isSelectedFile = true;
      });
      postImage = file;
    } else {
      setState(() {
        isSelectedFile = false;
      });
      Utils.toastMessage('Image not selected!');
    }
  }

  void removeAttachment() {
    postImage = null;
    setState(() {
      isSelectedFile = false;
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'Create group',
                        style: Constants().np_heading,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    (isSelectedFile == true)
                        ? Container(
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text('Cover Photo selected'),
                                ),
                                InkWell(
                                  onTap: () {
                                    removeAttachment();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    color: Colors.black,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(children: [
                            Container(
                              margin: EdgeInsets.only(top: 10, right: 10),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.black,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: InkWell(
                                      onTap: () {
                                        getImage('gallery');
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 10, right: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: Colors.black,
                                ),
                                child: InkWell(
                                  onTap: () {
                                    getImage('camera');
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Icon(
                                      Icons.camera_alt_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                )),
                          ])
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
                        hintText: 'Title...',
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
                        hintText: 'Write description...',
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
                            ? Text('Create group')
                            : Utils.LoadingIndictorWidtet(),
                        onPressed: () async {
                          if (_titleTxtController.text.isEmpty) {
                            Utils.toastMessage('Title is required');
                          } else if (_detailsTxtController.text.isEmpty) {
                            Utils.toastMessage('Description is required');
                          } else if (imagePath?.path == null) {
                            Utils.toastMessage('Cover photo is required');
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
    String uploadUrl = AppUrl.createGroup;
    final path = postImage!.path;
    var formData = FormData.fromMap(
      {
        'title': _titleTxtController.text,
        'description': _detailsTxtController.text,
        'image': await MultipartFile.fromFile(path, filename: basename(path)),
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
      Utils.toastMessage('Group created successfully!');
      Navigator.pop(context);
    } else {
      
    }

  }
}
