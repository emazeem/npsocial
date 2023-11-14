import 'package:flutter/cupertino.dart';
import 'package:np_social/model/Category.dart';
import 'package:np_social/model/directories/product_repo.dart';

class ProductCategoryViewModel extends ChangeNotifier {


  ProductRepo _productRepo = ProductRepo();

  List<CategoryModel> _categoryList = [];
  List<CategoryModel> get categoryList => _categoryList;


  void setProductCategories(List<CategoryModel> _noti) {
    _categoryList = _noti;
    notifyListeners();
  }

  Future fetchCategoryProducts(String token) async {
    try {
      final response = await _productRepo.fetchCategoryApi(token);
      List<CategoryModel> categoryListProduct = [];
      var json = response['data'];
      for (var category in json) {
        categoryListProduct.add(CategoryModel.fromJson(category));
      }
      _categoryList=categoryListProduct;
      notifyListeners();
    } catch (e) {
      print(e);
      notifyListeners();
      rethrow;

    }
  }

}
