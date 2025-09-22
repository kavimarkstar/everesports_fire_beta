import 'package:flutter/material.dart';

// Consistent breakpoints across the app
class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1200;
}

// Device type detection
bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < ResponsiveBreakpoints.mobile;

bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= ResponsiveBreakpoints.mobile &&
    MediaQuery.of(context).size.width < ResponsiveBreakpoints.tablet;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= ResponsiveBreakpoints.tablet;

// Screen size helpers
double getScreenWidth(BuildContext context) =>
    MediaQuery.of(context).size.width;
double getScreenHeight(BuildContext context) =>
    MediaQuery.of(context).size.height;

// Responsive padding
EdgeInsets getResponsivePadding(BuildContext context) {
  if (isMobile(context)) {
    return const EdgeInsets.all(16);
  } else if (isTablet(context)) {
    return const EdgeInsets.all(24);
  } else {
    return const EdgeInsets.all(32);
  }
}

// Responsive spacing
double getResponsiveSpacing(BuildContext context) {
  if (isMobile(context)) {
    return 8;
  } else if (isTablet(context)) {
    return 12;
  } else {
    return 16;
  }
}

// Responsive font sizes
double getResponsiveFontSize(
  BuildContext context, {
  double mobile = 14,
  double tablet = 16,
  double desktop = 18,
}) {
  if (isMobile(context)) {
    return mobile;
  } else if (isTablet(context)) {
    return tablet;
  } else {
    return desktop;
  }
}

// Responsive card width
double getResponsiveCardWidth(BuildContext context) {
  if (isMobile(context)) {
    return getScreenWidth(context) * 0.9;
  } else if (isTablet(context)) {
    return getScreenWidth(context) * 0.7;
  } else {
    return getScreenWidth(context) * 0.5;
  }
}

// Responsive image height
double getResponsiveImageHeight(BuildContext context) {
  if (isMobile(context)) {
    return MediaQuery.of(context).size.width * 0.91;
  } else if (isTablet(context)) {
    return MediaQuery.of(context).size.width * 0.8;
  } else {
    return MediaQuery.of(context).size.width * 0.3;
  }
}

// Device orientation
bool isPortrait(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.portrait;

bool isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;
