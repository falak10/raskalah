import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  CustomBottomNavigationBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: 'تحدياتنا',
          ),
         
         
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'الترتيب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'الحساب',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        iconSize: 30,  
        selectedLabelStyle: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.w600,  
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,  
        ),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,  
      ),
    );
  }
}
