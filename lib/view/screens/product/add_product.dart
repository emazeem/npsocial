import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:np_social/model/Category.dart';
import 'package:np_social/model/Products.dart';
import 'package:np_social/res/constant.dart';
import 'package:np_social/shared_preference/app_shared_preference.dart';
import 'package:np_social/utils/Utils.dart';
import 'package:np_social/view_model/products_view_model.dart';
import 'package:provider/provider.dart';

class AddProductScreen extends StatefulWidget {
  final TabController? tabController;
  AddProductScreen({Key? key, this.tabController}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  var authToken;
  var authId;
  final _titleTxtController = TextEditingController();
  final _priceTxtController = TextEditingController();
  final _areaTxtController = TextEditingController();
  final _detailTxtController = TextEditingController();
  final _titleFocus = FocusNode();
  final _priceFocus = FocusNode();
  final _areaFocus = FocusNode();
  final _detailFocus = FocusNode();
  int? selectedCategory;
  File? postImage;
  List<File> postImageList = [];
  XFile? imagePath;
  List<XFile?> imagePathList = [];
  bool isSelectedFile = false;
  int selectedIndex = 0;
  ProductViewModel _productViewModel = ProductViewModel();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      authToken = await AppSharedPref.getAuthToken();
      authId = await AppSharedPref.getAuthId();
      _productViewModel = Provider.of<ProductViewModel>(context, listen: false);
      _productViewModel.fetchCategory(authToken);
    });
    super.initState();
  }

  void getImage(String type) async {
    final ImagePicker _picker = ImagePicker();
    if (type == 'gallery') {
      imagePathList = await _picker.pickMultiImage(
        imageQuality: 100,
        maxHeight: 300,
      );
      if (imagePathList.isNotEmpty) {
        for (var image in imagePathList) {
          File file = File(image!.path);
          // double temp = file.lengthSync() / (1024 * 1024);
          postImage = file;
          postImageList.add(postImage!);
        }
        setState(() {
          isSelectedFile = true;
        });
      } else {
        setState(() {
          isSelectedFile = false;
        });
        Utils.toastMessage('Image not selected!');
      }
    } else {
      imagePath = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
        maxHeight: 300,
      );
      if (imagePath != null) {
        File file = File(imagePath!.path);
        double temp = file.lengthSync() / (1024 * 1024);
        setState(() {
          isSelectedFile = true;
        });
        postImage = file;
        postImageList.add(postImage!);
      } else {
        setState(() {
          isSelectedFile = false;
        });
        Utils.toastMessage('Image not selected!');
      }
    }
  }

  void removeAttachment() {
    postImage = null;
    postImageList = [];
    imagePathList = [];
    setState(() {
      isSelectedFile = false;
    });
  }

  pickRespectiveFile() {
    getImage('gallery');
  }

  @override
  void dispose() {
    _titleTxtController.dispose();
    _priceTxtController.dispose();
    _areaTxtController.dispose();
    _detailTxtController.dispose();
    _productViewModel.disposeData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: ListView(

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Product',
                        style: Constants().np_heading,
                        textAlign: TextAlign.left,
                      ),
                      SizedBox(height: 10,),
                      Text('*You can select upto 5 Images.',style: TextStyle(fontSize: 10,color: Colors.grey),),
                      Text('*Image size must be less than 5MB.',style: TextStyle(fontSize: 10,color: Colors.grey),),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: Colors.black,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: InkWell(
                              onTap: pickRespectiveFile,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.image,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: Colors.black,
                        ),
                        child: InkWell(
                          onTap: () {
                            getImage('camera');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.camera_alt_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
            Divider(),
            //Show Selected images
            isSelectedFile
                ? SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: postImageList.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Stack(
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 15, top: 10),
                              child: Stack(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      selectedIndex = index;
                                      Utils.toastMessage(
                                          "Marked as thumbnail");
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(2),
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 4),
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        image: DecorationImage(
                                          image:
                                              FileImage(postImageList[index]),
                                          fit: BoxFit.fill,
                                          opacity: selectedIndex == index
                                              ? 0.4
                                              : 1.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                  selectedIndex == index
                                      ? Positioned(
                                          right: 40,
                                          top: 40,
                                          child: Container(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Icon(Icons.check,
                                                  size: 15,
                                                  color: Colors.white),
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 3,
                                                color: Colors.black,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                  50,
                                                ),
                                              ),
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                            Positioned(
                                top: 1,
                                right: 5,
                                child: InkWell(
                                  onTap: () {
                                    postImageList.removeAt(index);
                                    selectedIndex = 0;
                                    postImageList.length < 1
                                        ? isSelectedFile = false
                                        : true;
                                    setState(() {});
                                  },
                                  child: Container(
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Icon(Icons.close,
                                          size: 15, color: Colors.white),
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 3,
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          50,
                                        ),
                                      ),
                                      color: Colors.black,
                                    ),
                                  ),
                                )),
                          ],
                        );
                      },
                    ),
                  )
                : SizedBox(),
            SizedBox(
              height: 10,
            ),
            //category
            Consumer<ProductViewModel>(
              builder: (context, provider, child) {
                final categoryList = _productViewModel.categoryList;
                categoryList.forEach((element) {
                  print(element.title);
                });
                selectedCategory;
                final isCategoryLoading = _productViewModel.isCategoryLoading;
                return DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                      label: Text('Category'),
                      hintText: 'Category',
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(5.0),
                        ),
                      ),
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 18, horizontal: 10)),
                  value: selectedCategory,
                  icon: isCategoryLoading
                      ? Utils.LoadingIndictorWidtet()
                      : Icon(Icons.arrow_drop_down),
                  items: categoryList.map((category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.title ?? ''),
                    );
                  }).toList(),
                  onChanged: (int? value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                );
              },
            ),
            Container(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _titleTxtController,
                  decoration: InputDecoration(
                    label: Text('Title'),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(5.0),
                      ),
                    ),
                  ),
                  focusNode: _titleFocus,
                  textInputAction: TextInputAction.next,
                )),
            //price
            Container(
                margin: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _priceTxtController,
                  decoration: InputDecoration(
                    label: Text('Price'),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(5.0),
                      ),
                    ),
                  ),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  focusNode: _priceFocus,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                )),
            //area
            selectedCategory == 2
                ? SizedBox()
                : Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _areaTxtController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text('Area in sq. ft.'),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(5.0),
                          ),
                        ),
                      ),
                      focusNode: _areaFocus,
                      textInputAction: TextInputAction.next,
                    )),

            //details
            Container(
                // margin: EdgeInsets.only(top: 10),
                margin: EdgeInsets.only(top: 10),
                // height: 7 * 24.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  controller: _detailTxtController,
                  maxLines: 8,
                  minLines: 3,
                  decoration: InputDecoration(
                    // label: Text('Description'),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(5.0),
                      ),
                    ),
                    hintText: "Write something...",
                  ),
                  maxLength: 200,
                  focusNode: _detailFocus,
                  textInputAction: TextInputAction.done,
                )),
            //button
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 150,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: (!context
                          .watch<ProductViewModel>()
                          .isCategoryDataLoading)
                      ? Text('Add Product')
                      : Utils.LoadingIndictorWidtet(),
                  onPressed: () async {
                    if (postImageList.isEmpty) {
                      Utils.toastMessage('Please select images');
                    }else if (postImageList.length>5) {
                      Utils.toastMessage('Only 5 images are allowed');
                    } else if (_titleTxtController.text.isEmpty) {
                      Utils.toastMessage('Please enter title');
                    } else if (_priceTxtController.text.isEmpty) {
                      Utils.toastMessage('Please enter price');
                    } else if (selectedCategory!=2 && _areaTxtController.text.isEmpty) {
                      Utils.toastMessage('Please enter area');
                    } else if (_detailTxtController.text.isEmpty) {
                      Utils.toastMessage('Please enter description');
                    } else {
                      ProductsModel product = ProductsModel(
                        userId: authId,
                        categoryId: selectedCategory,
                        title: _titleTxtController.text,
                        price: int.parse(_priceTxtController.text),
                        area: selectedCategory==2 ? '0' : _areaTxtController.text,
                        description: _detailTxtController.text,
                        is_thumbnail: selectedIndex,
                        images: postImageList,
                      );
                      _productViewModel
                          .storeProduct(product, authToken)
                          .then((value) {
                        if (value) {
                          widget.tabController?.animateTo(0);
                          context
                              .read<ProductViewModel>()
                              .setCurrentTabIndex(0);
                          context
                              .read<ProductViewModel>()
                              .fetchProducts({'key': 'all'}, authToken!);
                          context
                              .read<ProductViewModel>()
                              .fetchMyProducts({'key': 'my'}, authToken!);
                        }
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
