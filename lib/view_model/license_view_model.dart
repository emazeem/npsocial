import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:np_social/model/directories/license_repo.dart';
import 'package:np_social/model/license.dart';

class LicenseViewModel extends ChangeNotifier {
  bool _isLicenseLoading = false;
  bool _isLicenseDataLoading = false;
  bool _isUpdating = false;
  bool _isOpen = false;
  License? _updateResponse ;
  LicenseRepo _licenseRepo = LicenseRepo();
  List<License> _licenseList = [];

  bool get isLicenseLoading => _isLicenseLoading;
  bool get isUpdating => _isUpdating;
  bool get isOpen => _isOpen;
  bool get isLicenseDataLoading => _isLicenseDataLoading;
  List<License> get licenseList => _licenseList;
  License? get updateResponse => _updateResponse;
  Future storeLicense(License license, String token) async {
    setLoaderValue(value: true);
    final data = license.toMap();
    data.removeWhere((key, value) => value == null);
    final response = await _licenseRepo.storeLicenseApi(data, token);
    try {
      setLoaderValue();
      return response;
    } catch (e) {
      print(response);
      setLoaderValue();
      rethrow;
    }
  }

  Future fetchLicense(License license, String token) async {
    setLoaderValue(value: true, loader: 'fetch');
    final data = license.toMap();
    data.removeWhere((key, value) => value == null);
    final response = await _licenseRepo.fetchLicenseApi(data, token);
    try {
      _licenseList = [];
      var json = response['data'];
      for (var license in json){
        _licenseList.add(License.fromJson(license));
      }
      setLoaderValue(loader: 'fetch');
      return response;
    } catch (e) {
      print(response);
      setLoaderValue(loader: 'fetch');
      rethrow;
    }
  }
  Future deleteLicense(License license, String token) async {
    setLoaderValue(value: true, loader: 'delete');
    final data = license.toMap();
    data.removeWhere((key, value) => value == null);
    final response = await _licenseRepo.deleteLicenseApi(data, token);
    try {
      setLoaderValue(loader: 'fetch');
      return response;
    } catch (e) {
      print(response);
      setLoaderValue(loader: 'fetch');
      rethrow;
    }
  }

  Future updateLicense(License license, String token) async {
    setLoaderValue(value: true);
    final data = license.toMap();
    data.removeWhere((key, value) => value == null);
    final response = await _licenseRepo.updateLicenseApi(data, token);
    try {
      setLoaderValue();
      return response;
    } catch (e) {
      print(response);
      setLoaderValue();
      rethrow;
    }
  }


  void setLoaderValue({bool value = false, String loader = 'store'}) {
    if (loader == 'store') {
      _isLicenseLoading = value;
    } else {
      _isLicenseDataLoading = value;
    }

    notifyListeners();
  }

  void setEditValue(License? license,{bool isUpdatingData = false}){
    _isUpdating = isUpdatingData;
    if(_isUpdating){
      _updateResponse = license;
    }else{
      _updateResponse = null;
    }
    notifyListeners();
  }

  void isAddOpen(){
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void disposeData() {
     _isLicenseLoading = false;
     _isLicenseDataLoading = false;
     _isUpdating = false;
     _isOpen = false;
     _updateResponse = null ;
     _licenseList = [];
  }

}
