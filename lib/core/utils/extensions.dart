import 'package:flutter/material.dart';

extension StringExtensions on String {
  String collapseWhitespace() => replaceAll(RegExp(r'\s+'), ' ').trim();
}

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colors => theme.colorScheme;

  MediaQueryData get mq => MediaQuery.of(this);

  Size get screenSize => mq.size;
}
