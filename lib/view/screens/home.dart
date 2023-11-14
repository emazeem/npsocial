import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:np_social/model/Ad.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/ads.dart';
import 'package:np_social/view/screens/widgets/drawer_info.dart';
import 'package:np_social/view/screens/widgets/show_post.dart';
import 'package:np_social/view_model/ads_view_model.dart';
import 'package:np_social/view_model/post_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? authToken;
  int? AuthId;
  bool showMoreBtnFlag = true;
  int showMoreCounter = 0;
  bool _showMoreBtn = true;
  bool _isLoadingMore = false;
  List post = [];
  Map data = {};
  
  List<Map<String, dynamic>> _mentionList = [];

  List<int> impressionsDetected = [];

  Future<void> _pullRefresh() async {
    setState(() {
      post = [];
      _showMoreBtn = true;
      showMoreCounter = 0;
    });
    print('data == ' + data.toString());
    List _post = await Provider.of<PostViewModel>(context, listen: false)
        .fetchTwoMorePosts(data, '${authToken}');
    post = _post;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      await Provider.of<UserViewModel>(context, listen: false) .fetchAllUsers(); 
      setState(() {
        _mentionList = Provider.of<UserViewModel>(context, listen: false)
            .getAllUsers
            .map((e) => {
              'id': '${e!.id}',
              'display': "${e.fname} ${e.lname } ",
              'full_name': "${e.fname} ${e.lname}",
              'photo':"${AppUrl.url}storage/profile/${e.email}/50x50${e.profile} }"
                })
            .toList();
      });
      print('mentionList ' + _mentionList.toString());
      data = {'id': '${AuthId}', 'number': '${showMoreCounter}'};
      _pullRefresh();
    });
  }

  showTwoMorePosts() async {
    if (_isLoadingMore == false && _showMoreBtn == true) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = true;
        showMoreCounter = showMoreCounter + 7;
      });
      List twoMorePost =
          await Provider.of<PostViewModel>(context, listen: false)
              .fetchTwoMorePosts(
                  {'id': '${AuthId}', 'number': '${showMoreCounter}'},
                  '${authToken}');
      if (twoMorePost.isEmpty) {
        setState(() {
          _showMoreBtn = false;
        });
      }
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        post.addAll(twoMorePost);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget build(BuildContext context) {
    PostViewModel postViewModel = Provider.of<PostViewModel>(context);
    Widget _child = _defaultHomePage('Fetching posts. Please wait.');

    if (postViewModel.getStatus.status == Status.IDLE) {
      if (post.length == 0) {
        _child = _defaultHomePage('Fetching posts. Please wait.');
      } else {
        _child = RefreshIndicator(
            child: SingleChildScrollView(
              physics: ScrollPhysics(),
              child: Column(
                children: <Widget>[
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: post.length,
                    itemBuilder: (context, index) {
                       GlobalKey<FlutterMentionsState> uniqueKey =GlobalKey<FlutterMentionsState>();
                     
                      
                       
                       

                      if (post[index] is Post) {
                        if (post[post.length - 1] is Post &&
                            index == post.length - 1) {
                          return VisibilityDetector(
                              key: Key(index.toString()),
                              onVisibilityChanged: (VisibilityInfo info) {
                                if (info.visibleFraction * 100 > 80) {
                                  showTwoMorePosts();
                                }
                              },
                              child: ShowPostCard(
                                  post[index], _mentionList, uniqueKey));
                        } else {
                          return ShowPostCard(
                              post[index], _mentionList, uniqueKey);
                        }
                      } else if (post[index] is Ad) {
                        return VisibilityDetector(
                            key: Key(index.toString()),
                            onVisibilityChanged: (VisibilityInfo info) {
                              if (impressionsDetected
                                      .contains(post[index].id) ==
                                  false) {}
                              print('${info.visibleFraction * 100}');
                              if (info.visibleFraction * 100 == 100) {
                                print('visibility less than 100%');
                                var data = {
                                  'user_id': '${AuthId}',
                                  'type': 'impression',
                                  'ad_id': '${post[index].id}'
                                };
                                setState(() {
                                  impressionsDetected.add(post[index].id);
                                });
                                Provider.of<AdsViewModel>(context,
                                        listen: false)
                                    .registerImpression(data);
                              }
                              if (info.visibleFraction * 100 > 80) {
                                showTwoMorePosts();
                              }
                            },
                            child: AdsCard(post[index]));
                      } else {
                        return Container();
                      }
                    },
                  ),
                  Visibility(
                    visible: _showMoreBtn,
                    child: _isLoadingMore
                        ? Utils.LoadingIndictorWidtet(size: 40.0)
                        : Container(),
                  ),
                ],
              ),
            ),
            onRefresh: () async {
              _pullRefresh();
            });
      }
    } else if (postViewModel.getStatus.status == Status.BUSY) {
      _child = _defaultHomePage('Fetching posts. Please wait.');
    }

    return Container(
      color: Constants.np_bg_clr,
      child: _child,
    );
  }

  Widget _defaultHomePage(String? text, {bool showLoader = true}) {
    return RefreshIndicator(
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height - 140,
                width: double.infinity,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text!,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      showLoader == true
                          ? Utils.LoadingIndictorWidtet(size: 40.0)
                          : Container(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        onRefresh: () async {
          _pullRefresh();
        });
  }

  Widget AdsCard(Ad ad) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AdsScreen(ad)));
      },
      child: Container(
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Container(
                          width: 40,
                          height: 40,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.network(
                                '${Constants.profileImage(ad.user)}',
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return Constants.defaultImage(40.0);
                                },
                              ))),
                      Expanded(
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.only(left: 10, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${ad.user?.fname}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${ad.createdAt!.m}-${ad.createdAt!.d}-${ad.createdAt!.Y} ${ad.createdAt!.h}:${ad.createdAt!.i} ${ad.createdAt!.A} ',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  )
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Constants.np_yellow,
                                    borderRadius: BorderRadius.circular(4)),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                child: Text(
                                  'Ad',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    '${ad.title}',
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                  ),
                  leading: Image.network(
                    '${AppUrl.url + '/' + ad.image.toString()}',
                    width: 60,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  subtitle: Text(
                    '${ad.description}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
