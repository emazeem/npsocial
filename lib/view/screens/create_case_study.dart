import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/view/screens/show_case_study.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import '../../model/User.dart';
import '../../utils/Utils.dart';

class CreateCaseStudyScreen extends StatefulWidget {
  @override
  State<CreateCaseStudyScreen> createState() => _CreateCaseStudyScreenState();
}

class _CreateCaseStudyScreenState extends State<CreateCaseStudyScreen> {
  var authToken;
  var authId;

  final _detailsTxtController = TextEditingController();
  final _titleTxtController = TextEditingController();
  String _privacy = 'public';
  File? postpdf;
  bool? pdfselected = false;
  String? pdfname;
  File? postImage;
  XFile? imagePath;

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
    imagePath = (await _picker.pickImage(
      source: (type == 'gallery') ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 100,
      maxHeight: 1000,
    ));
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

  void _pickPdfFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf','*'],
      
    );
    File file;
    if (result != null) {
      File file = File(result.files.single.path!);
      double temp = file.lengthSync() / (1024 * 1024);
      if (temp > 10) {
        Utils.toastMessage('File size should be less than 10 MB');
      } else if (file.path.split('.').last != 'pdf') {
          Utils.toastMessage('File type should be pdf');
        } 
        else {
        setState(() {
          postpdf = file;
          pdfselected = true;
          pdfname = basename(file.path);
        });
    }} else {
      Utils.toastMessage('File not selected!');
    }
  }
  
 

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    User? authUser = _userViewModel.getUser;

    Widget _image() {
      if (_croppedFile != null) {
        final path = _croppedFile!.path;
        return Container(
          color: Colors.grey.shade200,
          width: double.infinity,
          height: 200,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Image.file(File(path)),
        );
      } else if (postImage != null) {
        final path = postImage!.path;
        return Container(
          color: Colors.grey.shade200,

          margin: EdgeInsets.symmetric(horizontal: 10),
          padding: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.file(File(path),
              height: MediaQuery.of(context).size.height/5,
              width: MediaQuery.of(context).size.width/1.3,
              fit: BoxFit.contain,),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    Future<void> _cropImage() async {
      if (postImage != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: postImage!.path,
         

          //don't compress image

          compressQuality: 50,
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
        child: Column(
          children: [
            Expanded(
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
                              'Create Case Study',
                              style: Constants().np_heading,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
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
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Constants.defaultImage(40.0);
                                      },
                                    ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Text(
                              '${authUser?.fname} ${authUser?.lname}',
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          TextField(
                            controller: _titleTxtController,
                            maxLines: 1,
                            maxLength: 100,
                            decoration: InputDecoration(
                              hintText: 'Add Title...',
                              fillColor: Colors.grey[100],
                              filled: true,
                              border: InputBorder.none,
                            ),
                          ),
                          TextField(
                            controller: _detailsTxtController,
                            maxLines: 8,
                            maxLength: 1000,
                            decoration: InputDecoration(
                              hintText: ' Add Details...',
                              fillColor: Colors.grey[100],
                              filled: true,
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                      _image(),
                      isSelectedFile == true
                          ? Container(
                              color: Colors.grey.shade300,
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:MainAxisAlignment.spaceAround,
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
                                      mainAxisAlignment:MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.undo),
                                        Text('Revert',textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      color: Colors.grey.shade300,
                                      child: InkWell(
                                    onTap: () {
                                      _cropImage();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.crop),
                                        Text(
                                          'Crop',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10
                                          ),
                                        ),
                                      ],
                                    ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      color: Colors.grey.shade200,
                                      padding: EdgeInsets.all(10),
                                      child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        postImage = null;
                                        isSelectedFile = false;
                                        _croppedFile = null;
                                      });
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.close),
                                        Text(
                                          'Remove',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(),
                      isSelectedFile == false
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Thumbnail',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child:InkWell(
                                            onTap: () {
                                              getImage('gallery');
                                            },
                                            child: Container(
                                              height: 50,
                                              padding: EdgeInsets.symmetric(horizontal: 15),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  border: Border.all(color: Colors.black, width: 1),
                                                  color: Colors.white),
                                              child: Center(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.photo,
                                                        color: Colors.black,
                                                      ),
                                                      Text(
                                                        'Gallery',
                                                        style: TextStyle(fontSize: 18, color: Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ),
                                      SizedBox(width: 10,),
                                      Expanded(
                                          child: InkWell(
                                        onTap: () {
                                          getImage('camera');
                                        },
                                        child: Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(color: Colors.black, width: 1),
                                              color: Colors.white),
                                          child: Center(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.black,
                                                  ),
                                                  Text(
                                                    'Camera',
                                                    style: TextStyle(fontSize: 18, color: Colors.black),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 20,
                      ),
                      pdfselected == false
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Add Document',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                                Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    _pickPdfFile();
                                  },
                                  child: Container(
                                    width: 175,
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                        color: Colors.white),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 5),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.picture_as_pdf,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              'Select PDF',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Container(
                              width: 40,
                              height: 50,
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                  color: Colors.white),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.folder,
                                    color: Colors.black,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Text(
                                      pdfname!,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          pdfselected = false;
                                          pdfname = null;
                                        });
                                      },
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
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
                                                      errorBuilder:
                                                          (BuildContext context,
                                                              Object exception,
                                                              StackTrace?
                                                                  stackTrace) {
                                                        return Constants
                                                            .defaultImage(20.0);
                                                      },
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
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
                                                      errorBuilder:
                                                          (BuildContext context,
                                                              Object exception,
                                                              StackTrace?
                                                                  stackTrace) {
                                                        return Constants
                                                            .defaultImage(20.0);
                                                      },
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
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
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            Container(

              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xff212121),
              ),
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xff212121),
                    ),
                    child: (_isUploading == 0)
                        ? Text(
                            'Share Case Study',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                ),
                          )
                        : Utils.LoadingIndictorWidtet(),
                    onPressed: () async {
                      uploadFile(context);
                    },
                  ),
                  SizedBox(height: 10,)
                ],
              ),
              
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Dio dio = new Dio();
  uploadFile(context) async {
    if (_titleTxtController.text.isEmpty) {
      Utils.toastMessage('Please enter Case Study Title');
      return;
    } else if (_detailsTxtController.text.isEmpty) {
      Utils.toastMessage('Please enter Case Study Details');
      return;
    } else if (postImage == null) {
      Utils.toastMessage('Please select Case Study Thumbnail ');
      return;
    } else
      setState(() {
        _isUploading = 1;
      });
    String uploadUrl = AppUrl.storeCaseStudy;

    var formData;

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
          'title': _titleTxtController.text,
          'image': await MultipartFile.fromFile(path, filename: basename(path)),
          'pdf': postpdf == null
              ? null
              : await MultipartFile.fromFile(postpdf!.path,
                  filename: basename(postpdf!.path)),
          'body': _detailsTxtController.text,
        },
      );
    } else {
      if (postImage == null) {
        Utils.toastMessage('Please select image');
      } else if (postpdf == null) {
        Utils.toastMessage('Please select pdf');
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
      Utils.toastMessage('Your case study has been added');
      _detailsTxtController.clear();
      _titleTxtController.clear();
      setState(() {
        _detailsTxtController.clear();
        _titleTxtController.clear();
        postImage = null;
        postpdf = null;
        pdfname = null;
        pdfselected = false;
        imagePath = null;
        _croppedFile = null;
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => ShowCaseStudyScreen()));
    } else {
      print("Error during connection to server.");
    }
  }
}
