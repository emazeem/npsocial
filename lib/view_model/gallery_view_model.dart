import 'package:flutter/material.dart';
import 'package:np_social/model/NpDateTime.dart';
import 'package:np_social/model/Post.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/model/apis/api_response.dart';
import 'package:np_social/model/directories/gallery_repo.dart';
import 'package:np_social/model/directories/post_repo.dart';
import 'package:np_social/model/Gallery.dart';

class GalleryViewModel extends ChangeNotifier {

  
  Gallery? galleryResponse=Gallery();
  GalleryRepo _galleryRepo=GalleryRepo();

  GalleryViewModel({this.galleryResponse});


  List<Gallery?> _myGalleryImages=[];
  List<Gallery?> get getGalleryImages => _myGalleryImages;

  set setGalleryImages(List<Gallery> _myImages) {
    _myGalleryImages = _myImages;
    notifyListeners();
  }


  ApiResponse _fetchGalleryStatus=ApiResponse();
  ApiResponse get getGalleryStatus => _fetchGalleryStatus;

  Future fetchMygalleryImages(dynamic data,String token) async {
    _fetchGalleryStatus = ApiResponse.loading('Fetching gallery images');
    try{
      final response =  await _galleryRepo.getGalleryImages(data,token);
      List<Gallery?> myGalleryImages=[];

      response['data'].forEach((item) {

        item['created_at']=NpDateTime.fromJson(item['created_at']);
        myGalleryImages.add(Gallery.fromJson(item));
      });
      _myGalleryImages=myGalleryImages;
      _fetchGalleryStatus = ApiResponse.completed(_myGalleryImages);
      notifyListeners();
    }catch(e){
      _fetchGalleryStatus= ApiResponse.error('Please try again.!');
    }

  }



}