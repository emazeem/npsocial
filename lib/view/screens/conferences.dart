import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:np_social/model/Conferences.dart';
import 'package:np_social/model/Poll.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/roles.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/create_conferences.dart';
import 'package:np_social/view/screens/near-me.dart';
import 'package:np_social/view/screens/other_profile.dart';
import 'package:np_social/view/screens/profile.dart';
import 'package:np_social/view_model/ConferenceViewModel.dart';
import 'package:np_social/view_model/role_view_model.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:badges/badges.dart' as badges;

class ConferenceScreen extends StatefulWidget {
  const ConferenceScreen();

  @override
  State<ConferenceScreen> createState() => _ConferenceScreenState();
}

class _ConferenceScreenState extends State<ConferenceScreen> {
  List<EventCountModel> _eventCounts = [];
  final _currentDate = DateTime.now();
  String? authToken;

  final ValueNotifier<List<Event>> _selectedEvents = ValueNotifier([]);
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String? conferenceStatus = 'choose your availability';
  bool _isFetchingEvents = false;
  bool _isModalOpening = false; 
  var isMyConference;
  bool _isVoting = false;
  bool _isLoading = false;
  Map data = {};
  int? AuthId;
  Future<void> _deleteConference(id) async {
    data = {'id': id};
    await Provider.of<ConferenceViewModel>(context, listen: false)
        .deleteConference(data, authToken!);
    _fetchCounts();
    
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
    }); 
    _fetchCounts();
    super.initState();
  }

  Future<void> _fetchCounts() async { 
    setState(() {
      _isLoading = true;
    });    String date = DateFormat('yyyy-MM-${_focusedDay.day.toString().padLeft(2, '0')}') .format(_focusedDay) .toString(); 
    setState(() { 
      _eventCounts = [];
      }); 
      dynamic response = await Provider.of<ConferenceViewModel>(context, listen: false).fetchEventCount({'date': '${date}'}); 
      response['data']['eventsCountByDate'].forEach((item) {
      setState(() {
        _eventCounts.add(EventCountModel(date: item['date'], count: item['count'])); 
        print('item $item');
        });
    });
    _onDaySelected(_selectedDay, _focusedDay);
    setState(() {
      _isLoading = false;
    });
    print('event count $_eventCounts');
  }

  String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('EEEE MM d HH:mm');
    final String formatted = formatter.format(date);
    return formatted;
  }
  DateTime convertDateFromString(String toTime,String toDate) 
  {
    DateTime parsedTime = DateFormat('h:mm a').parse(toTime);
    DateTime parsedDate = DateFormat('EEE, MMM d, yyyy').parse(toDate);
    int year = parsedDate.year;
    int month = parsedDate.month;
    int day = parsedDate.day;
    int hour = parsedTime.hour;
    int minute = parsedTime.minute;
    DateTime combinedDateTime = DateTime(year, month, day, hour, minute); 
    return combinedDateTime; 
  }
 

  searchCountFromModels(day) {
    String date = DateFormat('yyyy-MM-${day.toString().padLeft(2, '0')}').format(_focusedDay).toString();
    int? count;
    _eventCounts.where((element) => element.date == date).forEach((element) { 
      count = element.count;
    });
    return count; 
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
    setState(() {
      _isFetchingEvents = true;
    });
    Map data = {'date': selectedDay.toString()};
    dynamic response =
        await Provider.of<ConferenceViewModel>(context, listen: false)
            .fetchEventsByDate(data);
    setState(() {
      _isFetchingEvents = false;
    });
    if (response == false) {
      _selectedEvents.value = [];
    } else {
      setState(() {
        _selectedEvents.value = [];
      });
      List<Event> _events = [];
      response['data']['events'].forEach((e) {
        Event _event = Event.fromJson(e); 
        _event.from_time = DateFormat('h:mm a')
            .format(DateFormat('HH:mm').parse(_event.from_time.toString()));
        _event.to_time = DateFormat('h:mm a')
            .format(DateFormat('HH:mm').parse(_event.to_time.toString()));
        _event.from_date = DateFormat('EEEE MMMM d ')
            .format(DateTime.parse(_event.from_date.toString()));
        _event.to_date = DateFormat("EEE, MMM d, yyyy")
            .format(DateTime.parse(_event.to_date.toString())); 
        _events.add(_event);
      });
      setState(() {
        _selectedEvents.value = _events;
      });
    }
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
      floatingActionButton:
          context.watch<RoleViewModel>().getAuthRole == Role.User
              ? Container()
              : FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateConferences(),
                      ),
                    ).then((value) => _fetchCounts());
                  },
                  backgroundColor: Colors.black,
                  child: Icon(Icons.add)),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? Column(
                  children: [
                    Center(
                        child:Lottie.asset('assets/loadingBar.json',
                        width: double.infinity, fit: BoxFit.fill, height: 5),
                      ),
                      SizedBox(
                        height:MediaQuery.of(context).size.height * 0.45,
                      )
                  ],
                ) 
                : TableCalendar<Event>( 
                    calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, events) => Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration( 
                      borderRadius: BorderRadius.circular(50.0), 
                      ), 
                      child: (searchCountFromModels(date.day) == 0 || 
                              searchCountFromModels(date.day) == null)
                          ? Text(
                              '${date.day}',
                            )
                          : badges.Badge(
                            badgeStyle: badges.BadgeStyle(
                              badgeColor: Colors.black,
                            ),
                          /*badgeContent: Text(
                            '${searchCountFromModels(date.day)}',
                            style: TextStyle(color: Colors.white),
                          ),*/
                            child: Text(
                              '${date.day}',
                            ),
                        ),
                ),
              ),
              firstDay: DateTime.utc(2020),
              lastDay: DateTime.utc(2024),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: _calendarFormat, 
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
              ), 
              onDaySelected: _onDaySelected,
              //onRangeSelected: _onRangeSelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) async { 
                _focusedDay = focusedDay;
                _selectedDay = focusedDay; 
                await _fetchCounts();
              },
            ),
            const SizedBox(height: 8.0),
            Container(
                margin: EdgeInsets.only(left: 10, right: 14),
                child: Text(
                  'Conferences of ${DateFormat('MM-dd-yyyy').format(_selectedDay)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
            _isModalOpening
                ? Lottie.asset('assets/loadingBar.json',
                    width: double.infinity, fit: BoxFit.fill, height: 5)
                : SizedBox(),
            !_isFetchingEvents
                ? Expanded(
                    child: ValueListenableBuilder<List<Event>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        return (value.length == 0)
                            ? Container(
                                margin: EdgeInsets.only(top: 10, left: 20),
                                child: Text(
                                  'Empty list',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : Scrollbar(
                              isAlwaysShown: true,
                              
                              child: ListView.builder(
                                  itemCount: value.length,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () async {
                                        if (_isModalOpening == false) {
                                          setState(() {
                                            _isModalOpening = true;
                                          });
                                          List<Polls> _polls = [];
                                          dynamic pollsResponse = await Provider
                                                  .of<ConferenceViewModel>(
                                                      context,
                                                      listen: false)
                                              .fetchPollsOfEvent(
                                                  {'id': '${value[index].id}'});
                                          if (pollsResponse == false) {
                                          } else {
                                            pollsResponse.forEach((poll) {
                                              _polls.add(Polls.fromJson(poll));
                                            });
                                          }
                                          eventModelBottomSheet(
                                              context, value, index, _polls);
                                          setState(() {
                                            _isModalOpening = false;
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin:  (value.length==index+1)? EdgeInsets.only(bottom: 80,top: 2,left:12,right: 12) : const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 5.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                value[index].user!.id == AuthId
                                                    ? Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProfileScreen()),
                                                      )
                                                    : Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              OtherProfileScreen(
                                                            value[index].user!.id,
                                                          ),
                                                        ),
                                                      );
                                              },
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Image.network(
                                                  '${Constants.profileImage(value[index].user)}',
                                                  width: 30,
                                                  height: 30,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (BuildContextcontext,
                                                          Object exception,
                                                          StackTrace?
                                                              stackTrace) {
                                                    return Constants.defaultImage(
                                                        30.0);
                                                  },
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(left: 10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    80,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          // width: MediaQuery.of(context).size.width/2,
                                                          child: Text(
                                                            '${value[index].user?.fname}',
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(left:8.0),
                                                        child: Image.asset(Constants.orgBadgeImage,width: 20,),
                                                      )
                            
                                                      ],
                                                    ),
                                                    Text(
                                                      '${value[index].title}',
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ), 
                                                   
                                                  ],
                                                ),
                                              ),
                                            ),
                                            value[index].userId == AuthId
                                                ? IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'Confirmation'),
                                                            content: Text(
                                                                'Are you sure you want to delete?'),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                child: Text(
                                                                  'Yes',
                                                                  style: TextStyle(
                                                                      color: Constants
                                                                          .np_yellow),
                                                                ),
                                                                onPressed: () {
                                                                  _deleteConference(
                                                                      value[index]
                                                                          .id
                                                                          .toString());
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(true);
                                                                },
                                                              ),
                                                              TextButton(
                                                                child: Text(
                                                                  'No',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(false);
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    icon: Icon(
                                                      Icons.delete_outline,
                                                    ))
                                                : SizedBox(),
                                                
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            );
                      },
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Utils.LoadingIndictorWidtet(),
                  ),
          ],
        ),
      ),
    );
  }

  Future<dynamic> eventModelBottomSheet(
      BuildContext context, List<Event> value, int index, List<Polls> polls) {
    ConferenceViewModel _conferenceViewModel = ConferenceViewModel();

    Future<void> createPoll(String option) async {
      setState(() {
        conferenceStatus = option;
      });
      Map<String, dynamic> data = {
        'event_id': '${value[index].id.toString()}',
        'status': option,
      };
      await _conferenceViewModel.storeeventCount(data);
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(10),
          topRight: const Radius.circular(10),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                ),
              ),
              height: MediaQuery.of(context).size.height - 80,
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Image.network(
                                '${Constants.profileImage(value[index].user)}',
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
                          Row(
                            children: [
                              Text(
                                '${value[index].user?.fname}',
                                style: TextStyle(fontSize: 18),
                              ),
                              Image.asset(Constants.orgBadgeImage,width: 20,) 
                            ],
                          )
                        ],
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close)),
                    ],
                  ),
                  Divider(),
                  Text(
                    '${value[index].title}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height *0.01,),
                  Container(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Text(
                        '${value[index].description}',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  Text(
                    '${value[index].from_date} to ${value[index].to_date}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${value[index].from_time} - ${value[index].to_time} ',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Guests',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.width / 3,
                    child: polls.length > 0
                        ? ListView.builder(
                            itemCount: polls.length,
                            itemBuilder: (context, _index) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 20.0,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.network(
                                        '${Constants.profileImage(polls[_index].user)}',
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.cover,
                                        errorBuilder: (BuildContext context,
                                            Object exception,
                                            StackTrace? stackTrace) {
                                          return Constants.defaultImage(20.0);
                                        },
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, bottom: 5),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            child: Text(
                                              '${polls[_index].user!.fname} ${polls[_index].user!.lname}',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                              padding: EdgeInsets.only(
                                                  left: 7,
                                                  right: 7,
                                                  top: 2,
                                                  bottom: 2),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Colors.grey.shade100),
                                              child: Center(
                                                child: Text(
                                                  '${polls[_index].status.toString().toUpperCase()}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color: polls[_index]
                                                                  .status ==
                                                              'yes'
                                                          ? Colors.green
                                                          : polls[_index]
                                                                      .status ==
                                                                  'no'
                                                              ? Colors.red
                                                              : polls[_index]
                                                                          .status ==
                                                                      'maybe'
                                                                  ? Constants
                                                                      .np_yellow
                                                                  : Colors
                                                                      .black),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Text('No Guest'),
                  ),
                  value[index].user!.id == AuthId
                      ? Container()
                      : convertDateFromString(value[index].to_time.toString(),value[index].to_date.toString()).isAfter(DateTime.now())?
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Going?',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),  _isVoting ==true? Utils.LoadingIndictorWidtet():
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                              
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      side: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    onPressed: () async {
                                      setState(() {
                                        _isVoting = true;
                                      });
                                      await createPoll('yes');
                                      polls = [];
                                      dynamic pollsResponse = await Provider.of<
                                                  ConferenceViewModel>(context,
                                              listen: false)
                                          .fetchPollsOfEvent(
                                              {'id': '${value[index].id}'});
                                      if (pollsResponse == false) {
                                      } else {
                                        pollsResponse.forEach((poll) {
                                          setState(() {
                                            polls.add(Polls.fromJson(poll));
                                          });
                                        });
                                      }
                                      setState(() {
                                        _isVoting = false;
                                      });
                                    },
                                    child: Text(
                                            'Yes',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      side: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    onPressed: () async {
                                       setState(() {
                                        _isVoting = true;
                                      });
                                      await createPoll('no');
                                      polls = [];
                                      dynamic pollsResponse = await Provider.of<
                                                  ConferenceViewModel>(context,
                                              listen: false)
                                          .fetchPollsOfEvent(
                                              {'id': '${value[index].id}'});
                                      if (pollsResponse == false) {
                                      } else {
                                        pollsResponse.forEach((poll) {
                                          setState(() {
                                            polls.add(Polls.fromJson(poll));
                                          });
                                        });
                                      }
                                       setState(() {
                                        _isVoting = false;
                                      });
                                    },
                                    child: Text(
                                      'No',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      side: BorderSide(
                                        color: Colors.black,
                                      ),
                                    ),
                                    onPressed: () async {
                                        setState(() {
                                        _isVoting = true;
                                      });
                                      await createPoll('maybe');
                                      polls = [];
                                      dynamic pollsResponse = await Provider.of<
                                                  ConferenceViewModel>(context,
                                              listen: false)
                                          .fetchPollsOfEvent(
                                              {'id': '${value[index].id}'});
                                      if (pollsResponse == false) {
                                      } else {
                                        pollsResponse.forEach((poll) {
                                          setState(() {
                                            polls.add(Polls.fromJson(poll));
                                          });
                                        });
                                      }
                                        setState(() {
                                        _isVoting = false;
                                      });
                                      print(polls.length);
                                    },
                                    child: Text(
                                      'Maybe',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ):Container(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class EventCountModel {
  String? date;
  int? count;
  EventCountModel({
    this.date,
    this.count,
  });
}
