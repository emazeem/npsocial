import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indexed/indexed.dart';
import 'package:intl/intl.dart';
import 'package:np_social/model/AuthToken.dart';
import 'package:np_social/model/license.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view_model/comment_view_model.dart';
import 'package:np_social/view_model/license_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({Key? key}) : super(key: key);

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String? authToken;
  int? AuthId;
  bool _isCardOpen = false;
  License? license;
  var myFormat = DateFormat('yyyy-MM-dd');
  LicenseViewModel licenseViewModel = LicenseViewModel();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      selectableDayPredicate: (DateTime date) {
        return date.isAfter(DateTime.now().subtract(Duration(days: 1)));
      },
    );

    setState(() {
      if (picked != null) {
        _dateController.text = myFormat.format(picked);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      licenseViewModel = Provider.of<LicenseViewModel>(context, listen: false);
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      License _license = License(auth_id: AuthId);
      licenseViewModel.fetchLicense(_license, authToken!);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _dateController.dispose();
    licenseViewModel.disposeData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.np_bg_clr,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Constants.titleImage(),
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_outlined),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Consumer<LicenseViewModel>(
                builder: (context, provider, child) {
                  final isEditing = licenseViewModel.isUpdating;
                  final licenseData = licenseViewModel.updateResponse;
                  if (isEditing) {
                    _titleController.text = licenseData!.title ?? "";
                    _numberController.text = licenseData.number ?? "";
                    _dateController.text = licenseData.expiry_date ?? "";
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => licenseViewModel.isAddOpen(),
                        child: Row(
                          children: [
                            Text(
                              isEditing ? 'Update License' : 'Add License',
                              style: TextStyle(fontSize: 20),
                            ),
                            Spacer(),
                            IconButton(
                                onPressed: () {
                                  licenseViewModel.isAddOpen();
                                  setState(() {
                                    _isCardOpen = !_isCardOpen;
                                  });
                                },
                                icon: Icon(licenseViewModel.isOpen
                                    ? Icons.remove
                                    : Icons.add)),
                          ],
                        ),
                      ),
                      Divider(),
                      Consumer<LicenseViewModel>(
                        builder: (context, provider, child) {
                          final isOpen = licenseViewModel.isOpen;

                          return Visibility(
                            visible: isOpen,
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(Constants.np_padding),
                                  child: TextFormField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'[a-zA-Z0-9 ]')),
                                    ],
                                    controller: _titleController,
                                    keyboardType: TextInputType.text,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'License Title',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(Constants.np_padding),
                                  child: TextFormField(
                                    enableInteractiveSelection: true,
                                    controller: _numberController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'License Number',
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(Constants.np_padding),
                                  child: InkWell(
                                    onTap: () => _selectDate(context),
                                    child: IgnorePointer(
                                      child: TextField(
                                        controller: _dateController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Expiration Date',
                                          suffixIcon:
                                              Icon(Icons.date_range_sharp),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    isEditing
                                        ? ElevatedButton(
                                            onPressed: () {
                                              _titleController.text = "";
                                              _numberController.text = "";
                                              _dateController.text = "";
                                              context
                                                  .read<LicenseViewModel>()
                                                  .setEditValue(null);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey,
                                            ),
                                            child: Text('Cancel'),
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Consumer<LicenseViewModel>(
                                      builder: (context, provider, child) {
                                        final isLoading = context
                                            .watch<LicenseViewModel>()
                                            .isLicenseLoading;
                                        return Align(
                                          alignment: Alignment.centerRight,
                                          child: SizedBox(
                                            width: 150,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                              ),
                                              child: isLoading
                                                  ? Utils
                                                      .LoadingIndictorWidtet()
                                                  : Text(isEditing
                                                      ? 'Update License'
                                                      : 'Add License'),
                                              onPressed: () {
                                                if (_titleController
                                                    .text.isEmpty) {
                                                  Utils.toastMessage(
                                                      'Please enter license title');
                                                } else if (_numberController
                                                    .text.isEmpty) {
                                                  Utils.toastMessage(
                                                      'Please enter license number');
                                                } else if (_dateController
                                                    .text.isEmpty) {
                                                  Utils.toastMessage(
                                                      'Please select expiry date');
                                                } else {
                                                  Utils.hideKeyboard();
                                                  license = License(
                                                    id: isEditing
                                                        ? licenseData!.id
                                                        : null,
                                                    auth_id: AuthId,
                                                    title:
                                                        _titleController.text,
                                                    number:
                                                        _numberController.text,
                                                    expiry_date:
                                                        _dateController.text,
                                                  );
                                                  if (isEditing) {
                                                    context
                                                        .read<
                                                            LicenseViewModel>()
                                                        .updateLicense(license!,
                                                            authToken!)
                                                        .then((value) {
                                                      _titleController.text =
                                                          '';
                                                      _numberController.text =
                                                          '';
                                                      _dateController.text = '';
                                                      context
                                                          .read<
                                                              LicenseViewModel>()
                                                          .setEditValue(null);
                                                      License _license =
                                                          License(
                                                              auth_id: AuthId);

                                                      context
                                                          .read<
                                                              LicenseViewModel>()
                                                          .fetchLicense(
                                                              _license,
                                                              authToken!);
                                                    });
                                                  } else {
                                                    context
                                                        .read<
                                                            LicenseViewModel>()
                                                        .storeLicense(license!,
                                                            authToken!)
                                                        .then((value) {
                                                      _titleController.text =
                                                          '';
                                                      _numberController.text =
                                                          '';
                                                      _dateController.text = '';
                                                      License _license =
                                                          License(
                                                              auth_id: AuthId);
                                                      context
                                                          .read<
                                                              LicenseViewModel>()
                                                          .fetchLicense(
                                                              _license,
                                                              authToken!);
                                                    });
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              (_isCardOpen == true) ? Divider() : SizedBox(),
              SizedBox(
                height: 10,
              ),
              Text(
                'All License',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(),
              Consumer<LicenseViewModel>(
                builder: (context, provider, child) {
                  final isLoading = licenseViewModel.isLicenseDataLoading;
                  List<License> _licenseList = licenseViewModel.licenseList;
                  return Expanded(
                    child: isLoading
                        ? Utils.LoadingIndictorWidtet()
                        : _licenseList.isEmpty
                            ? Center(child: Text('No Licences'))
                            : ListView.separated(
                                itemCount: _licenseList.length,
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const Divider(
                                  height: 2,
                                ),
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    padding: EdgeInsets.only(
                                        left: 8, top: 10, bottom: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6,
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                  _licenseList[index].title ??
                                                      "",
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    if (!licenseViewModel
                                                        .isOpen) {
                                                      licenseViewModel
                                                          .isAddOpen();
                                                    }
                                                    context
                                                        .read<
                                                            LicenseViewModel>()
                                                        .setEditValue(
                                                            _licenseList[index],
                                                            isUpdatingData:
                                                                true);
                                                  },
                                                  icon: Icon(Icons.edit),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    License _license = License(
                                                      id: _licenseList[index]
                                                          .id,
                                                    );
                                                    _licenseList
                                                        .removeAt(index);
                                                    context
                                                        .read<
                                                            LicenseViewModel>()
                                                        .deleteLicense(_license,
                                                            authToken!)
                                                        .then((value) {});
                                                  },
                                                  icon: Icon(Icons.delete),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(_licenseList[index].number ??
                                                ""),
                                            Spacer(),
                                            Text(Utils.changeDateType(
                                                _licenseList[index]
                                                        .expiry_date ??
                                                    "")),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );

                                  // return ListTile(
                                  //   dense: true,
                                  //   title: Row(
                                  //     children: [
                                  //       Container(
                                  //         width: MediaQuery.of(context)
                                  //                 .size
                                  //                 .width *
                                  //             0.571,
                                  //         child: SingleChildScrollView(
                                  //           scrollDirection: Axis.horizontal,
                                  //           child: Text(
                                  //             _licenseList[index].title ?? "",
                                  //             style: TextStyle(
                                  //               fontSize: 20,
                                  //               fontWeight: FontWeight.bold,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       Row(
                                  //         children: [
                                  //           IconButton(
                                  //               onPressed: () {
                                  //                 if (!licenseViewModel
                                  //                     .isOpen) {
                                  //                   licenseViewModel
                                  //                       .isAddOpen();
                                  //                 }
                                  //                 context
                                  //                     .read<LicenseViewModel>()
                                  //                     .setEditValue(
                                  //                         _licenseList[index],
                                  //                         isUpdatingData: true);
                                  //               },
                                  //               icon: Icon(Icons.edit)),
                                  //           IconButton(
                                  //               onPressed: () {
                                  //                 License _license = License(
                                  //                   id: _licenseList[index].id,
                                  //                 );
                                  //                 _licenseList.removeAt(index);
                                  //                 context
                                  //                     .read<LicenseViewModel>()
                                  //                     .deleteLicense(
                                  //                         _license, authToken!)
                                  //                     .then((value) {});
                                  //               },
                                  //               icon: Icon(Icons.delete)),
                                  //         ],
                                  //       ),
                                  //     ],
                                  //   ),
                                  //   subtitle: Row(
                                  //     crossAxisAlignment:
                                  //         CrossAxisAlignment.start,
                                  //     children: [
                                  //       Text(_licenseList[index].number ?? ""),
                                  //       Spacer(),
                                  //       Text(Utils.changeDateType(
                                  //           _licenseList[index].expiry_date ??
                                  //               "")),
                                  //     ],
                                  //   ),
                                  // );
                                },
                              ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
