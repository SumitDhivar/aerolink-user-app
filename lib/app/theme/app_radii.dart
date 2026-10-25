import 'package:flutter/material.dart';

/// Corner radius tokens conforming to ARSP-DS-001.
class AppRadii {
  AppRadii._();

  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius border4 = BorderRadius.all(Radius.circular(radius4));
  static const BorderRadius border8 = BorderRadius.all(Radius.circular(radius8));
  static const BorderRadius border12 = BorderRadius.all(Radius.circular(radius12));
  static const BorderRadius border16 = BorderRadius.all(Radius.circular(radius16));
  static const BorderRadius border24 = BorderRadius.all(Radius.circular(radius24));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(radiusFull));

  static const BorderRadius sheetTop24 = BorderRadius.vertical(top: Radius.circular(radius24));
}
