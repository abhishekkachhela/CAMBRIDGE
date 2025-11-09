import 'package:shared_preferences/shared_preferences.dart';

import '../assistantMethods/cart_methods.dart';



SharedPreferences? sharedPreferences;

final itemsImagesList =
[
  "slider/0.jpg",
  "slider/1.jpg",
  "slider/2.jpg",
  "slider/3.jpg",
  "slider/4.jpg",
  ];

CartMethods cartMethods = CartMethods();

double countStarsRating = 0.0;
String titleStarsRating = "";