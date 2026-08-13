import 'package:flutter/material.dart';

/// Simple responsive-size helpers, matching the API already used across the
/// employee (ESD ERP) app: ResponsiveSize.init(context, orientation) once at
/// the top of a screen, then getTextSize()/getVerticalSpace()/etc anywhere.
class ResponsiveSize {
  static late double _width;
  static late double _height;
  static const double _designWidth = 375; // reference design width (iPhone-ish)
  static const double _designHeight = 812;

  static void init(BuildContext context, [Orientation? orientation]) {
    final size = MediaQuery.of(context).size;
    _width = orientation == Orientation.landscape ? size.height : size.width;
    _height = orientation == Orientation.landscape ? size.width : size.height;
  }

  static double get widthScale => (_width) / _designWidth;
  static double get heightScale => (_height) / _designHeight;
}

double getTextSize(double size) {
  final scale = ResponsiveSize.widthScale;
  return size * (scale.clamp(0.85, 1.25));
}

double getScreeWidth(double width) => width * ResponsiveSize.widthScale;

double getScreenHeight(double height) => height * ResponsiveSize.heightScale;

Widget getVerticalSpace(double height) => SizedBox(height: getScreenHeight(height));

Widget getHorizontalSpace(double width) => SizedBox(width: getScreeWidth(width));
