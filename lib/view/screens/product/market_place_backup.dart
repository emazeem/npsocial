import 'package:flutter/material.dart';
import 'package:np_social/model/Products.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/product/add_product.dart';
import 'package:np_social/view/screens/product/product_details.dart';
import 'package:np_social/view_model/products_view_model.dart';
import 'package:provider/provider.dart';

class MarketPlaceScreen2 extends StatefulWidget {
  const MarketPlaceScreen2({Key? key}) : super(key: key);

  @override
  State<MarketPlaceScreen2> createState() => _MarketPlaceScreen2State();
}

class _MarketPlaceScreen2State extends State<MarketPlaceScreen2>
    with TickerProviderStateMixin {
  String? authToken;
  int? AuthId;
  bool isSwitchOn = true;
  ProductViewModel productViewModel = ProductViewModel();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      authToken = await AppSharedPref.getAuthToken();
      AuthId = await AppSharedPref.getAuthId();
      // ProductsModel _product = ProductsModel(userId: AuthId);
      ProductsModel _productAll = ProductsModel(key: 'all');
      ProductsModel _productMe = ProductsModel(key: 'my');
      productViewModel.fetchProducts(_productAll, authToken!);
      productViewModel.fetchMyProducts(_productMe, authToken!);
      productViewModel.fetchCategoryProducts(authToken!);
    });
    super.initState();
  }

  @override
  void dispose() {
    productViewModel.disposeData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Marketplace',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<ProductViewModel>(
                              builder: (context, provider, child) {
                                final filterName = provider.selectedFilter;
                                final filterId = provider.selectedFilterId;
                                final filterTime = provider.timeFilter;
                                final filterPrice = provider.priceFilter;
                                return Row(
                                  children: [
                                    Consumer(
                                      builder: (context, ref, child) {
                                        final categoryList = context
                                            .watch<ProductViewModel>()
                                            .categoryListProduct;
                                        return PopupMenuButton(
                                          child: Text(filterName),
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          itemBuilder: (context) =>
                                              <PopupMenuEntry>[
                                            ///Category
                                            PopupMenuItem(
                                              value: 1,
                                              child: Text('Categories'),
                                              enabled: false,
                                            ),
                                            PopupMenuDivider(),
                                            PopupMenuItem(
                                                onTap: () {
                                                  context
                                                      .read<ProductViewModel>()
                                                      .selectFilter(
                                                          'All', null);
                                                  ProductsModel _product =
                                                      ProductsModel(
                                                          key: 'all',
                                                          keyCategory: null,
                                                          keyTime: filterTime
                                                                  .isEmpty
                                                              ? null
                                                              : filterTime ==
                                                                      'Old to New'
                                                                  ? 'ASC'
                                                                  : filterTime ==
                                                                          'new-to-old'
                                                                      ? 'DESC'
                                                                      : null,
                                                          keyPrice: filterPrice
                                                                  .isEmpty
                                                              ? null
                                                              : filterPrice ==
                                                                      'Price (Low to High)'
                                                                  ? 'ASC'
                                                                  : filterPrice ==
                                                                          'Price (High to Low)'
                                                                      ? 'DESC'
                                                                      : null);
                                                  productViewModel
                                                      .fetchProducts(
                                                          _product, authToken!);
                                                  // productViewModel.fetchProducts(
                                                  //     null, authToken!);
                                                },
                                                value: 'All',
                                                child: Text('All')),
                                            ...categoryList
                                                .map((s) => PopupMenuItem(
                                                    onTap: () {
                                                      context
                                                          .read<
                                                              ProductViewModel>()
                                                          .selectFilter(
                                                              s.title ?? 'All',
                                                              s.id.toString());
                                                      ProductsModel _product =
                                                          ProductsModel(
                                                              key: 'all',
                                                              keyCategory:
                                                                  '${s.id}',
                                                              keyTime: filterTime
                                                                      .isEmpty
                                                                  ? null
                                                                  : filterTime ==
                                                                          'Old to New'
                                                                      ? 'ASC'
                                                                      : 'DESC',
                                                              keyPrice: filterPrice
                                                                      .isEmpty
                                                                  ? null
                                                                  : filterPrice ==
                                                                          'Price (Low to High)'
                                                                      ? 'price-low-to-high'
                                                                      : filterPrice ==
                                                                              'Price (High to low)'
                                                                          ? 'price-high-to-low'
                                                                          : '');
                                                      productViewModel
                                                          .fetchProducts(
                                                              _product,
                                                              authToken!);
                                                      // productViewModel
                                                      //     .fetchCategory(authToken!);
                                                    },
                                                    value: s,
                                                    child: Text(s.title ?? "")))
                                                .toList(),
                                          ],
                                        );
                                      },
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            context
                                                .read<ProductViewModel>()
                                                .selectFilterTime('');
                                            productViewModel.selectFilterPrice(
                                                filterPrice.isEmpty
                                                    ? 'Price (Low to High)'
                                                    : filterPrice);
                                            if (filterPrice ==
                                                'Price (High to Low)') {
                                              ProductsModel _product =
                                                  ProductsModel(
                                                      key: 'all',
                                                      keyCategory:
                                                          filterName == 'All'
                                                              ? null
                                                              : '${filterId}',
                                                      keyTime: null,
                                                      keyPrice: 'DESC');
                                              productViewModel.fetchProducts(
                                                  _product, authToken!);
                                            } else {
                                              ProductsModel _product =
                                                  ProductsModel(
                                                      key: 'all',
                                                      keyCategory:
                                                          filterName == 'All'
                                                              ? null
                                                              : '${filterId}',
                                                      keyTime: null,
                                                      keyPrice: 'ASC');
                                              productViewModel.fetchProducts(
                                                  _product, authToken!);
                                            }
                                          },
                                          child: Text(
                                            'Price',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Positioned(
                                              bottom: 0,
                                              child: Icon(
                                                Icons.keyboard_arrow_up,
                                                size: 24,
                                                color: filterPrice ==
                                                        'Price (High to Low)'
                                                    ? Colors.black
                                                    : Colors.grey,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              child: Icon(
                                                Icons.keyboard_arrow_down,
                                                size: 24,
                                                color: filterPrice ==
                                                        'Price (Low to High)'
                                                    ? Colors.black
                                                    : Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              'Text',
                                              style: TextStyle(
                                                  color: Colors.transparent),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        InkWell(
                                            onTap: () {
                                              context
                                                  .read<ProductViewModel>()
                                                  .selectFilterPrice('');
                                              productViewModel.selectFilterTime(
                                                  filterTime.isEmpty
                                                      ? 'Old to New'
                                                      : filterTime);
                                              if (filterTime == 'New to Old') {
                                                ProductsModel _product =
                                                    ProductsModel(
                                                        key: 'all',
                                                        keyCategory:
                                                            filterName == 'All'
                                                                ? null
                                                                : '${filterId}',
                                                        keyTime: 'DESC',
                                                        keyPrice: null);
                                                // ProductsModel _product = ProductsModel(
                                                //     keyTime: 'new-to-old');
                                                productViewModel.fetchProducts(
                                                    _product, authToken!);
                                              } else {
                                                ProductsModel _product =
                                                    ProductsModel(
                                                        key: 'all',
                                                        keyCategory:
                                                            filterName == 'All'
                                                                ? null
                                                                : '${filterId}',
                                                        keyTime: 'ASC',
                                                        keyPrice: null);
                                                productViewModel.fetchProducts(
                                                    _product, authToken!);
                                              }
                                            },
                                            child: Icon(Icons.timelapse)),
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Positioned(
                                              bottom: 0,
                                              child: Icon(
                                                Icons.keyboard_arrow_up,
                                                size: 24,
                                                color:
                                                    filterTime == 'New to Old'
                                                        ? Colors.black
                                                        : Colors.grey,
                                              ),
                                            ),
                                            Positioned(
                                              top: 0,
                                              child: Icon(
                                                Icons.keyboard_arrow_down,
                                                size: 24,
                                                color:
                                                    filterTime == 'Old to New'
                                                        ? Colors.black
                                                        : Colors.grey,
                                              ),
                                            ),
                                            Text(
                                              'Text',
                                              style: TextStyle(
                                                  color: Colors.transparent),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            context.watch<ProductViewModel>().isShowClearButton
                                ? InkWell(
                                    onTap: () {
                                      productViewModel.clearAllFilters();
                                      ProductsModel _productAll =
                                          ProductsModel(key: 'all');
                                      productViewModel.fetchProducts(
                                          _productAll, authToken!);
                                    },
                                    child: Icon(Icons.close))
                                : SizedBox(),
                          ],
                        ),
                      ),
                      Divider(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ProductsModel _productAll =
                                ProductsModel(key: 'all');
                            productViewModel.fetchProducts(
                                _productAll, authToken!);
                          },
                          child: Consumer<ProductViewModel>(
                            builder: (context, provider, child) {
                              final isLoading =
                                  productViewModel.isFetchingProduct;
                              final productList = productViewModel.productList;
                              return isLoading
                                  ? Utils.LoadingIndictorWidtet()
                                  : productViewModel.productList.isEmpty
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
                                                    ProductsModel _productAll =
                                                        ProductsModel(
                                                            key: 'all');
                                                    ProductsModel _productMe =
                                                        ProductsModel(
                                                            key: 'my');
                                                    productViewModel
                                                        .fetchProducts(
                                                            _productAll,
                                                            authToken!);
                                                    productViewModel
                                                        .fetchMyProducts(
                                                            _productMe,
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
                                isSwitchOn = !isSwitchOn;
                                if (!isSwitchOn) {
                                  ProductsModel _productMe =
                                      ProductsModel(key: 'my', trashKey: '1');
                                  productViewModel.fetchTrashProducts(
                                      _productMe, authToken!);
                                }
                                setState(() {});
                              },
                              child: Text(
                                isSwitchOn ? 'Active' : 'Trashed',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: !isSwitchOn
                                        ? Colors.red
                                        : Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            ProductsModel _productMe = ProductsModel(key: 'my');
                            productViewModel.fetchMyProducts(
                                _productMe, authToken!);
                          },
                          child: Consumer<ProductViewModel>(
                            builder: (context, provider, child) {
                              final isLoading =
                                  productViewModel.isFetchingProduct;
                              final myProductList =
                                  productViewModel.myProductList;
                              final trashList = productViewModel.trashedProduct;
                              productViewModel.myProductList;
                              return isLoading
                                  ? Utils.LoadingIndictorWidtet()
                                  : productViewModel.myProductList.isEmpty
                                      ? Center(
                                          child: Text('No products found!'))
                                      : GridView.builder(
                                          gridDelegate:
                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                            maxCrossAxisExtent: 200,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 20,
                                            childAspectRatio: 0.7,
                                          ),
                                          itemCount: isSwitchOn
                                              ? myProductList.length
                                              : trashList.length,
                                          itemBuilder:
                                              (BuildContext ctx, index) {
                                            return isSwitchOn
                                                ? InkWell(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        Constants
                                                            .productDetailsPage,
                                                        arguments:
                                                            ScreenArguments(
                                                          myProductList[index]
                                                              .id!,
                                                          myProductList[index]
                                                              .userId!,
                                                          isMyProduct: true,
                                                        ),
                                                      ).then((value) {
                                                        ProductsModel
                                                            _productAll =
                                                            ProductsModel(
                                                                key: 'all');
                                                        ProductsModel
                                                            _productMe =
                                                            ProductsModel(
                                                                key: 'my');
                                                        productViewModel
                                                            .fetchProducts(
                                                                _productAll,
                                                                authToken!);
                                                        productViewModel
                                                            .fetchMyProducts(
                                                                _productMe,
                                                                authToken!);
                                                      });
                                                    },
                                                    child: ProductWidget(
                                                      myProducts:
                                                          myProductList[index],
                                                      // onChanged: (value) {
                                                      //   print(value);
                                                      //   setState(() {
                                                      //     isSwitchOn = value;
                                                      //   });
                                                      // },
                                                      // isSwitchOn: isSwitchOn,
                                                      // onTap: (){
                                                      //
                                                      // },
                                                      // isMyProduct: true,
                                                    ),
                                                  )
                                                : ProductWidget(
                                                    myProducts:
                                                        trashList[index],
                                                    // onChanged: (value) {
                                                    //   print(value);
                                                    //   setState(() {
                                                    //     isSwitchOn = value;
                                                    //   });
                                                    // },
                                                    // isSwitchOn: isSwitchOn,
                                                    // onTap: (){
                                                    //
                                                    // },
                                                    // isMyProduct: true,
                                                  );
                                          });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: () {
          //     Navigator.pushNamed(context, Constants.addProductPage).then((value) {
          //       if (value == true) {
          //         // ProductsModel _product = ProductsModel(userId: AuthId);
          //         productViewModel.fetchProducts(null, authToken!);
          //         productViewModel.fetchCategory(authToken!);
          //       }
          //     });
          //   },
          //   child: Icon(Icons.add),
          //   backgroundColor: Constants.np_yellow,
          // ),
          // floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
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
        padding: EdgeInsets.all(10),
        indicatorColor: Colors.transparent,
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
    // this.isMyProduct = false,
    // this.onTap,
    // this.onChanged,
    // this.isSwitchOn = true,
  }) : super(key: key);

  final ProductsModel myProducts;
  // final bool isMyProduct;
  // final Function()? onTap;
  // final Function(bool)? onChanged;
  // final bool isSwitchOn;

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
                        context.watch<ProductViewModel>().categoryListProduct;
                    final index = categoryList.indexWhere(
                        (element) => element.id == myProducts.categoryId);
                    String categoryName = '';
                    if (index != -1) {
                      categoryName = categoryList[index].title ?? '';
                    }
                    // print(categoryList.length);
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

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Text(
            //       '\$ ${myProducts.price}',
            //       style: TextStyle(
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //     // isMyProduct
            //     //     // ? Switch(
            //     //     //     // thumb color (round icon)
            //     //     //     activeColor: Constants.np_yellow,
            //     //     //     activeTrackColor: Colors.black,
            //     //     //     inactiveThumbColor: Colors.black54,
            //     //     //     inactiveTrackColor: Colors.white,
            //     //     //     splashRadius: 50.0,
            //     //     //     // boolean variable value
            //     //     //     value: isSwitchOn,
            //     //     //     // changes the state of the switch
            //     //     //     onChanged: onChanged)
            //     // ?IconButton(onPressed: onTap, icon: Icon(Icons.delete,
            //     // color: Colors.red,
            //     // ))
            //     //     : SizedBox(),
            //   ],
            // ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
