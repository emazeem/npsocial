import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:np_social/model/Products.dart';
import 'package:np_social/model/services/BaseApiServices.dart';
import 'package:np_social/model/services/NetworkApiServices.dart';
import 'package:np_social/res/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:np_social/utils/Utils.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';

class ProductRepo {
  BaseApiServices _apiServices = NetworkApiServices();
  Future<dynamic> fetchCategoryApi(token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.fetchCategory, '', token);
    try {
      Map res = {
        'message': response['message'],
        'data': response['data'],
      };
      return res;
    } catch (e) {
      Map res = {
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

  //Store
  Future<bool> storeProductApi(ProductsModel data, token) async {
    Dio dio = new Dio();
    String uploadUrl = AppUrl.storeProduct;

    var formData;
    formData = FormData.fromMap(
      {
        'user_id': data.userId,
        'category_id': data.categoryId,
        'title': data.title,
        'price': data.price,
        'is_thumbnail': data.is_thumbnail,
        'area': data.area,
        'description': data.description,
        "images[]": [
          for (var image in data.images!)
            await MultipartFile.fromFile(image.path,
                filename: basename(image.path))
        ],
      },
    );
    try {
      Response response = await dio.post(
        uploadUrl,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            'Authorization': "Bearer " + token
          },
          receiveTimeout: 200000,
          sendTimeout: 200000,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      var logger = Logger();
      logger.d(response.data);
      logger.d(url);
      if (response.statusCode == 200) {
        Utils.toastMessage('Your product has been added');
        return true;
      } else {
        print("Error during connection to server.");
        return false;
      }
    } catch (e) {
      Utils.toastMessage(e.toString());
      rethrow;
    }
  }

//Fetch Products
  Future<dynamic> fetchProductsApi(final data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.fetchProduct, data, token);
    try {
      Map res = {
        'message': response['message'],
        'data': response['data'],
      };
      return res;
    } catch (e) {
      Map res = {
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

//Fetch Product Details
  Future<dynamic> fetchProductDetailsApi(dynamic data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.fetchProductDetails, data, token);
    try {
      Map res = {
        'message': response['message'],
        'data': response['data'],
      };
      return res;
    } catch (e) {
      Map res = {
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

  //Remove My Product
  Future<dynamic> removeProductApi(dynamic data, token) async {
    dynamic response = await _apiServices.getPostAuthApiResponse(
        AppUrl.removeProduct, data, token);
    try {
      Map res = {
        'message': response['message'],
        'data': response['data'],
      };
      return res;
    } catch (e) {
      Map res = {
        'message': e.toString(),
      };
      return jsonEncode(res);
    }
  }

}
