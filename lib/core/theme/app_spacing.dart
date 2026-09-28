import 'package:flutter/material.dart';

/// Spacing, Padding, and Radius constants for consistent responsive layouts.
class AppSpacing {
  AppSpacing._();

  // Spacing scales
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double hero = 48.0;

  // Responsive Breakpoints
  static const double tabletBreakpoint = 720.0;
  static const double desktopBreakpoint = 1024.0;

  // Corner Radii
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(radiusPill));

  // Elevations
  static const double elevationLow = 1.0;
  static const double elevationMed = 3.0;
  static const double elevationHigh = 6.0;
}
