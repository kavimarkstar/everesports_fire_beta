import 'package:flutter/material.dart';

class Responsive {
  static const double r0 = 1600;
  static const double r1 = 1500;
  static const double r2 = 1400;
  static const double r3 = 1300;
  static const double r4 = 1200;
  static const double r5 = 1100;
  static const double r6 = 1000;
  static const double r7 = 900;
  static const double r8 = 800;
  static const double r9 = 700;
  static const double r10 = 600;
  static const double r11 = 500;
  static const double r12 = 400;
  static const double r13 = 300;
  static const double r14 = 200;

  static double gridAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= r0) return 1.2;
    if (width >= r1) return 1.2;
    if (width >= r2) return 1.1;
    if (width >= r3) return 1.1;
    if (width >= r4) return 1.05;
    if (width >= r5) return 0.95;
    if (width >= r6) return 0.9;
    if (width >= r7) return 1.15;
    if (width >= r8) return 1.1;
    if (width >= r9) return 1.05;
    if (width >= r10) return 0.9;
    if (width >= r11) return 1.25;
    if (width >= r12) return 1.15;
    if (width >= r13) return 1.05;
    if (width >= r14) return 0.95;
    return 1.0;
  }

  static double gridAspectRatio2(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= r0) return 1.0;
    if (width >= r1) return 1.0;
    if (width >= r2) return 1.0;
    if (width >= r3) return 1.0;
    if (width >= r4) return 1.0;
    if (width >= r5) return 1.0;
    if (width >= r6) return 1.0;
    if (width >= r7) return 1.0;
    if (width >= r8) return 1.0;
    if (width >= r9) return 1.0;
    if (width >= r10) return 1.0;
    if (width >= r11) return 1.0;
    if (width >= r12) return 1.0;
    if (width >= r13) return 1.0;
    return 1.0;
  }

  static int gridColumnCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= r0) return 5;
    if (width >= r1) return 4;
    if (width >= r2) return 3;
    if (width >= r3) return 2;
    if (width >= r4) return 2;
    if (width >= r5) return 2;
    if (width >= r6) return 2;
    if (width >= r7) return 2;
    if (width >= r8) return 2;
    if (width >= r9) return 1;
    if (width >= r10) return 1;
    if (width >= r11) return 1;
    if (width >= r12) return 1;
    if (width >= r13) return 1;
    return 1;
  }
}

extension ResponsiveContext on BuildContext {
  double get gridAspectRatio => Responsive.gridAspectRatio(this);
  int get gridColumnCount => Responsive.gridColumnCount(this);
}
