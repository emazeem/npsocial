import 'dart:io';

import 'package:flutter/material.dart';
import 'package:np_social/model/Category.dart';
import 'package:np_social/model/Products.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/colors/AppColors.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/product/add_product.dart';
import 'package:np_social/view/screens/product/product_details.dart';
import 'package:np_social/view_model/product_category_view_model.dart';
import 'package:np_social/view_model/products_view_model.dart';
import 'package:provider/provider.dart';

class MarketPlaceScreen extends StatefulWidget {
  const MarketPlaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketPlaceScreen> createState() => _MarketPlaceScreenState();
}

class _MarketPlaceScreenState extends State<MarketPlaceScreen> {
  String? authToken;
  int? AuthId;
  List<CategoryModel> _categories = [];

  Map _myProductParam = {'key': 'my'};
  bool isActive = true;
  String _selectedCategory = 'All Categories';
  String? _selectedSortBy;

  String? _filterKey = 'all';
  String? _filterTime = 'ASC';
  String? _filterPrice = '';
  Map _allProductParam = {};

  applyFilter({filter, int? categoryIndex = 0, orderBy = 'ASC'}) {
    if (filter == 'time') {
      setState(() {
        _filterTime = orderBy;
        _filterPrice = '';
        _selectedCategory = 'All Categories';
        _allProductParam = {'time': orderBy};
      });
    }
    if (filter == 'price') {
      setState(() {
        _filterPrice = orderBy;
        _selectedCategory = 'All Categories';
        _allProductParam = {'price': orderBy};
      });
    }
    if (filter == 'category') {
      setState(() {
        _selectedSortBy = 'Sort By';
        _filterTime = 'ASC';
        _filterPrice = '';
        if (categoryIndex == 0) {
          _allProductParam = {'time': _filterTime};
        } else {
          _allProductParam = {'category': '${categoryIndex}'};
        }
      });
    }
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    Provider.of<ProductViewModel>(context, listen: false).setProducts([]);
    Provider.of<ProductViewModel>(context, listen: false)
        .fetchProducts(_allProductParam, authToken!);
  }

  Future<void> _fetchMyProducts() async {
    Provider.of<ProductViewModel>(context, listen: false).setProducts([]);
    Provider.of<ProductViewModel>(context, listen: false)
        .fetchMyProducts(_myProductParam, authToken!);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _allProductParam = {
        'key': _filterKey,
        'time': _filterTime,
        'price': _filterPrice
      };
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      Provider.of<ProductCategoryViewModel>(context, listen: false)
          .setProductCategories([]);
      Provider.of<ProductCategoryViewModel>(context, listen: false)
          .fetchCategoryProducts(authToken!);
      _fetchProducts();
      _fetchMyProducts();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _categories = Provider.of<ProductCategoryViewModel>(context).categoryList;

    List<PopupMenuEntry> _popupMenusCategory = [];
    _popupMenusCategory.add(PopupMenuItem(
      value: 0,
      child: Text('All Categories', style: TextStyle(fontSize: 12)),
      onTap: () {
        setState(() {
          _selectedCategory = 'All Categories';
        });
        applyFilter(filter: 'category', categoryIndex: 0);
      },
    ));
    _categories.forEach((element) {
      _popupMenusCategory.add(PopupMenuItem(
        value: element.id,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Text('${element.title}', style: TextStyle(fontSize: 12)),
        ),
        onTap: () {
          setState(() {
            _selectedCategory = ' ${element.title}';
          });
          applyFilter(filter: 'category', categoryIndex: element.id);
        },
      ));
    });

    return DefaultTabController(
      length: 3,
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Constants.np_bg_clr,
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
          bottomNavigationBar: menu(),
          body: Container(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marketplace',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              PopupMenuButton(
                                child: Text(
                                  _selectedCategory,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                itemBuilder: (context) => _popupMenusCategory,
                              ),
                              Icon(
                                Icons.arrow_drop_down_sharp,
                                size: 15,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              PopupMenuButton(
                                child: Row(
                                  children: [
                                    Text(
                                      '${_selectedSortBy == null ? 'Sort By' : _selectedSortBy}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down_sharp,
                                      size: 15,
                                    ),
                                  ],
                                ),
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                itemBuilder: (context) => <PopupMenuEntry>[
                                  PopupMenuItem(
                                    child: Text('Old to New',
                                        style: TextStyle(fontSize: 12)),
                                    onTap: () {
                                      setState(() {
                                        _selectedSortBy = 'Old to New';
                                      });
                                      applyFilter(
                                          filter: 'time', orderBy: 'ASC');
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Text('New to Old',
                                        style: TextStyle(fontSize: 12)),
                                    onTap: () {
                                      setState(() {
                                        _selectedSortBy = 'New to Old';
                                      });
                                      applyFilter(
                                          filter: 'time', orderBy: 'DESC');
                                    },
                                  ),
                                  PopupMenuItem(
                                    enabled: false,
                                    value: 0,
                                    child: Text(
                                      'Price',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    child: Text('Low to High',
                                        style: TextStyle(fontSize: 12)),
                                    onTap: () {
                                      setState(() {
                                        _selectedSortBy = 'Price : Low to High';
                                      });
                                      applyFilter(
                                          filter: 'price', orderBy: 'ASC');
                                    },
                                  ),
                                  PopupMenuItem(
                                    child: Text('High to Low',
                                        style: TextStyle(fontSize: 12)),
                                    onTap: () {
                                      setState(() {
                                        _selectedSortBy = 'Price : High to Low';
                                      });
                                      applyFilter(
                                          filter: 'price', orderBy: 'DESC');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            Provider.of<ProductViewModel>(context)
                                .fetchProducts({'key': 'all'}, authToken!);
                          },
                          child: Consumer<ProductViewModel>(
                            builder: (context, provider, child) {
                              final isLoading =
                                  Provider.of<ProductViewModel>(context)
                                      .isFetchingProduct;
                              final productList =
                                  Provider.of<ProductViewModel>(context)
                                      .productList;
                              return isLoading
                                  ? Utils.LoadingIndictorWidtet()
                                  : Provider.of<ProductViewModel>(context).productList.isEmpty
                                      ? Center(
                                          child: Text('No product found!'),
                                          
                                        )
                                      : GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 200,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20,
                                            childAspectRatio: 0.7,
                                          ),
                                          itemCount: productList.length,
                                          itemBuilder:
                                              (BuildContext ctx, index) {
                                            print('ggggg');
                                            print(productList.length);
                                            return InkWell(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    Constants
                                                        .productDetailsPage,
                                                    arguments: ScreenArguments(
                                                        productList[index].id!,
                                                        productList[index]
                                                            .userId!,
                                                        isMyProduct: AuthId ==
                                                                productList[
                                                                        index]
                                                                    .userId
                                                            ? true
                                                            : false),
                                                  ).then((value) {
                                                    Provider.of<ProductViewModel>(
                                                            context)
                                                        .fetchProducts(
                                                            {'key': 'all'},
                                                            authToken!);
                                                    Provider.of<ProductViewModel>(
                                                            context)
                                                        .fetchMyProducts(
                                                            {'key': 'my'},
                                                            authToken!);
                                                  });
                                                },
                                                child: ProductWidget(
                                                    myProducts:
                                                        productList[index]));
                                          });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AddProductScreen(
                  tabController: DefaultTabController.of(context),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  padding: const EdgeInsets.all(10.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Products',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (isActive) {
                                  setState(() {
                                    isActive = false;
                                  });
                                  Provider.of<ProductViewModel>(context,
                                          listen: false)
                                      .fetchMyProducts(
                                          {'key': 'my', 'only_trash': '1'},
                                          authToken!);
                                } else {
                                  setState(() {
                                    isActive = true;
                                  });
                                  Provider.of<ProductViewModel>(context,
                                          listen: false)
                                      .fetchMyProducts(
                                          {'key': 'my'}, authToken!);
                                }
                              },
                              child: Container(
                                child: Row(
                                  children: [
                                    Text(
                                      isActive ? 'Active' : 'Trashed',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                          color: !isActive
                                              ? Colors.red
                                              : Colors.green),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isActive
                                            ? Icons.toggle_on
                                            : Icons.toggle_off,
                                        size: 37,
                                        color: !isActive
                                            ? Colors.red
                                            : Colors.green,
                                      ),
                                      onPressed: () {
                                        if (isActive) {
                                          setState(() {
                                            isActive = false;
                                          });
                                          Provider.of<ProductViewModel>(context,
                                                  listen: false)
                                              .fetchMyProducts({
                                            'key': 'my',
                                            'only_trash': '1'
                                          }, authToken!);
                                        } else {
                                          setState(() {
                                            isActive = true;
                                          });
                                          Provider.of<ProductViewModel>(context,
                                                  listen: false)
                                              .fetchMyProducts(
                                                  {'key': 'my'}, authToken!);
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
                      Divider(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            Provider.of<ProductViewModel>(context)
                                .fetchMyProducts({'key': 'my'}, authToken!);
                          },
                          child: Consumer<ProductViewModel>(
                            builder: (context, provider, child) {
                              final isLoading =
                                  Provider.of<ProductViewModel>(context)
                                      .isFetchingProduct;
                              final productList =Provider.of<ProductViewModel>(context).myProductList;
                              return isLoading
                                  ? Utils.LoadingIndictorWidtet()
                                  : Provider.of<ProductViewModel>(context)
                                          .myProductList
                                          .isEmpty
                                      ? Center( child: Text('No product found!'),)
                                      : GridView.builder(
                                          gridDelegate:const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 200,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20,
                                            childAspectRatio: 0.7,
                                          ),
                                          itemCount: productList.length,
                                          itemBuilder:
                                              (BuildContext ctx, index) {
                                            return InkWell(
                                                onTap: () {
                                                  if (isActive) {
                                                    Navigator.pushNamed(
                                                      context,
                                                      Constants
                                                          .productDetailsPage,
                                                      arguments: ScreenArguments(
                                                          productList[index]
                                                              .id!,
                                                          productList[index]
                                                              .userId!,
                                                          isMyProduct: AuthId ==
                                                                  productList[
                                                                          index]
                                                                      .userId
                                                              ? true
                                                              : false),
                                                    ).then((value) {
                                                      setState(() {
                                                        _myProductParam = {
                                                          'key': 'my'
                                                        };
                                                        _allProductParam = {
                                                          'key': 'all'
                                                        };
                                                      });
                                                      _fetchProducts();
                                                      _fetchMyProducts();
                                                    });
                                                  }
                                                },
                                                child: ProductWidget(
                                                    myProducts:
                                                        productList[index]));
                                          });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15,)
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget menu() {
    int currentIndex = context.watch<ProductViewModel>().currentTabIndex;
    return Container(
      color: Colors.white,
      child: TabBar(
        labelColor: Constants.np_yellow,
        unselectedLabelColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.all(5.0),
        padding: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: Platform.isIOS?20:10),
        indicatorColor: Constants.np_yellow,
        indicator: currentIndex == 1
            ? BoxDecoration()
            : UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: Constants.np_yellow),
              ),
        // tabs: _tabs,
        tabs: [
          Tab(
            text: "Marketplace",
            // icon: Icon(Icons.euro_symbol),
          ),
          Tab(
            icon: ImageIcon(
              AssetImage('assets/images/plus.png'),
              color:
                  currentIndex == 1 ? Constants.np_yellow : Color(0xFF343232),
              size: 50,
            ),
          ),
          Tab(
            text: "My Products",
            // icon: Icon(Icons.assignment),
          ),
        ],
        onTap: (index) {
          context.read<ProductViewModel>().setCurrentTabIndex(index);
          // productViewModel.fetchCategory(authToken!);
        },
      ),
    );
  }
}

class ProductWidget extends StatelessWidget {
  const ProductWidget({
    Key? key,
    required this.myProducts,
  }) : super(key: key);

  final ProductsModel myProducts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(1),
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(10),
        color: Constants.np_bg_clr,
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Utils.showImage(
                    AppUrl.productImageBaseUrl + myProducts.thumbNailPic!),
                Consumer<ProductViewModel>(
                  builder: (context, provider, child) {
                    final categoryList =
                        context.watch<ProductCategoryViewModel>().categoryList;
                    final index = categoryList.indexWhere(
                        (element) => element.id == myProducts.categoryId);
                    String categoryName = '';
                    if (index != -1) {
                      categoryName = categoryList[index].title ?? '';
                    }
                    return Container(
                        padding: EdgeInsets.all(5),
                        color: Colors.black,
                        child: Text(
                          categoryName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ));
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              myProducts.title ?? "",
              style: TextStyle(),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '\$ ${myProducts.price}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
