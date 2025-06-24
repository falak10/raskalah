import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wastmanagement/NearestCenterPage.dart';
import 'package:wastmanagement/RewardManagementScreen.dart';
import 'package:wastmanagement/UserRewardsScreen.dart';
import 'package:wastmanagement/sharedbar.dart';

class UserHomePage extends StatefulWidget {
  @override
  State<UserHomePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserHomePage> {
  User? user = FirebaseAuth.instance.currentUser;
  int totalPoints = 0;
  List<String> recycleTypes = [
    'بلاستيك',
    'معادن',
    'زجاج',
    'كرتون',
    'ورق',
    'قمامة'
  ];
  Map<String, bool> selectedRecycles = {};

  String username = '';
  String email = '';
  int classificationCount = 0;
  Map<String, int> classificationsCount = {};
  int doneRequestCount = 0;

  @override
  void initState() {
    super.initState();
    loadUserData();
    countUserClassifications();
    countUserClassificationsByType();
    countDoneRequests();
    selectedRecycles = Map.fromIterable(recycleTypes,
        key: (item) => item, value: (item) => false);

    if (user != null) {
      FirebaseFirestore.instance
          .collection('requests')
          .where('sender_id', isEqualTo: user!.uid)
          .where('status', isEqualTo: 'done')
          .snapshots()
          .listen((snapshot) {
        int accumulatedPoints = 0;
        for (var doc in snapshot.docs) {
          accumulatedPoints += (doc.data()['points'] as int? ?? 0);
        }
        setState(() {
          totalPoints = accumulatedPoints;
        });
      });
    }
  }
  void countUserClassifications() {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    FirebaseFirestore.instance
        .collection('classifications')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .listen((snapshot) {
      int newCount = snapshot.docs.length;

      if (newCount != classificationCount) {
        setState(() {
          classificationCount = newCount;
        });
      }
    });
  }

 void countUserClassificationsByType() async {
  FirebaseFirestore.instance
      .collection('classifications')
      .where('user_id', isEqualTo: user?.uid)
      .snapshots()
      .listen((snapshot) {
        Map<String, int> localCounts = {};
        for (var doc in snapshot.docs) {

          var status = doc.data()['status'] as String?;
          if (status == null || status != 'done') {
            String type = doc.get('classification');
            if (type != null) {
              localCounts[type] = (localCounts[type] ?? 0) + 1;
            }
          }
        }
        if (!mounted) return;
        setState(() {
          classificationsCount = localCounts;
        });
      });
}

  Future<void> loadUserData() async {
    if (user != null) {
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        username = userData['name'];
        email = userData['email'];
      });
    }
  }

  final int step = 100;

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void countDoneRequests() {
    FirebaseFirestore.instance
        .collection('requests')
        .where('sender_id', isEqualTo: user!.uid)
        .where('status', isEqualTo: 'done')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        doneRequestCount = snapshot.docs.length;
      });
    });
  }

  void updateClassificationsAsPending() {
    selectedRecycles.forEach((type, isSelected) {
      if (isSelected) {
        FirebaseFirestore.instance
            .collection('classifications')
            .where('user_id', isEqualTo: user!.uid)
            .where('classification', isEqualTo: type)
            .get()
            .then((snapshot) {
          for (var doc in snapshot.docs) {
            var status = doc.data()['status'] as String?;
            if (status == null || status != 'done') {
              FirebaseFirestore.instance
                  .collection('classifications')
                  .doc(doc.id)
                  .update({'status': 'pending'});
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> recycleItems = [
      'بلاستيك',
      'معادن',
      'زجاج',
      'كرتون',
      'ورق',
      'قمامة'
    ];

    final Map<String, bool> selectedItems = Map.fromIterable(recycleItems,
        key: (item) => item, value: (item) => false);

    void showRecycleOptionsModal() {
      showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter modalState) {
                return Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text('اختر نوع النفايات للتصنيف:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      ...recycleTypes.map((type) {
                        return CheckboxListTile(
                          title: Text(type),
                          value: selectedRecycles[type],
                          onChanged: (bool? value) {
                            modalState(() {
                              selectedRecycles[type] = value!;
                            });
                          },
                        );
                      }).toList(),
                      ElevatedButton(
                        onPressed: () {
                          bool anySelected =
                              selectedRecycles.values.any((v) => v == true);
                          if (anySelected) {
                            updateClassificationsAsPending();
                            Navigator.pop(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NearestCenterPage()));
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text('رسكلها'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                );
              }),
            );
          });
    }

    Widget customSteppedProgressIndicator(int totalPoints) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: userRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            int pointsFromUsersThisDoc =
                snapshot.data?.data()?['points'] as int? ?? 0;
            int totalPointsNet = totalPoints - pointsFromUsersThisDoc;
            print(totalPointsNet);
            print('..................................');
            final int endPoint = totalPointsNet + 200;  
            final int numSteps = ((endPoint) / 100)
                .ceil();  

            List<Widget> steps = List.generate(
              numSteps,
              (index) {
                final int stepValue = index * 50;  
                final bool isReached =
                    stepValue <= totalPointsNet;  

                return Expanded(
                  child: Container(
                    height: 40,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width:
                              40, 
                          height:
                              40,  
                          decoration: BoxDecoration(
                            color: isReached ? Colors.green : Colors.grey[300]!,
                            borderRadius: BorderRadius.circular(
                                10),  
                          ),
                          child: Center(
                            child: Text(
                              stepValue.toString(),
                              style: TextStyle(
                                color: isReached ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نقاطك المتاحة للاستخدام:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),Text(
                    totalPointsNet.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width:
                        double.infinity,  
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: steps,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      );
    }

    final List<Map<String, dynamic>> wasteTypes = [
      {
        'icon': Icons.delete,
        'label': 'بلاستيك',
        'count': '20/50',
        'color': Colors.blue
      },
      {
        'icon': Icons.settings,
        'label': 'معادن',
        'count': '32/50',
        'color': Colors.grey
      },
      {
        'icon': Icons.broken_image,
        'label': 'زجاج',
        'count': '15/50',
        'color': Colors.green
      },
      {
        'icon': Icons.cut,
        'label': 'كرتون',
        'count': '45/50',
        'color': Colors.brown
      },
      {
        'icon': Icons.description,
        'label': 'ورق',
        'count': '28/50',
        'color': Colors.blueGrey
      },
      {
        'icon': Icons.delete_sweep,
        'label': 'قمامة',
        'count': '5/50',
        'color': Colors.red
      }
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
           flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              color: Colors.green,
            ),
          ),
          centerTitle: true,
          title:
              Text('مرحبا: ${username}', style: TextStyle(color: Colors.white)),
          leading: Container(),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    buildStatCard(
                        Icons.star, 'نقاطك', '$totalPoints', Colors.yellow),
                    buildStatCard(Icons.recycling, 'رسكلتك',
                        doneRequestCount.toString(), Colors.blue),
                    buildStatCard(Icons.qr_code_scanner, 'مسحاتك',
                        '$classificationCount', Colors.green),
                  ],
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(wasteTypes.length, (index) {
                      return Container(
                        width: 160,
                        padding: EdgeInsets.all(10),
                        child: Card(
                          color: wasteTypes[index]['color'],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(wasteTypes[index]['icon'],
                                  size: 50, color: Colors.white),
                              Text(wasteTypes[index]['label'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              Text(
                                  '${classificationsCount[wasteTypes[index]['label']] ?? 0}/50',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 15),
                customSteppedProgressIndicator(totalPoints),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () => showRecycleOptionsModal(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(double.infinity, 60),
                  ),
                  child: Text('رسكلها'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: totalPoints > 100
                      ? () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserRewardsScreen()));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: Size(double.infinity, 60),
                  ),
                  child: Text('استبدل نقاطك'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(
      IconData iconData, String label, String count, Color iconColor) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(iconData, size: 48, color: iconColor),
            SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text(count,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _onScan() {}
}

class StepProgressPainter extends CustomPainter {
  final Color color;
  final bool isReached;

  StepProgressPainter({required this.color, required this.isReached});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..style = isReached ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 16.0, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
