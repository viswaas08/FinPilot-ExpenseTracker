import 'package:flutter/material.dart';

abstract class AppSpacing {
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  static const SizedBox gap4 = SizedBox(width: space4, height: space4);
  static const SizedBox gap8 = SizedBox(width: space8, height: space8);
  static const SizedBox gap12 = SizedBox(width: space12, height: space12);
  static const SizedBox gap16 = SizedBox(width: space16, height: space16);
  static const SizedBox gap20 = SizedBox(width: space20, height: space20);
  static const SizedBox gap24 = SizedBox(width: space24, height: space24);
  static const SizedBox gap32 = SizedBox(width: space32, height: space32);
  static const SizedBox gap40 = SizedBox(width: space40, height: space40);
  static const SizedBox gap48 = SizedBox(width: space48, height: space48);

  static const EdgeInsets cardPadding = EdgeInsets.all(space20);
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: space20, vertical: space16);
}
