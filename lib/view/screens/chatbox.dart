import 'dart:async';
import 'package:flutter/material.dart';
import 'package:np_social/model/Chat.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Products.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/widgets/layout.dart';
import 'package:np_social/view/screens/widgets/product_message_card.dart';
import 'package:np_social/view_model/chat_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ChatBoxScreen extends StatefulWidget {
  final User? user;
  final bool isMarketChat;
  final ProductsModel? productsModel;
  const ChatBoxScreen(
    this.user, {
    Key? key,
    this.isMarketChat = false,
    this.productsModel,
  }) : super(key: key);

  @override
  State<ChatBoxScreen> createState() => _ChatBoxScreenState();
}

class _ChatBoxScreenState extends State<ChatBoxScreen> {
  var authToken;
  var authId;
  User? authUser;
  final _messageTxtController = TextEditingController();
  final ScrollController _sc = ScrollController();


  bool isProcessing = false;

  Future<void> _pullMessages(ctx) async {
    Map messagesParams = {
      'id': '${authId}',
      'user': '${widget.user?.id}',
      'key': widget.isMarketChat ? 'marketplace' : 'social'
    };
    Provider.of<ChatViewModel>(context, listen: false)
        .fetchAllMessages(messagesParams, '${authToken}');
  }

  @override
  void initState() {
    //key = marketplace,social
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      Map data = {'id': '${authId}'};
      Provider.of<ChatViewModel>(context, listen: false).setAllMessages([]);
      Provider.of<UserViewModel>(context, listen: false)
          .getUserDetails(data, '${authToken}');

      Map msgMarkAsReadParams = {
        'to': '${authId}',
        'from': '${widget.user?.id}',
        'key': widget.isMarketChat ? 'marketplace' : 'social'
      };
      Provider.of<UserViewModel>(context, listen: false)
          .messagesMarkAsRead(msgMarkAsReadParams, '${authToken}');
      // }
      _pullMessages(context);

    });
  }
  void _animateToIndex() {
    _sc.animateTo(
      _sc.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
  @override
  Widget build(BuildContext context) {
    ChatViewModel _chatViewModel = Provider.of<ChatViewModel>(context);
    List<Chat?> messages = _chatViewModel.getAllMessages;
    authUser = Provider.of<UserViewModel>(context).getUser;
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (messages.length > 0) {
        _animateToIndex();
        timer.cancel();
      }
    });

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
        title: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OtherProfileScreen(widget.user?.id)));
          },
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.network(
                  '${Constants.profileImage(widget.user)}',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return Constants.defaultImage(40.0);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '${widget.user?.fname} ${widget.user?.role==Role.User? widget.user?.lname : ""}',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Container(
        color: Constants.np_bg_clr,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              (widget.isMarketChat && widget.productsModel?.title != null)
                  ? Container(
                      height: 100,
                      width: double.infinity,
                      child: ProductMessageCard(
                        name: '${widget.productsModel?.title}',
                        price: '${widget.productsModel?.price}',
                        description: '${widget.productsModel?.description}',
                        imageUrl: '${widget.productsModel?.thumbNailPic}',
                      ),
                    )
                  : SizedBox(),
              Expanded(
                flex: 16,
                child: Container(
                  child: Card(
                    child: RefreshIndicator(
                        child: ListView(
                          controller: _sc,

                          children: [
                            if (_chatViewModel.getAllMessagesStatus.status ==
                                Status.IDLE) ...[
                              if (messages.length != 0) ...[
                                for (var message in messages)
                                  MessageRow(message),
                              ]
                            ] else if (_chatViewModel
                                    .getAllMessagesStatus.status ==
                                Status.BUSY) ...[
                              Center(
                                child: Container(
                                  height: 500,
                                  child:
                                      Utils.LoadingIndictorWidtet(size: 30.0),
                                ),
                              )
                            ],
                          ],
                        ),
                        onRefresh: () async {
                          _pullMessages(context);
                        }),
                  ),
                ),
              ),
              Container(
                child: Card(
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 80,
                        child: TextField(
                          controller: _messageTxtController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: InputBorder.none,
                            hintText: 'Type your message here.',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send_rounded),
                        color: (!isProcessing)
                            ? Colors.black
                            : Colors.grey.shade100,
                        tooltip: 'Send',
                        onPressed: () async {

                          if (_messageTxtController.text.isEmpty) {
                            Utils.toastMessage(
                                'Please enter a message to send.!');
                          } else {
                            if (isProcessing == false) {
                              setState(() {
                                isProcessing = true;
                              });
                              Map data = {
                                'user': '${widget.user!.id}',
                                'id': '${authUser!.id}',
                                'message': '${_messageTxtController.text}',
                                'key': widget.isMarketChat
                                    ? 'marketplace'
                                    : 'social'
                              };
                              dynamic sentMessage = await _chatViewModel
                                  .storeMessage(data, '${authToken}');

                              setState(() {
                                _messageTxtController.text = '';
                                isProcessing = false;
                                sentMessage['created_at'] = NpDateTime.fromJson(
                                    sentMessage['created_at']);
                                messages.add(Chat(
                                  id: sentMessage['id'] as int?,
                                  from:
                                      int.tryParse(sentMessage['from']) as int?,
                                  to: int.tryParse(sentMessage['to']) as int?,
                                  message: sentMessage['message'] as String?,
                                  created_at:
                                      sentMessage['created_at'] as NpDateTime?,
                                ));
                                //_pullMessages(context);
                              });
                            }
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget MessageRow(Chat? chat) {
    User? user;
    var type;
    final messageBg;

    if (chat!.from == widget.user!.id) {
      type = 'left';
      messageBg = Colors.grey[200];
      user = widget.user!;
    } else {
      type = 'right';
      messageBg = Colors.blueGrey[100];
      user = authUser;
    }

    dynamic messageContainer;
    dynamic imageCard = ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Image.network(
        '${Constants.profileImage(user)}',
        width: 30,
        height: 30,
        fit: BoxFit.cover,
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return Constants.defaultImage(40.0);
        },
      ),
    );
    dynamic messageCard = Container(
      width: MediaQuery.of(context).size.width - 100,
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: messageBg,
          ),
          padding: EdgeInsets.all(10),
          child: Text('${chat.message}'),
        ),
      ),
    );

    if (type == 'left') {
      messageContainer = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              imageCard,
              messageCard,
            ],
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Text(
                '${chat.created_at?.h}: ${chat.created_at?.i} ${chat.created_at?.A} ${chat.created_at?.m}-${chat.created_at?.d}-${chat.created_at?.Y}',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          )
        ],
      );
    }
    if (type == 'right') {
      messageContainer = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [messageCard, imageCard],
          ),
          Container(
            margin: EdgeInsets.only(left: 24),
            child: Text(
                '${chat.created_at?.h}: ${chat.created_at?.i} ${chat.created_at?.A} ${chat.created_at?.m}-${chat.created_at?.d}-${chat.created_at?.Y}',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          )
        ],
      );
    }
    return Padding(padding: EdgeInsets.all(10), child: messageContainer);
  }

  void handleClick(int item) {
    switch (item) {
      case 0:
        break;
      case 1:
        break;
    }
  }
}
