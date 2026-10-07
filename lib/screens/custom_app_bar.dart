import 'package:flutter/material.dart';

const primaryGreen = Color(0xFF134D3F);

AppBar buildAppBar({
  required String title,
  Color backgroundColor = const Color(0xFFEEF4F6),
  List<Widget>? actions,
  Widget? leading,
  bool centerTitle = true,
}) {
  return AppBar(
    backgroundColor: backgroundColor,
    elevation: 0,
    centerTitle: centerTitle,
    iconTheme: const IconThemeData(color: Colors.black),
    leading: leading,
    actions: actions,
    title: Text(
      title,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}