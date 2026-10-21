import 'package:flutter/material.dart';

/// Small helpers that keep the widgets free from repeated locale checks.
extension LocalizationContext on BuildContext {
  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  TextDirection get appTextDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// Returns [ar] when the device language is Arabic, otherwise [en].
  String tr(String ar, String en) => isArabic ? ar : en;
}
