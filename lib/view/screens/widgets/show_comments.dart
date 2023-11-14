import 'package:comment_tree/widgets/comment_tree_widget.dart';
import 'package:comment_tree/widgets/tree_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:lottie/lottie.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/profile.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view_model/comment_view_model.dart';
import 'package:np_social/view_model/groups_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:np_social/model/Comment.dart';
import 'package:flutter/gestures.dart';
import '../../../res/app_url.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

class ShowCommentCard extends StatefulWidget {
  final Post? post;
  final bool fromGroup;
  ShowCommentCard(this.post, {this.fromGroup = false});

  @override
  State<ShowCommentCard> createState() => _ShowCommentCardState();
}

class _ShowCommentCardState extends State<ShowCommentCard> {
  List<Comment> comment = [];
  List<Comment> commentmodified = [];
  final RichTextController _commentTxtController = RichTextController(
    patternMatchMap: {},
    onMatch: (match) {},
  );
  final GlobalKey<FlutterMentionsState> uniqueKey =
      GlobalKey<FlutterMentionsState>();
  String? authToken;
  int? AuthId;
  FocusNode _focusNode = FocusNode();
  bool isAutofocusEnabled = false;
  bool commentHelper = true;
  CommentViewModel commentViewModel = CommentViewModel();
  bool colorHelper = false;
  List<Comment> replies = [];
  int? replyid;
  int editId = 0;
  String replyingTo = '';
  bool isProcessing = false;
  bool _isLoadingReplies = false;
  var listOfTaggedUsers = [];
  List<String> mentionedUsers = [];
  List<Map<String, dynamic>> _mentionList = [];
  List<Map<String, dynamic>> _mentionlistGroup = [];
  bool _isLoading = false;
  int? replyParent;
  void setMode(value) {
    setState(() {
      mode = value;
    });
  }

  handleMentionUser(data) {
    // print('handleMentionUser $data');
    String adduser = '@${data['id']}' + '#' + data['full_name'] + '#';
    mentionedUsers.add(adduser);
    // print('mentionedUsers added $mentionedUsers');
  }

  String replaceUsernames(String inputString) {
    var usersList =
        Provider.of<UserViewModel>(context, listen: false).getAllUsers;
    for (User? user in usersList) {
      inputString = inputString.replaceAll('@${user!.fname} ${user.lname}',
          '@${user.id}#${user!.fname} ${user.lname}#');
    }
    return inputString;
  }

  // mode values : add (for comment), edit (for comment) , reply (for reply) edit_reply (for reply)
  String mode = 'add';

  Future<void> _pullComments() async {
    setState(() {
      _isLoading = true;
    });
    Provider.of<CommentViewModel>(context, listen: false).setAllComments([]);
    Provider.of<CommentViewModel>(context, listen: false)
        .fetchAllComments({'id': '${widget.post?.id}'}, '${authToken}');
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pullReplies(id, index) async {
    setState(() {
      _isLoadingReplies = true;
    });
    dynamic response =
        await Provider.of<CommentViewModel>(context, listen: false)
            .fetchCommentReply({'id': '${id}'}, '${authToken}', index);
    replies = [];
    response['data'].forEach((item) {
      item['created_at'] = NpDateTime.fromJson(item['created_at']);
      item['updated_at'] = NpDateTime.fromJson(item['updated_at']);
      item['user'] = User.fromJson(item['user']);
      Comment reply = Comment.fromJson(item);
      replies.add(reply);
    });
    setState(() {
      _isLoadingReplies = false;
    });
  }

  Future<void> _deleteComment(id) async {
    Provider.of<CommentViewModel>(context, listen: false)
        .deleteComment({'id': '${id}'}, '${authToken}');
  }

  bool isMyPost = false;
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _isLoading = true;
    });
    Provider.of<CommentViewModel>(context, listen: false).setAllComments([]);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      isMyPost = widget.post!.user!.id == AuthId ? true : false;
      commentViewModel = Provider.of<CommentViewModel>(context, listen: false);
      _pullComments();
      Provider.of<UserViewModel>(context, listen: false)
          .getUserDetails({'id': '${AuthId}'}, '${authToken}');
      await Provider.of<UserViewModel>(context, listen: false).fetchAllUsers();

      setState(() {
        _mentionlistGroup = Provider.of<GroupsViewModel>(context, listen: false)
            .getGroupTaggingUsers
            .map((e) => {
                  'id': '${e!.id}',
                  'display': "${e!.fname} ${e!.lname}",
                  'full_name': "${e!.fname} ${e!.lname}",
                  'photo':
                      "${AppUrl.url}storage/profile/${e.email}/50x50${e.profile} }"
                })
            .toList();
        _mentionList = Provider.of<UserViewModel>(context, listen: false)
            .getAllUsers
            .map((e) => {
                  'id': '${e!.id}',
                  'display': "${e!.fname} ${e!.lname}",
                  'full_name': "${e!.fname} ${e!.lname}",
                  'photo':
                      "${AppUrl.url}storage/profile/${e.email}/50x50${e.profile} }"
                })
            .toList();
      });
      Provider.of<CommentViewModel>(context, listen: false).setReplyingoff();
    });
    setState(() {
      _isLoading = false;
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    mentionedUsers.clear();
    _commentTxtController.dispose();
    commentViewModel.disposeData();
    Provider.of<CommentViewModel>(context, listen: false).setAllComments([]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Comment?> comments = context.watch<CommentViewModel>().getAllComments;
    User? authUser = Provider.of<UserViewModel>(context).getUser;
    CommentViewModel _commentViewModal = Provider.of<CommentViewModel>(context);
    ScrollController _scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
        title: Image.asset(
          'assets/images/logo.png',
          width: 50,
          height: 50,
        ),
      ),
      body: _isLoading == true
          ? Center(
              child: Utils.LoadingIndictorWidtet(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _isLoadingReplies
                    ? Container(
                        margin: EdgeInsets.only(bottom: 0),
                        child: Lottie.asset('assets/loadingBar.json',
                            width: double.infinity,
                            fit: BoxFit.fill,
                            height: 5),
                      )
                    : SizedBox(
                        height: 5,
                      ),
                Container(
                  color: Colors.grey[200],
                  margin: EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, top: 10, bottom: 10),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
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
                              Expanded(
                                  child: SizedBox(
                                height: 40,
                                child: FlutterMentions(
                                  
                                  onMentionAdd: (data) {
                                    handleMentionUser(data);
                                    _scrollController.animateTo(
                                      _commentTxtController.text.length
                                              .toDouble() *
                                          10,
                                      duration: Duration(milliseconds: 50),
                                      curve: Curves.easeIn,
                                    );
                                  },
                                  focusNode: _focusNode,
                                  suggestionPosition: SuggestionPosition.Bottom,
                                  showCursor: true,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25)),
                                      borderSide:
                                          BorderSide(color: Colors.black),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25)),
                                      borderSide: BorderSide(
                                        width: 1,
                                        color: colorHelper == false
                                            ? Color.fromARGB(255, 132, 132, 132)
                                            : Colors.red,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(25)),
                                    ),
                                    hintText: 'Write something ...',
                                    suffixIcon: (isProcessing == false)
                                        ? IconButton(
                                            icon: Icon(Icons.send_rounded),
                                            color: Colors.grey,
                                            tooltip: 'Add Comment',
                                            onPressed: () async {
                                              if (_commentTxtController
                                                  .text.isEmpty) {
                                                setState(() {
                                                  colorHelper = true;
                                                });
                                                Utils.toastMessage(
                                                    'Write something to comment');
                                              } else {
                                                setState(() {
                                                  colorHelper = false;
                                                });
                                                if (mode == 'add') {
                                                  String formattedtext =
                                                      replaceUsernames(
                                                          _commentTxtController
                                                              .text);
                                                  //print ('formattedtext' + formattedtext);
                                                  //TODO: validation for empty field
                                                  Map commentStoreData = {
                                                    'comment': formattedtext,
                                                    'post_id':
                                                        '${widget.post?.id}',
                                                    'user_id': '${AuthId}',
                                                  };
                                                  setState(() {
                                                    isProcessing = true;
                                                  });
                                                  await _commentViewModal
                                                      .storeComments(
                                                          commentStoreData,
                                                          '${authToken}');
                                                  setState(() {
                                                    isProcessing = false;
                                                  });
                                                  uniqueKey
                                                      .currentState!.controller!
                                                      .clear();
                                                  mentionedUsers.clear();
                                                  await _pullComments();

                                                  Utils.toastMessage(
                                                      'Your comment has been added');
                                                }
                                                if (mode == 'reply') {
                                                  //TODO: validation for empty field
                                                  String formattedtextreply =
                                                      replaceUsernames(
                                                          _commentTxtController
                                                              .text);
                                                  //print ('formattedtext' + formattedtextreply);
                                                  Map commentStoreData = {
                                                    'comment':
                                                        formattedtextreply,
                                                    'post_id':
                                                        '${widget.post?.id}',
                                                    'user_id': '${AuthId}',
                                                    'parent_id':
                                                        '${replyParent}',
                                                  };
                                                  setState(() {
                                                    isProcessing = true;
                                                    _isLoadingReplies = true;
                                                  });
                                                  await _commentViewModal
                                                      .storeComments(
                                                          commentStoreData,
                                                          '${authToken}');
                                                  setState(() {
                                                    isProcessing = false;
                                                    _isLoadingReplies = false;
                                                  });
                                                  await _pullComments();

                                                  uniqueKey
                                                      .currentState!.controller!
                                                      .clear();
                                                  mentionedUsers.clear();
                                                  setMode('add');
                                                  Utils.toastMessage(
                                                      'Reply has been added');
                                                }
                                                if (mode == 'edit_reply') {
                                                  //TODO: validation for empty field
                                                  String
                                                      formattedTextEditReply =
                                                      replaceUsernames(
                                                          _commentTxtController
                                                              .text);
                                                  print('formattedtext' +
                                                      formattedTextEditReply);
                                                  Map editreplyData = {
                                                    'comment':
                                                        formattedTextEditReply,
                                                    'id': '${replyid}',
                                                  };
                                                  setState(() {
                                                    isProcessing = true;
                                                  });
                                                  await _commentViewModal
                                                      .editComment(
                                                          editreplyData,
                                                          '${authToken}');
                                                  setState(() {
                                                    isProcessing = false;
                                                  });
                                                  setMode('add');
                                                  uniqueKey
                                                      .currentState!.controller!
                                                      .clear();
                                                  _pullComments();
                                                  Utils.toastMessage(
                                                      'Your reply has been updated');
                                                }
                                                if (mode == 'edit') {
                                                  //TODO: validation for empty field
                                                  String formattedTextEdit =
                                                      replaceUsernames(
                                                          _commentTxtController
                                                              .text);
                                                  print('formattedtext' +
                                                      formattedTextEdit);
                                                  Map commentEditData = {
                                                    'comment':
                                                        formattedTextEdit,
                                                    'id': '${editId}',
                                                  };
                                                  setState(() {
                                                    isProcessing = true;
                                                  });
                                                  await _commentViewModal
                                                      .editComment(
                                                          commentEditData,
                                                          '${authToken}');
                                                  setState(() {
                                                    isProcessing = false;
                                                  });
                                                  setMode('add');
                                                  uniqueKey
                                                      .currentState!.controller!
                                                      .clear();
                                                  mentionedUsers.clear();
                                                  _pullComments();
                                                  Utils.toastMessage(
                                                      'Your comment has been updated');
                                                }
                                              }
                                            },
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(right: 10),
                                                child: Utils
                                                    .LoadingIndictorWidtet(),
                                              )
                                            ],
                                          ),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                  ),
                                  key: uniqueKey,
                                  scrollController: _scrollController,
                                  suggestionListDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  mentions: [
                                    Mention(
                                      trigger: '@',
                                      data: widget.fromGroup == true
                                          ? _mentionlistGroup
                                          : _mentionList,
                                      matchAll: false,
                                      suggestionBuilder: (data) {
                                        return SizedBox(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 10),
                                            width: 50,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors
                                                          .grey.shade300)),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 10,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: Image.network(
                                                      data['photo'],
                                                      width: 30,
                                                      height: 30,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (BuildContext context,
                                                              Object exception,
                                                              StackTrace?
                                                                  stackTrace) {
                                                        return Constants
                                                            .defaultImage(30.0);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      data['full_name'],
                                                      style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextStyle(
                                        color: Constants.np_yellow,
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    _scrollController.animateTo(
                                      _commentTxtController.text.length
                                              .toDouble() *
                                          10,
                                      duration: Duration(milliseconds: 50),
                                      curve: Curves.easeIn,
                                    );

                                    if (value.isEmpty) {
                                      mentionedUsers.clear();
                                    }
                                    _commentTxtController.text = value;
                                  },
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                      (mode == 'edit')
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setMode('add');
                                    uniqueKey.currentState!.controller!.clear();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 25, bottom: 5, top: 0),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      (mode == 'edit_reply')
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setMode('add');
                                    uniqueKey.currentState!.controller!.clear();
                                    setState(() {
                                      _focusNode.requestFocus();
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 25, bottom: 5, top: 0),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      (mode == 'reply')
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setMode('add');
                                    uniqueKey.currentState!.controller!.clear();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        right: 20, bottom: 5, top: 0),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${replyingTo}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setMode('add');
                                            setState(() {
                                              _focusNode.requestFocus();
                                            });
                                          },
                                          child: Text(
                                            '  Cancel',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
                if (commentViewModel.fetchAllCommentStatus.status == Status.IDLE) ...[
                  if (comments.length == 0) ...[
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(Constants.np_padding),
                        child:
                            Text('No comments yet. Be the first to comment!'),
                      ),
                    )
                  ] else ...[
                    Expanded(
                      child: ListView.builder(
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            //print('comment: ${comments[index]!.text}');
                            RichText commenttext =
                                buildRichTextWithClickableUsernames(
                                    comments[index]!.text!,
                                    context,
                                    comments[index]!.id!);
                            //print ('commenttext: $commenttext');
                            return commentWidget(comments[index], index, true,
                                commentViewModel, commenttext,_scrollController);
                          }),
                    ),
                  ]
                ] else if (commentViewModel.fetchAllCommentStatus.status ==
                    Status.BUSY) ...[
                  Center(
                    child: Utils.LoadingIndictorWidtet(),
                  )
                ],
              ],
            ),
    );
  }

  List<Map<String, List<int>>> getNonTaggedStrings(
      String inputString, List<Map<String, List<int>>> taggeduser) {
    List<Map<String, List<int>>> nonTaggedStrings = [];
    int currentIndex = 0;

    for (var user in taggeduser) {
      int startIndex = user.values.first[0];
      int endIndex = user.values.first[1];

      if (currentIndex < startIndex) {
        nonTaggedStrings.add({
          inputString.substring(currentIndex, startIndex): [
            currentIndex,
            startIndex
          ]
        });
      }

      currentIndex = endIndex;
    }

    if (currentIndex < inputString.length) {
      nonTaggedStrings.add({
        inputString.substring(currentIndex, inputString.length): [
          currentIndex,
          inputString.length
        ]
      });
    }

    return nonTaggedStrings;
  }

 void jointaggedandnontagged(List<TextSpan> textSpans, String inputString, List<Map<String, List<int>>> taggeduser, List<Map<String, List<int>>> stext) {
  // Combine tagged and non-tagged lists
  List<Map<String, List<int>>> combinedList = []..addAll(taggeduser)..addAll(stext);
  print ('combinedListfunction : $combinedList');

  // Sort the combined list by start index
  combinedList.sort((a, b) => a.values.first[0].compareTo(b.values.first[0]));

  for (var item in combinedList) {
    String text = item.keys.first;
    int startIndex = item.values.first[0];
    int endIndex = item.values.first[1];

    // Check if the item is tagged or non-tagged
    bool isTagged = taggeduser.any((user) => user.keys.first == text);

    if (isTagged) {
      // Add a clickable TextSpan for tagged user
        int profile = item.values.first[2];
      textSpans.add(TextSpan(
        text: text,
        style: TextStyle(color: Constants.np_yellow, fontWeight: FontWeight.bold),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
           Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OtherProfileScreen(profile)),
              ).then((value) => {initState()});
          },
      ));
    } else {
      // Add a normal TextSpan for non-tagged text
      textSpans.add(TextSpan(text: text));
    }

  }
  print ('textSpansfunction : $textSpans');
}


  RichText buildRichTextWithClickableUsernames(
      String inputString, BuildContext context, int commentId) {
    print('Comment Id =======> $commentId  <==========');
    print('Comment Text =======> $inputString  <==========');

    List<User?> usersList =
        Provider.of<UserViewModel>(context, listen: false).getAllUsers;
    List<TextSpan> textSpans = [];
    List<int> startIndices = [];
    List<int> endIndices = [];
    List<Map<String, List<int>>> taggeduser = [];

    if (inputString.isEmpty || inputString == null ) {
      return RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: textSpans,
        ),
      );
    }
     if (usersList == null || usersList.isEmpty) {
    return RichText(
      text: TextSpan(
        text: 'Loading Comment...',
        style: DefaultTextStyle.of(context).style,
      ),
    );
  }
    for (User? user in usersList) {
      String username = '@${user!.id}#${user.fname} ${user.lname}#';
      String userid = '@${user.id}#';
      // print('usernamefinding: $username');
      int currentIndex = 0;

      while (currentIndex <= inputString.length) {
        if (currentIndex + username.length > inputString.length) {
          //  print(
          //    'current index is $currentIndex and username length is ${username.length} and inputString length is ${inputString.length}');
          //  print('username $username not found in $inputString ');
          break;
        } else {
          if (inputString.substring(
                  currentIndex, currentIndex + username.length) ==
              username) {
            print('usf $username found in comment $commentId');
            taggeduser.add({
              '${user.fname} ${user.lname}': [
                currentIndex,
                currentIndex + username.length,
                user.id!
              ]
            });
            int startIndex = currentIndex;
            startIndices.add(startIndex);
            int endIndex = currentIndex + username.length;
            endIndices.add(endIndex);
            //  print(
            //     'startIndex: $startIndex of comment $commentId and found username $username ');
            //  print(
            //       'endIndex: $endIndex of comment $commentId and found username $username ');

            currentIndex += username.length;
          } else {
            currentIndex += 1;
            continue;
          }
        }
      }

      continue;
    }
    //now map non tagged indices

    print('taggeduser: $taggeduser');
    taggeduser.sort((a, b) =>
        (a.values.first[0] as int).compareTo(b.values.first[0] as int));

    print('after sorting taggeduser: $taggeduser');
    List<Map<String, List<int>>> stext = getNonTaggedStrings(
      inputString,
      taggeduser,
    );
   
    jointaggedandnontagged(textSpans, inputString, taggeduser, stext);

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: textSpans,
      ),
    );
  }

  String convertforEditing(String input) {
    List<User?> usersList =
        Provider.of<UserViewModel>(context, listen: false).getAllUsers;

    for (var user in usersList) {
      String username = '@${user!.id}#${user.fname} ${user.lname}#';

      if (input.contains(username)) {
        input = input.replaceAll(username, '@${user.fname} ${user.lname}');
      }
    }
    return input;
  }

  Widget commentWidget(Comment? comment, index, isComment,
      CommentViewModel _commentViewModal, RichText commenttext,ScrollController scrollController) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: CommentTreeWidget<Comment, Comment>(comment!, comment.replies,
          treeThemeData: TreeThemeData(lineColor: Colors.grey, lineWidth: 2),
          isReplyOn: !comment.replies.isEmpty,
          avatarRoot: (context, data) => PreferredSize(
                child: ClipOval(
                  child: SizedBox.fromSize(
                    size: Size.fromRadius(22),
                    child: InkWell(
                      onTap: () {
                        context.read<UserViewModel>().userResponse?.id ==
                                comment.user?.id
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen()))
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OtherProfileScreen(comment.user!.id!)));
                      },
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/image-placeholder.png',
                        image: '${Constants.profileImage(comment.user)}',
                        fit: BoxFit.cover,
                        height: 50.0,
                        width: 50.0,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Constants.defaultImage(50.0);
                        },
                      ),
                    ),
                  ),
                ),
                preferredSize: Size.fromRadius(20),
              ),
          avatarChild: (context, data) => PreferredSize(
                child: ClipOval(
                  child: SizedBox.fromSize(
                    size: Size.fromRadius(22),
                    child: InkWell(
                      onTap: () {
                        context.read<UserViewModel>().userResponse?.id ==
                                data.user?.id
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileScreen()))
                            : Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OtherProfileScreen(data.user?.id)));
                      },
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/image-placeholder.png',
                        image: '${Constants.profileImage(data.user)}',
                        fit: BoxFit.cover,
                        height: 50.0,
                        width: 50.0,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Constants.defaultImage(50.0);
                        },
                      ),
                    ),
                  ),
                ),
                preferredSize: Size.fromRadius(20),
              ),
          contentChild: (context, data) {
            //print ('commenttextreply: ${data.text}');
            RichText contentchildtext = buildRichTextWithClickableUsernames(
                data.text!, context, data.id!);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () => {
                                      AuthId == data.user?.id
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NPLayout(
                                                        currentIndex: 4,
                                                      )))
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OtherProfileScreen(
                                                          data.user?.id)))
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          '${data.user?.fname}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        data.user?.role == Role.User
                                            ? Text(
                                                ' ${data.user?.lname}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${data.updated_at?.h}:${data.updated_at?.i}${data.updated_at?.a}',
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                      Text(
                                          '${data.updated_at?.m}-${data.updated_at?.d}-${data.updated_at?.Y}',
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.grey))
                                    ],
                                  )
                                ],
                              ),
                              contentchildtext,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.grey[700], fontWeight: FontWeight.bold),
                  child: Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 8,
                        ),
                        data.user!.id == AuthId
                            ? InkWell(
                                onTap: () async {
                                  var editdata = convertforEditing(data.text!);
                                  setState(() {
                                    uniqueKey.currentState!.controller!.text =
                                        editdata;
                                  });
                                _focusNode.requestFocus();
                                uniqueKey.currentState!.controller!.selection = TextSelection.fromPosition(TextPosition(offset: _commentTxtController.text.length));
                                scrollController.animateTo(_commentTxtController.text.length.toDouble()*10,duration: Duration(milliseconds: 50),curve: Curves.easeIn);
                                  setMode('edit_reply');
                                  setReplyId(data.id);
                                },
                                child: Text(
                                  'Edit',
                                  style: TextStyle(color: Colors.grey),
                                ))
                            : SizedBox(),
                        SizedBox(
                          width: 24,
                        ),
                        (isMyPost == true ||
                                (isMyPost == false && data.user!.id == AuthId))
                            ? InkWell(
                                onTap: () async {
                                  await _deleteComment(data.id);
                                  await _pullComments();
                                },
                                child: Text('Delete',
                                    style: TextStyle(color: Colors.grey)),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
          contentRoot: (context, data) {
            return Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                    onTap: () => {
                                      AuthId == comment.user?.id
                                          ? Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      NPLayout(
                                                        currentIndex: 4,
                                                      )))
                                          : Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OtherProfileScreen(
                                                          comment.user?.id)))
                                    },
                                    child: Text(
                                      '${comment.user!.fname} ${comment.user!.role == Role.User ? comment.user!.lname : ''}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${comment.updated_at?.h}:${comment.updated_at?.i}${comment.updated_at?.a}',
                                        style: TextStyle(
                                            fontSize: 10, color: Colors.grey),
                                      ),
                                      Text(
                                          '${comment.updated_at?.m}-${comment.updated_at?.d}-${comment.updated_at?.Y}',
                                          style: TextStyle(
                                              fontSize: 10, color: Colors.grey))
                                    ],
                                  )
                                ],
                              ),
                              commenttext,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                              onTap: () async {
                                setState(() {
                                  _isLoadingReplies = true;
                                });
                                await _pullReplies(comment.id, index);
                                setState(() {
                                  comment.replies = replies;
                                });
                                setMode('reply');
                                replyingTo =
                                    'Replying to ${comment.user!.fname} ${comment.user!.role == Role.User ? comment.user!.lname : ''}';
                                uniqueKey.currentState!.controller!.clear();
                                setState(() {
                                  replyParent = comment.id;
                                  _focusNode.requestFocus();
                                  _isLoadingReplies = false;
                                });
                              },
                              child: Text('Reply',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13))),
                          comment.user!.id == AuthId
                              ? SizedBox(
                                  width: 10,
                                )
                              : Container(),
                          comment.user!.id == AuthId
                              ? InkWell(
                                  onTap: () async {
                                    var editdata =
                                        convertforEditing(comment.text!);
                                    uniqueKey.currentState!.controller!.text =
                                        '${editdata}';
                                         _focusNode.requestFocus();
                                          uniqueKey.currentState!.controller!.selection = TextSelection.fromPosition(TextPosition(offset: _commentTxtController.text.length));
                                
                                   scrollController.animateTo(
                                     editdata.length.toDouble()
                                               *
                                          10,
                                      duration: Duration(milliseconds: 50),
                                      curve: Curves.easeIn,
                                    );
                                    setMode('edit');
                                    editId = int.parse('${comment.id}');
                                  },
                                  child: Text('Edit',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)))
                              : SizedBox(),
                          (isMyPost == true ||
                                  (isMyPost == false &&
                                      comment.user!.id == AuthId))
                              ? SizedBox(
                                  width: 10,
                                )
                              : Container(),
                          (isMyPost == true ||
                                  (isMyPost == false &&
                                      comment.user!.id == AuthId))
                              ? InkWell(
                                  onTap: () async {
                                    await _deleteComment(comment.id);
                                    await _pullComments();
                                  },
                                  child: Text('Delete',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)))
                              : Container(),
                        ],
                      ),
                      (comment.replies_count! > 0)
                          ? Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: InkWell(
                                  onTap: () async {
                                    setState(() {
                                      comment.replies = [];
                                      _isLoadingReplies = true;
                                    });
                                    await _pullReplies(comment.id, index);
                                    setState(() {
                                      comment.replies = replies;
                                      _isLoadingReplies = false;
                                    });
                                  },
                                  child: Text(
                                      'View ${comment.replies_count} ${comment.replies_count == 1 ? 'Reply' : 'Replies'}',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13))),
                            )
                          : Container(),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }

  Widget? showAlertDialog(BuildContext context, Comment data) {
    // set up the button
    Widget yesButton = InkWell(
      child: Container(
        width: 70,
        height: 20,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            "Yes",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
      onTap: () {
        Map commentData = {
          'id': '${data.id.toString()}',
        };
        Navigator.of(context).pop();
        context
            .read<CommentViewModel>()
            .deleteComment(commentData, authToken!)
            .then((value) {
          Utils.toastMessage(value['message']);
          _pullComments();
        });
      },
    );
    Widget noButton = InkWell(
      child: Container(
        width: 70,
        height: 20,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Text(
            "No",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(
        "Are you sure you want to delete comment ?",
        style: TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      title: Icon(
        Icons.comments_disabled_rounded,
        color: Colors.red,
        size: 60,
      ),
      actions: [
        noButton,
        yesButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void setReplyId(int? id) {
    setState(() {
      replyid = id;
    });
  }
}
