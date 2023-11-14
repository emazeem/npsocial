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
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/role_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class CreatePostScreen extends StatefulWidget {
  final String? type;
  final int? groupId;


  const CreatePostScreen(this.type, this.groupId);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  var authToken;
  var authId;

  final _detailsTxtController = TextEditingController();
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

  void getImage(String type) async {
    final ImagePicker _picker = ImagePicker();
    imagePath = await _picker.pickImage(
      source: (type == 'gallery') ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 100,
      maxHeight: 1000,
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
    if (widget.type == 'image') {
      postImage = null;
    }
    if (widget.type == 'video') {
      postVideo = null;
    }
    if (widget.type == 'audio') {
      postAudio = null;
    }
    setState(() {
      isSelectedFile = false;
    });
  }

  void _pickVideoFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowCompression: true,
      type: FileType.video,
    );
    String? _path;
    try {
      _path = await VideoThumbnail.thumbnailFile(
        video: result!.files.single.path!,
        thumbnailPath: (await getTemporaryDirectory()).path,

        /// path_provider
        imageFormat: ImageFormat.PNG,
        maxHeight: 700,
        quality: 100,
      );
    } catch (e) {
      print(e);
    }
    if (result != null) {
      postVideo = File(result.files.single.path!);
      if (_path != null) {
        videThumbnail = File(_path!);
      }
      double temp =
          File(result.files.single.path!).lengthSync() / (1024 * 1024);
      setState(() {
        isSelectedFile = true;
      });
      if (temp >= 20) {
        Utils.toastMessage('Video should be less than 20MB.');
        postVideo = null;
        setState(() {
          isSelectedFile = false;
        });
      }
    } else {
      result = null;
      setState(() {
        isSelectedFile = false;
      });
      Utils.toastMessage('Video not selected!');
    }
  }

  void _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowCompression: true,
        allowedExtensions: ['mp3', 'wav', 'ogg', 'm4a'],
        type: FileType.custom);

    if (result != null) {
      postAudio = File(result.files.single.path!);
      double temp =
          File(result.files.single.path!).lengthSync() / (1024 * 1024);
      setState(() {
        isSelectedFile = true;
      });
      if (temp >= 20) {
        Utils.toastMessage('Video should be less than 20MB.');
        postAudio = null;
        setState(() {
          isSelectedFile = false;
        });
      }
    } else {
      postAudio = null;
      setState(() {
        isSelectedFile = false;
      });
      Utils.toastMessage('Audio not selected!');
    }
  }

  pickRespectiveFile() {
    if (widget.type == 'image') {
      getImage('gallery');
    }
    if (widget.type == 'video') {
      _pickVideoFile();
    }
    if (widget.type == 'audio') {
      _pickAudioFile();
    }
  }

  @override
  Widget build(BuildContext context) {
    MyPostViewModel _myPostViewModel = Provider.of<MyPostViewModel>(context);
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    User? authUser = _userViewModel.getUser;

    Widget _image() {
      if (_croppedFile != null) {
        final path = _croppedFile!.path;
        return Container(
          color: Colors.grey.shade200,
          width: double.infinity,
          height: 300,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Image.file(File(path)),
        );
      } else if (postImage != null) {
        final path = postImage!.path;
        return Container(
          color: Colors.grey.shade200,
          width: double.infinity,
          height: 300,
          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.all(10),
          child: Image.file(File(path)),
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    Future<void> _cropImage() async {
      if (postImage != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: postImage!.path,
          compressFormat: ImageCompressFormat.jpg,
    
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.black,
              cropFrameColor: Colors.grey,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
              presentStyle: CropperPresentStyle.dialog,
              boundary: const CroppieBoundary(
                width: 520,
                height: 520,
              ),
              viewPort: const CroppieViewPort(
                  width: 480, height: 480, type: 'circle'),
              enableExif: true,
              enableZoom: true,
              showZoomer: true,
            ),
          ],
        );
        if (croppedFile != null) {
          setState(() {
            _croppedFile = croppedFile;
          });
        }
      }
    }

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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            (widget.groupId!=0)?Icon(Icons.group_rounded):Container(),
                            Text(
                              ' Create ${(widget.type != 'simple' ? widget.type : '')} post',
                              style: Constants().np_heading,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                      if (widget.type != 'simple') ...[
                        (isSelectedFile == true)
                            ? Container(
                          child: Row(
                            children: [
                              Container(
                                padding:
                                EdgeInsets.symmetric(horizontal: 5),
                                child: Text('1 ${widget.type} selected'),
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
                            : Row(
                          children: [
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
                                      onTap: pickRespectiveFile,
                                      child: Row(
                                        children: [
                                          widget.type == 'image'
                                              ? Icon(
                                            Icons.image,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                              : SizedBox(),
                                          widget.type == 'video'
                                              ? Icon(
                                            Icons
                                                .slow_motion_video_outlined,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                              : SizedBox(),
                                          widget.type == 'audio'
                                              ? Icon(
                                            Icons.audiotrack,
                                            size: 20,
                                            color: Colors.white,
                                          )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            if (widget.type == 'image') ...[
                              Container(
                                  margin:
                                  EdgeInsets.only(top: 10, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5)),
                                    color: Colors.black,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      if (widget.type == 'image') {
                                        getImage('camera');
                                      }
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
                            ]
                          ],
                        )
                      ],
                    ],
                  ),
                ),
                Divider(),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: (authUser?.profile == null)
                            ? Utils.LoadingIndictorWidtet()
                            : Image.network(
                                '${Constants.profileImage(authUser)}',
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Constants.defaultImage(40.0);
                                },
                              ),
                      ),
                    ),
                    context.watch<RoleViewModel>().getAuthRole== Role.User?
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          '${authUser?.fname} ${authUser?.lname}',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ):Container(),
                    context.watch<RoleViewModel>().getAuthRole== Role.Organization?
                      Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: Text(
                          '${authUser?.fname}',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ):Container(),


                  ],
                ),
                Container(
                    margin: EdgeInsets.all(10),
                    height: 7 * 24.0,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      controller: _detailsTxtController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: 'Write something ...',
                        fillColor: Colors.grey[100],
                        filled: true,
                        border: InputBorder.none,
                      ),
                    )),
                    
                if (widget.type == 'image') ...[
                  _image(),
                  if (_croppedFile != null || postImage != null) ...[
                    Container(
                      color: Colors.grey.shade300,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                              child: Container(
                            color: Colors.grey.shade400,
                            padding: EdgeInsets.all(10),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _croppedFile = null;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.undo),
                                  Text(
                                    'Revert',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.all(10),
                            color: Colors.grey.shade300,
                            child: InkWell(
                              onTap: () {
                                _cropImage();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.crop),
                                  Text(
                                    'Crop',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    )
                  ]
                ],
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
                                                  return Constants.defaultImage(
                                                      20.0);
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
                                                'assets/images/friends.png',
                                                width: 20,
                                                height: 20,
                                                errorBuilder: (BuildContext
                                                        context,
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
                            ? Text('Share post')
                            : Utils.LoadingIndictorWidtet(),
                        onPressed: () async {
                          uploadFile(context);
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
    String uploadUrl = AppUrl.createPost;

    var formData;


    if (widget.type != 'simple') {
      if (widget.type == 'image') {
        if (imagePath != null) {
          String path;
          if (_croppedFile == null) {
            path = postImage!.path;
          } else {
            path = _croppedFile!.path;
          }

          //String path = imagePath!.path;
          formData = FormData.fromMap(
            {
              'group_id':'${widget.groupId}',
              'details': _detailsTxtController.text,
              'user': "${authId}",
              'privacy': "${_privacy}",
              'attachment': await MultipartFile.fromFile(path, filename: basename(path)),
              'file_type': '${widget.type}',
              "image_path": "${postImage!}",
            },
          );
        } else {
          Utils.toastMessage('Please select ${widget.type}');
        }
      } else if (widget.type == 'video') {
        if (postVideo != null) {
          String path = postVideo!.path;
          String vthumbnail = videThumbnail!.path;
          formData = FormData.fromMap(
            {
              'group_id':'${widget.groupId}',
              'details': _detailsTxtController.text,
              'user': "${authId}",
              'privacy': "${_privacy}",
              'attachment': await MultipartFile.fromFile(path, filename: basename(path)),
              'thumbnail': await MultipartFile.fromFile(vthumbnail,
                  filename: basename(vthumbnail)),
              'file_type': '${widget.type}',
              "image_path": "${postVideo!}",
            },
          );
        } else {
          Utils.toastMessage('Please select ${widget.type}');
        }
      } else if (widget.type == 'audio') {
        if (postAudio != null) {
          String path = postAudio!.path;
          formData = FormData.fromMap(
            {
              'group_id':'${widget.groupId}',
              'details': _detailsTxtController.text,
              'user': "${authId}",
              'privacy': "${_privacy}",
              'attachment':
                  await MultipartFile.fromFile(path, filename: basename(path)),
              'file_type': '${widget.type}',
              "image_path": "${postAudio!}",
            },
          );
        } else {
          Utils.toastMessage('Please select ${widget.type}');
        }
      }
    } else {
      if (_detailsTxtController.text.isNotEmpty) {
        formData = FormData.fromMap(
          {
            'group_id':'${widget.groupId}',
            'details': _detailsTxtController.text,
            'user': "${authId}",
            'privacy': "${_privacy}",
          },
        );
      } else {
        Utils.toastMessage('Write something...');
      }
    }

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
      Utils.toastMessage('Your post has been added');
      if(widget.groupId==0){
        Navigator.push(context, MaterialPageRoute(builder: (context) => NPLayout()));
      }else{
        Navigator.pop(context);
      }
    } else {
    }
  }
}
