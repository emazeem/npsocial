import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/view_model/ConferenceViewModel.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:date_time_picker/date_time_picker.dart';

import 'package:provider/provider.dart';

import '../../model/User.dart';
import '../../utils/Utils.dart';

class CreateConferences extends StatefulWidget {
  const CreateConferences({super.key});

  @override
  State<CreateConferences> createState() => _CreateConferencesState();
}

class _CreateConferencesState extends State<CreateConferences> {
  TextEditingController _detailsTxtController = TextEditingController();
  TextEditingController _titleTxtController = TextEditingController();
  String _privacy = 'public';
  bool _isLoading = false;
  DateTime? _fromdate;
  bool _fromdateselected = false;

  bool _todateselected = false;
  DateTime? _todate;
  String? _fromtime;
  String? _totime;
  bool _fromtimeselected = false;
  bool _totimeselected = false;

  @override
  Widget build(BuildContext context) {
    UserViewModel _userViewModel = Provider.of<UserViewModel>(context);
    User? authUser = _userViewModel.getUser;

    ConferenceViewModel _conferenceViewModel =
        Provider.of<ConferenceViewModel>(context);

    String? longitude = '';
    String? latitude = '';

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Text(
                              ' Create Conference',
                              style: Constants().np_heading,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextFormField(
                      controller: _titleTxtController,
                      maxLength: 60,
                      decoration: InputDecoration(
                        labelText: 'Title of Conference',
                      ),
                    )
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  height: 7 * 24.0,
                  child: TextFormField(
                    controller: _detailsTxtController,
                    maxLines: 8,
                    maxLength: 250,
                    decoration: InputDecoration(
                      hintText: 'Write Details ...',
                      ),
                    ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(Constants.np_padding),
                      child: Text(
                        'From Date',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(Constants.np_padding),
                      child: DateTimePicker(
                        type: DateTimePickerType.date,
                        dateMask: 'yyyy-MM-dd',
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        //icon: Icon(Icons.event),
                        dateLabelText: 'Date',
                        selectableDayPredicate: (date) {
                          return date.isAfter(
                              DateTime.now().subtract(Duration(days: 1)));
                        },
                        onChanged: (value) {
                          setState(() {
                            _fromdate = DateTime.parse(value);
                            _fromdateselected = true;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: _fromdateselected,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(Constants.np_padding),
                        child: Text(
                          'To Date',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(Constants.np_padding),
                        child: DateTimePicker(
                          type: DateTimePickerType.date,
                          dateMask: 'yyyy-MM-dd',
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          //icon: Icon(Icons.event),
                          dateLabelText: 'Date',
                          selectableDayPredicate: (date) {
                            return date.isAfter(
                                DateTime.now().subtract(Duration(days: 1)));
                          },
                          onChanged: (value) {
                            setState(() {
                              DateTime _todatedata = DateTime.parse(value);

                              if (_todatedata.isBefore(_fromdate!)) {

                                Utils.toastMessage(
                                    'To date should be after than from date');

                                _todateselected = false;
                              } else {
                                setState(() {
                                  _todate = DateTime.parse(value);

                                  _todateselected = true;
                                });
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _todateselected,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(Constants.np_padding),
                        child: Text(
                          'From Time',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(Constants.np_padding),
                        child: DateTimePicker(
                          type: DateTimePickerType.time,
                          //icon: Icon(Icons.event),
                          timeLabelText: "Time",
                          initialTime: TimeOfDay.now(),
                          onChanged: (value) {
                            setState(() {
                              _fromtime = value;
                              _fromtimeselected = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: _fromtimeselected,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'To Time',
                        style: TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(Constants.np_padding),
                        child: DateTimePicker(
                          type: DateTimePickerType.time,
                          //icon: Icon(Icons.event),
                          timeLabelText: "Time",
                          initialTime: TimeOfDay.now(),
                          onChanged: (value) {
                            setState(() {
                              _totime = value;
                              _totimeselected = true;
                            });
                          },
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
                      child: TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white),
                        child: _isLoading == true
                            ? Utils.LoadingIndictorWidtet()
                            : Text('Create Conference'),
                        onPressed: () async {
                          if (_isLoading == false) {
                            if (_titleTxtController.text.isEmpty) {
                              Utils.toastMessage(
                                  'Please enter Conference Title');
                              return;
                            }
                            if (_detailsTxtController.text.isEmpty) {
                              Utils.toastMessage(
                                  'Please enter Conference Details');
                              return;
                            }
                            if (_fromdate == null) {
                              Utils.toastMessage('Please select from date');
                              return;
                            }
                            if (_todate == null) {
                              Utils.toastMessage('Please select to date');
                              return;
                            }
                            if (_fromtime == null) {
                              Utils.toastMessage('Please select from time');
                              return;
                            }
                            if (_totime == null) {
                              Utils.toastMessage('Please select to time');
                            }

                            String fromdateString =
                                '${_fromdate!.year}-${_fromdate!.month}-${_fromdate!.day}'; // format date as string
                            DateTime _from = DateFormat('yyyy-M-dd HH:mm:ss').parse(
                                '${fromdateString} ${_fromtime.toString()}:00');

                            String todateString =
                                '${_todate!.year}-${_todate!.month}-${_todate!.day}';

                            DateTime _to = DateFormat('yyyy-M-dd HH:mm:ss').parse('${todateString} ${_totime.toString()}:00');
                            Duration difference = _to.difference(_from);
                            print('The difference between $_to and $_from is ${difference.inDays} days.');
                            if (difference.inDays > 30) {
                              Utils.toastMessage(
                                  'Conference duration should be less than 30 days');
                              return;
                              
                            }
                            if (_from.isAfter(_to)) {
                              Utils.toastMessage(
                                  'From date/Time should be before To date');
                              return;
                            }
                            setState(() {
                              _isLoading = true;
                            });
                            Map _data = {
                              'title': '${_titleTxtController.text}',
                              'description': '${_detailsTxtController.text}',
                              'from': '${_from}',
                              'to': '$_to',
                              'location': 'Lahore',
                              'longitude': longitude,
                              'latitude': latitude,
                            };

                            dynamic response = await _conferenceViewModel.createConference(_data);
                            if (response == false) {
                              Utils.toastMessage('Something went wrong!');
                              setState(() {
                                _isLoading = false;
                              });
                            } else {

                              Utils.toastMessage(response['message']);
                              Navigator.pop(context);
                            }
                          } else {
                            //show toast only once
                            Utils.toastMessage('Please wait...');
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
}
