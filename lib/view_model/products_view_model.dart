import 'package:flutter/material.dart';
import 'package:np_social/model/Category.dart';
import 'package:np_social/model/Products.dart';
import 'package:np_social/model/directories/product_repo.dart';

class ProductViewModel extends ChangeNotifier {
  List<CategoryModel> _categoryList = [];
  List<CategoryModel> get categoryList => _categoryList;

  Future fetchCategoryProducts(String token) async {
    notifyListeners();
    try {
      notifyListeners();
      final response = await _productRepo.fetchCategoryApi(token);
      List<CategoryModel> categoryListProduct = [];
      var json = response['data'];

      for (var category in json) {
        categoryListProduct.add(CategoryModel.fromJson(category));
        print('json : ${category}');
      }
      _categoryList = categoryList;
      return _categoryList;
      notifyListeners();
    } catch (e) {
      print(e);
      notifyListeners();
      rethrow;
    }
  }

  CategoryModel? _selectedCategory;
  ProductRepo _productRepo = ProductRepo();
  String? _selectedFilterId;
  String _selectedFilter = 'All';
  String _priceFilter = '';
  String _timeFilter = 'New to Old';
  bool _isCategoryLoading = false;
  bool _isCategoryDataLoading = false;
  bool _isFetchingProduct = false;
  bool _isFetchingDetails = false;
  bool _isShowCLearButton = false;
  List<CategoryModel> _categoryListProduct = [];
  List<ProductsModel> _productList = [];
  List<ProductsModel> _myProductList = [];
  List<ProductsModel> _trashedProduct = [];

  ProductsModel? _productDetails;

  CategoryModel? get selectedCategory => _selectedCategory;
  String get selectedFilter => _selectedFilter;
  String? get selectedFilterId => _selectedFilterId;
  String get priceFilter => _priceFilter;
  String get timeFilter => _timeFilter;

  bool get isCategoryLoading => _isCategoryLoading;
  bool get isCategoryDataLoading => _isCategoryDataLoading;
  bool get isFetchingProduct => _isFetchingProduct;
  bool get isFetchingDetails => _isFetchingDetails;
  bool get isShowClearButton => _isShowCLearButton;
  List<CategoryModel> get categoryListProduct => _categoryListProduct;
  List<ProductsModel> get productList => _productList;
  List<ProductsModel> get myProductList => _myProductList;
  List<ProductsModel> get trashedProduct => _trashedProduct;

  ProductsModel? get productDetails => _productDetails;
  int _selectedTabIndex = 0;

  int get currentTabIndex => _selectedTabIndex;

  setCurrentTabIndex(final int index) {
    _selectedTabIndex = index;
    // notify listeners if you want here
    notifyListeners();
  }

  Future fetchCategory(String token) async {
    setLoaderValue(value: true);
    // final data = license.toMap();
    // data.removeWhere((key, value) => value == null);
    final response = await _productRepo.fetchCategoryApi(token);
    try {
      _categoryList = [];
      var json = response['data'];
      for (var category in json) {
        _categoryList.add(CategoryModel.fromJson(category));
      }
      print(_categoryList.length);
      setLoaderValue();
      return response;
    } catch (e) {
      print(response);
      setLoaderValue();
      rethrow;
    }
  }

// Product Screen

//Store Products
  Future storeProduct(ProductsModel data, String token) async {
    setLoaderValue(value: true, type: 'store');

    try {
      final response = await _productRepo.storeProductApi(data, token);
      setLoaderValue(type: 'store');
      return response;
    } catch (e) {
      setLoaderValue(type: 'store');
    }
  }

  void setProducts(List<ProductsModel> _list) {
    _productList = _list;
    notifyListeners();
  }

  //Fetch Products
  Future fetchProducts(dynamic? data, String token) async {
    print(data);
    setLoaderValue(value: true, type: 'fetch');
    dynamic response;
    response = await _productRepo.fetchProductsApi(data, token);
    try {
      _productList = [];
      var json = response['data'];
      for (var product in json) {
        _productList.add(ProductsModel.fromJson(product));
      }
      _productList.forEach((element) {
        if (element.networkImages != null) {
          element.setThumbNailImage();
        }
      });
      setLoaderValue(type: 'fetch');
      return response;
    } catch (e) {
      print(response);
      setLoaderValue(type: 'fetch');
      rethrow;
    }
  }

  void setMyProducts(List<ProductsModel> _list) {
    _myProductList = _list;
    notifyListeners();
  }

  //My Products
  Future fetchMyProducts(dynamic data, String token) async {
    setLoaderValue(value: true, type: 'fetch');
    dynamic response;
    response = await _productRepo.fetchProductsApi(data, token);
    try {
      _myProductList = [];

      var json = response['data'];

      for (var product in json) {
        _myProductList.add(ProductsModel.fromJson(product));
      }
      _myProductList.forEach((element) {
        if (element.networkImages != null) {
          element.setThumbNailImage();
        }
      });
      setLoaderValue(type: 'fetch');
      return response;
    } catch (e) {
      print(response);
      setLoaderValue(type: 'fetch');
      rethrow;
    }
  }

  //Fetch Trash Product
  Future fetchTrashProducts(dynamic data, String token) async {
    setLoaderValue(value: true, type: 'fetch');
    dynamic response;
    response = await _productRepo.fetchProductsApi(data, token);
    try {
      _trashedProduct = [];
      var json = response['data'];
      for (var product in json) {
        _trashedProduct.add(ProductsModel.fromJson(product));
      }
      // _productList[0].networkImages![1].is_thumbnail = 1;
      _trashedProduct.forEach((element) {
        if (element.networkImages != null) {
          element.setThumbNailImage();
        }
      });
      setLoaderValue(type: 'fetch');
      return response;
    } catch (e) {
      print(response);
      setLoaderValue(type: 'fetch');
      rethrow;
    }
  }

  //My Products
  Future removeMyProduct(ProductsModel? productsModel, String token) async {
    setLoaderValue(value: true, type: 'details');
    dynamic response;
    // if (productsModel == null) {
    final data = productsModel?.toMap();
    data!.removeWhere((key, value) => value == null);
    response = await _productRepo.removeProductApi(data, token);
    try {
      // _myProductList = [];
      var json = response['data'];

      print(response['message']);
      // for (var product in json) {
      //   _myProductList.add(ProductsModel.fromJson(product));
      // }
      // // _productList[0].networkImages![1].is_thumbnail = 1;
      // _myProductList.forEach((element) {
      //   if (element.networkImages != null) {
      //     element.setThumbNailImage();
      //   }
      // });
      setLoaderValue(type: 'details');
      return response;
    } catch (e) {
      print(response);
      setLoaderValue(type: 'details');
      rethrow;
    }
  }

  //Product Details
  Future fetchProductDetails(ProductsModel productsModel, String token) async {
    setLoaderValue(value: true, type: 'details');
    final data = productsModel.toMap();
    data.removeWhere((key, value) => value == null);
    final response = await _productRepo.fetchProductDetailsApi(data, token);
    try {
      _productDetails = null;
      var json = response['data'];
      _productDetails = ProductsModel.fromJson(json);
      _productDetails?.setThumbNailImage();
      setLoaderValue(type: 'details');
      return response;
    } catch (e) {
      print(response);
      setLoaderValue(type: 'details');
      rethrow;
    }
  }

  //Selected Filter
  void selectFilter(String filterName, String? id) {
    _selectedFilter = filterName;
    _selectedFilterId = id;
    _isShowCLearButton = true;
    notifyListeners();
  }

  //Selected time Filter
  void selectFilterTime(String filterName) {
    if (filterName == 'New to Old') {
      _timeFilter = 'Old to New';
    } else if (filterName == 'Old to New') {
      _timeFilter = 'New to Old';
    } else {
      _timeFilter = 'New to Old';
    }
    _isShowCLearButton = true;
    notifyListeners();
  }

  //Selected price Filter
  void selectFilterPrice(String filterName) {
    if (filterName == 'Price (High to Low)') {
      _priceFilter = 'Price (Low to High)';
    } else if (filterName == 'Price (Low to High)') {
      _priceFilter = 'Price (High to Low)';
    } else {
      _priceFilter = '';
    }
    _isShowCLearButton = true;
    notifyListeners();
  }

  void setLoaderValue({bool value = false, String type = 'category'}) {
    if (type == 'category') {
      _isCategoryLoading = value;
    } else if (type == 'fetch') {
      _isFetchingProduct = value;
    } else if (type == 'details') {
      _isFetchingDetails = value;
    } else {
      _isCategoryDataLoading = value;
    }
    notifyListeners();
  }

  void clearAllFilters() {
    _selectedFilter = 'All';
    _timeFilter = '';
    _priceFilter = '';
    _isShowCLearButton = false;
    _selectedFilterId = null;
    notifyListeners();
  }

  void disposeData() {
    _selectedCategory = null;
    _isCategoryLoading = false;
    _isCategoryDataLoading = false;
    _categoryList = [];
    _selectedFilter = 'All';
    _timeFilter = '';
    _priceFilter = '';
    _isShowCLearButton = false;
    _selectedFilterId = null;
    _selectedTabIndex = 0;
  }
}
