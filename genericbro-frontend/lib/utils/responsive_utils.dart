import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  static double getResponsiveFontSize(BuildContext context, {
    double baseFontSize = 16,
    double minFontSize = 14,
    double maxFontSize = 24
  }) {
    double screenWidth = getScreenWidth(context);
    double fontSize = baseFontSize * (screenWidth / 1440);
    return fontSize.clamp(minFontSize, maxFontSize);
  }

  static double getResponsiveImageSize(BuildContext context) {
    if (isMobile(context)) {
      return getScreenWidth(context) * 0.6;
    } else if (isTablet(context)) {
      return getScreenWidth(context) * 0.4;
    } else {
      return getScreenWidth(context) * 0.25;
    }
  }

  static double getResponsiveButtonWidth(BuildContext context) {
    if (isMobile(context)) {
      return getScreenWidth(context) * 0.8;
    } else if (isTablet(context)) {
      return getScreenWidth(context) * 0.5;
    } else {
      return getScreenWidth(context) * 0.3;
    }
  }
} 