import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:np_social/model/CaseStudy.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/view/screens/create_case_study.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/profile.dart';
import 'package:np_social/view/screens/widgets/case_study_details.dart';
import 'package:np_social/view_model/case_study_view_model.dart';
import 'package:provider/provider.dart';

import '../../shared_preference/app_shared_preference.dart';
import '../../utils/Utils.dart';

class ShowCaseStudyScreen extends StatefulWidget {
  final CaseStudy? casestudy;

  ShowCaseStudyScreen({this.casestudy});

  @override
  State<ShowCaseStudyScreen> createState() => _ShowCaseStudyScreenState();
}

var timeCreated;

class _ShowCaseStudyScreenState extends State<ShowCaseStudyScreen> {
  String? authToken;
  int? AuthId;
  bool? isAuth;
  Future<void> _fetchCaseStudies() async {
    Provider.of<CaseStudyViewModel>(context, listen: false)
        .setallcaseStudies([]);
    Provider.of<CaseStudyViewModel>(context, listen: false)
        .fetchCaseStudy({}, '${authToken}');
  }

  @override
  void initState() {
    super.initState();
    timeCreated = widget.casestudy?.createdAt;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      _fetchCaseStudies();
    });
  }

  @override
  Widget build(BuildContext context) {
    CaseStudyViewModel _casestudyviewmodel =
        Provider.of<CaseStudyViewModel>(context);
    List<CaseStudy?> casestudies = _casestudyviewmodel.getallCaseStudies;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Constants.titleImage(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => CreateCaseStudyScreen()));
        },
        child: Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCaseStudies,
        child: SingleChildScrollView(
          child: Container(
            color: Constants.np_bg_clr,
            child: Padding(
                padding: EdgeInsets.all(Constants.np_padding_only),
                child: Card(
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            child: Padding(
                                padding: EdgeInsets.only(top: 10, left: 10),
                                child: Text('Case Studies',
                                    style: TextStyle(fontSize: 20)))),
                      ],
                    ),
                    Divider(),
                    if (_casestudyviewmodel.getCaseStudyStatus.status ==
                        Status.IDLE) ...[
                      if (casestudies.length == 0) ...[
                        Center(
                          child: Container(
                            width: double.infinity,
                            child: Container(
                              padding: EdgeInsets.all(10),
                              child: Text('No Case Study Found.'),
                            ),
                          ),
                        )
                      ] else ...[
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:2,
                            ),
                            itemCount: casestudies.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CaseStudyDetailsScreen(
                                                      caseStudy:
                                                          casestudies[index]!)))
                                      .then((value) => _fetchCaseStudies());
                                },
                                child:
                                    CaseStudyCard(casestudies[index]!, context),
                              );
                            },
                          ),
                        ),
                      ]
                    ] else if (_casestudyviewmodel.getCaseStudyStatus.status ==
                        Status.BUSY) ...[
                      Container(
                        height: MediaQuery.of(context).size.height - 100,
                        child: Center(
                          child: Utils.LoadingIndictorWidtet(),
                        ),
                      )
                    ],
                  ]),
                )),
          ),
        ),
      ),
      backgroundColor: Constants.np_bg_clr,
    );
  }
}

class CaseStudyCard extends StatelessWidget {
  CaseStudy casestudy;
  BuildContext context;
  CaseStudyCard(this.casestudy, this.context);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Padding(
  padding: EdgeInsets.all(w * 0.014),
  child: Container(
    child: Column(
      children: [
        (casestudy.image == null)
            ? Utils.LoadingIndictorWidtet()
            : ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
                child: AspectRatio(
                  aspectRatio: 2 / 1, // Set the desired aspect ratio
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl:
                        "${Constants.postImagecasestudy(casestudy.image)}",
                    placeholder: (context, url) =>
                        Utils.LoadingIndictorWidtet(),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/image-placeholder.png',
                    ),
                  ),
                ),
              ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
              color: Colors.grey.shade200,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      '${casestudy.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Divider(),
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              '${Constants.profileImage(casestudy.user)}',
                              fit: BoxFit.cover,
                              errorBuilder: (BuildContext context,
                                  Object exception,
                                  StackTrace? stackTrace) {
                                return Constants.defaultImage(50.0);
                              },
                            )),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: 10,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width:
                                  MediaQuery.of(context).size.width / 3.5,
                              child: Text(
                                '${casestudy.user!.fname} ${casestudy.user!.lname}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);

  }
}
