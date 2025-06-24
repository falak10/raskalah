import 'package:flutter/material.dart';
import 'package:wastmanagement/sharedbar.dart'; 


class SomeOtherPage extends StatefulWidget {
  @override
  _SomeOtherPageState createState() => _SomeOtherPageState();
}

class _SomeOtherPageState extends State<SomeOtherPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

  }

  void _onScan() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

      ),
      body: Center(

      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onScan,
        child: Icon(Icons.camera_alt),
        tooltip: 'Scan',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
