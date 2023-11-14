import 'dart:convert';
import 'dart:io';

class ProductsModel {
  int? id;
  int? categoryId;
  int? userId;
  int? is_thumbnail;
  String? title;
  int? price;
  String? area;
  String? description;
  List<File>? images;
  List<ProductImages>? networkImages;
  String? thumbNailPic;
  String? ago;
  String? keyCategory;
  String? keyTime;
  String? keyPrice;
  String? key;
  String? trashKey;
  ProductsModel({
    this.categoryId,
    this.id,
    this.userId,
    this.title,
    this.price,
    this.area,
    this.is_thumbnail,
    this.description,
    this.images,
    this.networkImages,
    this.ago,
    this.keyCategory,
    this.keyPrice,
    this.keyTime,
    this.key,
    this.trashKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': this.id == null ? null : this.id.toString(),
      'key': this.key,
      'category': this.keyCategory,
      'price': this.keyPrice,
      'time': this.keyTime,
      'only_trash':this.trashKey,
    };
  }

  setThumbNailImage() {
    for (var image in networkImages!) {
      if (image.is_thumbnail == 1) {
        thumbNailPic = image.image;
      } else {
        thumbNailPic = networkImages!.first.image;
      }
    }
  }

  factory ProductsModel.fromJson(Map<String, dynamic> map) {
    return ProductsModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int,
      title: map['title'] as String,
      price: map['price'] ,
      area: map['area'] as String,
      ago: map['ago'] == null ? null : map['ago'] as String,
      networkImages: map['images'] == null
          ? []
          : List<ProductImages>.from(
              map['images']!.map((x) => ProductImages.fromJson(x))),
      description: map['description'] as String,
    );
  }
}

class ProductImages {
  int? id;
  int? product_id;
  int? is_thumbnail;
  String? image;

  ProductImages({
    this.id,
    this.product_id,
    this.is_thumbnail,
    this.image,
  });

  factory ProductImages.fromJson(Map<String, dynamic> map) {
    return ProductImages(
      id: map['id'] as int,
      product_id: map['product_id'] as int,
      is_thumbnail: map['is_thumbnail'] as int,
      image: map['image'] as String,
    );
  }
}
