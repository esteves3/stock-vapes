import 'package:flutter/material.dart';

enum ResponsiveFlags { 
   height, 
   width
}

enum FontFlags { 
   extraLight, 
   light,
   regular,
   medium
}

class Constants{
  static const String title = "App Base";

  /*COLORS*/
  static const Color kPrimaryColor = Color(0xFFFF8C42);
  /*COLORS*/

  /*IMAGES PATH*/
  static const String assetsPath = "assets/images/";
  static const String logoPath = "${assetsPath}test.png";
  /*IMAGES PATH*/

  /*SHARED PREFERENCES KEYS*/
  /*SHARED PREFERENCES KEYS*/

  /*RESPONSIVE*/ //This case: Iphone 13 Pro
  static const int prototypeHeight = 844;
  static const int prototypeWidth = 390;
  /*RESPONSIVE*/

  /*HERO TAGS*/
  /*HERO TAGS*/ 
}