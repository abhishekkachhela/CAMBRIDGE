import 'package:cloud_firestore/cloud_firestore.dart';

class Items
{
  String? brandID;
  String? itemID;
  String? itemInfo;
  String? itemTitle;
  String? longDescription;
  String? price;
  Timestamp? publishedDate;
  String? sellerName;
  String? sellerUID;
  String? status;
  String? thumbnailUrl;
  String? quantityInStock;  // Added field
  String? sizesAvailable;   // Added field

  Items({
    this.brandID,
    this.itemID,
    this.itemInfo,
    this.itemTitle,
    this.longDescription,
    this.price,
    this.publishedDate,
    this.sellerName,
    this.sellerUID,
    this.status,
    this.thumbnailUrl,
    this.quantityInStock,  // Added to constructor
    this.sizesAvailable,   // Added to constructor
  });

  Items.fromJson(Map<String, dynamic> json)
  {
    brandID = json["brandID"];
    itemID = json["itemID"];
    itemInfo = json["itemInfo"];
    itemTitle = json["itemTitle"];
    longDescription = json["longDescription"];
    price = json["price"];
    publishedDate = json["publishedDate"];
    sellerName = json["sellerName"];
    sellerUID = json["sellerUID"];
    status = json["status"];
    thumbnailUrl = json["thumbnailUrl"];
    quantityInStock = json["quantityInStock"];  // Added to fromJson
    sizesAvailable = json["sizesAvailable"];    // Added to fromJson
  }
}