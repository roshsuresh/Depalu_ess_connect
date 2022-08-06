import 'package:flutter/material.dart';

class SizeConfig {
  static SizeConfig? _instance;
  static BuildContext? context;
  static SizeConfig? instance(BuildContext context) {
    if (_instance == null) _instance = SizeConfig._init(context);
    return _instance;
  }

  static MediaQueryData? _mediaQueryData;
  static double? _screenWidth;
  static double? _screenHeight;

  SizeConfig._init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    _screenWidth = _mediaQueryData!.size.width;
    _screenHeight = _mediaQueryData!.size.height;
  }

  double getProportionateScreenHeight(double inputHeight) {
    double screenHeight = _screenHeight!;
    return (inputHeight / 812.0) * screenHeight;
  }

  double getProportionateScreenWidth(double inputWidth) {
    double screenWidth = _screenWidth!;
    return (inputWidth / 375.0) * screenWidth;
  }

  double? getScreenWidth() {
    return _screenWidth;
  }

  double? getScreenHeight() {
    return _screenHeight;
  }
}