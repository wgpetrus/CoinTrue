import 'package:flutter/material.dart';

/// Helper class for responsive design
/// 
/// Provides utilities to adjust UI based on screen size and device type.
/// Helps create layouts that work well on different Android screen sizes
/// (phones, tablets, foldables) and iOS devices (iPhone, iPad).
/// 
/// Validates: Requirements 9.5
class ResponsiveHelper {
  /// Private constructor to prevent instantiation
  ResponsiveHelper._();

  /// Breakpoints for different device sizes
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Returns true if the screen width is considered mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Returns true if the screen width is considered tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  /// Returns true if the screen width is considered desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Returns the appropriate horizontal padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    if (isDesktop(context)) return 80.0;
    if (isTablet(context)) return 40.0;
    return 20.0;
  }

  /// Returns the appropriate vertical padding based on screen size
  static double getVerticalPadding(BuildContext context) {
    if (isDesktop(context)) return 40.0;
    if (isTablet(context)) return 32.0;
    return 24.0;
  }

  /// Returns the appropriate logo size based on screen size
  static double getLogoSize(BuildContext context) {
    if (isDesktop(context)) return 240.0;
    if (isTablet(context)) return 220.0;
    return 180.0;
  }

  /// Returns the appropriate icon size based on screen size
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    if (isDesktop(context)) return baseSize * 1.2;
    if (isTablet(context)) return baseSize * 1.1;
    return baseSize;
  }

  /// Returns the appropriate font size based on screen size
  static double getFontSize(BuildContext context, {double baseSize = 16.0}) {
    if (isDesktop(context)) return baseSize * 1.1;
    if (isTablet(context)) return baseSize * 1.05;
    return baseSize;
  }

  /// Returns the appropriate button height based on screen size
  static double getButtonHeight(BuildContext context) {
    if (isDesktop(context)) return 60.0;
    if (isTablet(context)) return 58.0;
    return 56.0;
  }

  /// Returns the appropriate spacing between elements
  static double getSpacing(BuildContext context, {double baseSpacing = 16.0}) {
    if (isDesktop(context)) return baseSpacing * 1.5;
    if (isTablet(context)) return baseSpacing * 1.25;
    return baseSpacing;
  }

  /// Returns the number of columns for grid layouts
  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  /// Returns the appropriate max width for content
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1200.0;
    if (isTablet(context)) return 800.0;
    return double.infinity;
  }

  /// Returns true if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns true if the device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Returns the screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Returns the screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Returns the safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Returns true if the device has a notch or cutout
  static bool hasNotch(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top > 24; // Typical status bar height
  }

  /// Returns the appropriate card elevation based on screen size
  static double getCardElevation(BuildContext context) {
    if (isDesktop(context)) return 4.0;
    if (isTablet(context)) return 2.0;
    return 0.0; // Flat design for mobile
  }

  /// Returns the appropriate border radius based on screen size
  static double getBorderRadius(BuildContext context, {double baseRadius = 16.0}) {
    if (isDesktop(context)) return baseRadius * 1.25;
    if (isTablet(context)) return baseRadius * 1.1;
    return baseRadius;
  }

  /// Wraps content with appropriate constraints for responsive design
  static Widget wrapWithConstraints(
    BuildContext context,
    Widget child, {
    bool centerContent = true,
  }) {
    final maxWidth = getMaxContentWidth(context);
    
    if (maxWidth == double.infinity) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }

  /// Returns appropriate text scale factor
  static double getTextScaleFactor(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    // Limit text scale factor to prevent UI breaking
    return textScaleFactor.clamp(0.8, 1.3);
  }

  /// Returns true if the device is a small phone (< 360dp width)
  static bool isSmallPhone(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  /// Returns true if the device is a large phone (> 400dp width)
  static bool isLargePhone(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 400 && width < mobileBreakpoint;
  }
}
