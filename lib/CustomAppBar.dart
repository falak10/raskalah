 import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onBackTap;

  CustomAppBar({
    required this.title,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          color: Colors.green,
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: onBackTap,
      ),
      actions: [],
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(100.0);
}
