import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:np_social/model/Products.dart';
import 'package:np_social/model/User.dart';
import 'package:np_social/res/app_url.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view/screens/chatbox.dart';
import 'package:np_social/view_model/products_view_model.dart';
import 'package:np_social/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ScreenArguments arguments;

  const ProductDetailsScreen(this.arguments, {Key? key}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String? authToken;
  int? authId;
  ProductViewModel productViewModel = ProductViewModel();
  int currentIndex = 1;
  late User _userDetail;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      ProductsModel _product = ProductsModel(id: widget.arguments.productId);
      productViewModel.fetchProductDetails(_product, authToken!);
      productViewModel.fetchCategory(authToken!);
      Map data = {'id': '${widget.arguments.userId}'};
      context
          .read<UserViewModel>()
          .getUserDetails(data, authToken!, isSellerDetails: true);
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
    return Scaffold(
      key: _scaffoldKey,
      // backgroundColor: Constants.np_bg_clr,
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
      body: context.watch<ProductViewModel>().isFetchingDetails ||
              productViewModel.productDetails == null
          ? Utils.LoadingIndictorWidtet()
          : SingleChildScrollView(
              child: Container(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      color: Constants.np_bg_clr,
                      child: Stack(
                        children: [
                          CarouselSlider(
                            options: CarouselOptions(
                              viewportFraction: 1,
                              initialPage: 0,
                              onPageChanged: (index, reason) {
                                setState(
                                  () {
                                    currentIndex = index + 1;
                                  },
                                );
                              },
                            ),
                            items:
                                productViewModel.productDetails!.networkImages
                                    ?.map(
                                      (item) => showImage(
                                          "${AppUrl.productImageBaseUrl + item.image!}"),
                                    )
                                    .toList(),
                          ),
                          Positioned(
                              right: 1,
                              bottom: 1,
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  color: Colors.black.withOpacity(0.2),
                                  child: Text(
                                    '$currentIndex / ${productViewModel.productDetails!.networkImages!.length}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ))),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            productViewModel.productDetails!.title ?? '',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '\$ ${productViewModel.productDetails!.price}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          (productViewModel.productDetails!.categoryId == 2)
                              ? Container()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Area in sq. ft. :'),
                                    Text(
                                        productViewModel.productDetails!.area ??
                                            ''),
                                  ],
                                ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Category :'),
                              Consumer<ProductViewModel>(
                                builder: (context, provider, child) {
                                  final categoryList = context
                                      .watch<ProductViewModel>()
                                      .categoryList;
                                  final index = categoryList.indexWhere(
                                      (element) =>
                                          element.id ==
                                          productViewModel
                                              .productDetails!.categoryId);
                                  String categoryName = '';
                                  if (index != -1) {
                                    categoryName =
                                        categoryList[index].title ?? '';
                                  }
                                  return Text(categoryName);
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          Text(
                              '${productViewModel.productDetails!.description}'),
                          SizedBox(height: 16),
                          Text(
                            'Seller Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(),
                          Consumer<UserViewModel>(
                            builder: (context, provider, child) {
                              _userDetail = provider.sellerUserData ?? User();
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    Constants.profileImage(_userDetail),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (BuildContext context,
                                        Object exception,
                                        StackTrace? stackTrace) {
                                      return Constants.defaultImage(50.0);
                                    },
                                  ),
                                ),
                                title: Text(
                                    '${_userDetail.fname} ${_userDetail.lname}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Contact No : ${_userDetail.phone ?? ''}'),
                                    Text(
                                        '${productViewModel.productDetails!.ago ?? ''}'),
                                  ],
                                ),
                                trailing: authId == _userDetail.id
                                    ? widget.arguments.isMyProduct
                                        ? InkWell(
                                            onTap: () {
                                              ProductsModel _product =
                                                  ProductsModel(
                                                      id: widget
                                                          .arguments.productId);

                                              productViewModel
                                                  .removeMyProduct(
                                                      _product, authToken!)
                                                  .then((value) {
                                                Navigator.pop(
                                                    _scaffoldKey
                                                        .currentContext!,
                                                    value);
                                              });
                                            },
                                            child: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ))
                                        : SizedBox()
                                    : InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatBoxScreen(
                                                        _userDetail,
                                                        isMarketChat: true,
                                                        productsModel:
                                                            productViewModel
                                                                .productDetails,
                                                      )));
                                        },
                                        child: Icon(Icons.message)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  Widget showImage(image){
    return CachedNetworkImage(
      imageUrl: image,
      imageBuilder: (context, imageProvider) => Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.contain,
          ),
        ),
      ),
      placeholder: (context, url) => Utils.LoadingIndictorWidtet(),
      errorWidget: (context, url, error) => Image.asset(
        '${Constants.defaultCover}',
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ScreenArguments {
  final int productId;
  final int userId;
  final bool isMyProduct;

  ScreenArguments(this.productId, this.userId, {this.isMyProduct = false});
}
