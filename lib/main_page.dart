import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wastmanagement/ChallengePageView.dart';
import 'package:wastmanagement/PersonalPage.dart';
import 'package:wastmanagement/PointsDisplayScreen.dart';
import 'package:wastmanagement/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';  

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  PageController _pageController = PageController();
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _imagePath;

  final Map<String, String> classificationMap = {
    'plastic': 'بلاستيك',
    'metal': 'معادن',
    'glass': 'زجاج',
    'cardboard': 'كرتون',
    'paper': 'ورق',
    'trash': 'قمامة'
  };

  void _classifyImage() async {
    final uri = Uri.parse('http://10.0.2.2:5000/predict');
    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        _imagePath!,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = jsonDecode(responseString);
      var prediction = jsonResponse['prediction'];
      var translatedPrediction = classificationMap[prediction] ??
          'غير معروف';  

      _showResultDialog(translatedPrediction);
    } else {}
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  Future<void> _onScan() async {
    final ImageSource? source = await _showImageSourceDialog();
    if (source != null) {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _isLoading = true;  
          _imagePath = image.path;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _isLoading = false;  
          });
          _showImageOptionsDialog();
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('كاميرا', textAlign: TextAlign.right),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('معرض الصور', textAlign: TextAlign.right),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('هل ترغب في رسكلة هذه الصورة؟', textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      height: 300, 
                      child: Image.file(File(_imagePath!)),
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _classifyImage();  
                },
                child: Text('صنفها'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _onScan();  
                },
                child: Text('اختر صورة أخرى'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClassification(String classification) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('classifications').add({
          'user_id': currentUser.uid,
          'classification': classification,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حفظ التصنيف',textAlign: TextAlign.right,),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء حفظ التصنيف'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('المستخدم غير مسجل الدخول'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showManualClassificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedClassification;
        return AlertDialog(
          title: Text('صنفها يدوياً', textAlign: TextAlign.right),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    for (var entry in classificationMap.entries)
                      RadioListTile<String>(
                        title: Text(entry.value, textAlign: TextAlign.right,),
                        value: entry.key,
                        groupValue: selectedClassification,
                        onChanged: (value) {
                          setState(() => selectedClassification = value);
                        },
                      ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('اعتمد التصنيف'),
              onPressed: () {
                Navigator.of(context).pop();
                if (selectedClassification != null) {
                  String classificationLabel =
                      classificationMap[selectedClassification] ?? 'غير معروف';
                  _confirmClassification(classificationLabel);
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
  void _showResultDialog(String prediction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('نتيجة التصنيف', textAlign: TextAlign.right),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('التصنيف: $prediction', textAlign: TextAlign.right),
              SizedBox(height: 20),
              _imagePath == null
                  ? Container()
                  : Image.file(File(_imagePath!), height: 300),
              SizedBox(height: 20),
              Text(
                "قد يكون التصنيف خاطئًا بسبب عدة عوامل مثل جودة الصورة، إضاءتها، أو تداخل العناصر في الصورة. يُرجى التأكد من أن الصورة واضحة وتُظهر العنصر المُراد تصنيفه بشكل جلي.",
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('اعتمد التصنيف'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _confirmClassification(prediction);
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color.fromARGB(255, 255, 255, 255),
                  backgroundColor: Color.fromARGB(255, 8, 185, 52),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('صنفها يدوياً'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _showManualClassificationDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _onScan();
                },
                child: Text('إعادة المسح'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          UserHomePage(),
          ChallengePageView(),
          PointsDisplayScreen(),
          PersonalPage(),
        ],
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onScan,
        child: Icon(Icons.camera_alt),
        tooltip: 'Scan',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: SharedBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class SharedBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  SharedBottomNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'تحدياتنا'),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_numbered), label: 'الترتيب'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'الحساب'),
        ],
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
        selectedLabelStyle:
            TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14),
        showUnselectedLabels: true,
      ),
    );
  }
}
