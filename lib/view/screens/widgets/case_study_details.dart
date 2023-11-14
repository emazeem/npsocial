import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:np_social/model/CaseStudy.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/show_case_study.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/webview/pdf_view.dart';
import 'package:np_social/view_model/case_study_view_model.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class CaseStudyDetailsScreen extends StatefulWidget {
  CaseStudy caseStudy;
  CaseStudyDetailsScreen({required this.caseStudy});

  @override
  State<CaseStudyDetailsScreen> createState() => _CaseStudyDetailsScreenState();
}

class _CaseStudyDetailsScreenState extends State<CaseStudyDetailsScreen> {
  String? authToken;
  int? authId;
  int currentIndex = 1;
  Map data = {};
  bool isMyCaseStudy = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void>? _launched;
  Future<void> _launchInBrowser(Uri url) async {
    if (Platform.isAndroid) {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw 'Could not launch $url';
      }
    } else {
      final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
      if (await launcher.canLaunch(url.toString())) {
        await launcher.launch(
          url.toString(),
          useSafariVC: true,
          useWebView: true,
          enableJavaScript: true,
          enableDomStorage: false,
          universalLinksOnly: false,
          headers: <String, String>{'my_header_key': 'my_header_value'},
        );
      } else {
        throw 'Could not launch $url';
      }
    }
  }

  Future<void> _deleteCaseStudy() async {
    await Provider.of<CaseStudyViewModel>(context, listen: false).deleteCaseStudy(data, authToken!);
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>ShowCaseStudyScreen(),));
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();

      authId = await AppSharedPref.getAuthId();
      data = {'id': "${widget.caseStudy.id}"};
      setState(() {
        isMyCaseStudy = (authId == widget.caseStudy.userId);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // String $CreatedAt;
    NpDateTime  CreatedAt = widget.caseStudy.createdAt!;

    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Constants.np_bg_clr,
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
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                color: Constants.np_bg_clr,
                child: Stack(
                  children: [
                    Container(
                      height:MediaQuery.of(context).size.height*0.3,
                      width:MediaQuery.of(context).size.width/1,
                      
                      child: CachedNetworkImage(
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.contain,
                        imageUrl:
                            "${Constants.postImagecasestudy(widget.caseStudy.image!)}",
                        placeholder: (context, url) =>
                            Utils.LoadingIndictorWidtet(),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/images/image-placeholder.png',
                          width: 300,
                          height: 100,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Text(
                              widget.caseStudy.title ?? '',
                              maxLines: 5,
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                        ]),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        widget.caseStudy.pdf == null
                            ? Container()
                            : TextButton(
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => PDFViewer(
                                            pdfUrl: widget.caseStudy.pdf)),
                                  );
                                },
                                child: Text('View PDF'),
                              ),
                      ],
                    ),
                    Text(
                       '${CreatedAt.m}-${CreatedAt.d}-${CreatedAt.Y} ${CreatedAt.h}:${CreatedAt.i} ${CreatedAt.A} ',
                            style: TextStyle(
                              fontSize: 12, color: Colors.grey),
                                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Text(
                              widget.caseStudy.body ?? '',
                            )),
                      ],
                    ),
                    Divider(),
                    Text(
                      'Author',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    Divider(),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => OtherProfileScreen(
                                    widget.caseStudy.user!.id)));
                      },
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.network(
                            Constants.profileImage(widget.caseStudy.user!),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                              return Constants.defaultImage(50.0);
                            },
                          ),
                        ),
                        title: Text(
                            '${widget.caseStudy.user!.fname} ${widget.caseStudy.user!.lname}'),
                      ),
                    ),
                    
                  ],
                ),
              ),
              InkWell(
                onTap: (){
                  _deleteCaseStudy();
                },
                child:isMyCaseStudy ?
                    Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Color.fromARGB(255, 255, 121, 121),),
                        child:  Text('Delete Case Study',style: TextStyle(fontWeight: FontWeight.w500,),textAlign: TextAlign.center,)
                    ):
                    Container(),
              )
            ],
          ),
        ),
      ),
    );
  }
  
}
