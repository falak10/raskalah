


 import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PointsDisplayScreen extends StatefulWidget {
  @override
  _PointsDisplayScreenState createState() => _PointsDisplayScreenState();
}

class _PointsDisplayScreenState extends State<PointsDisplayScreen> {
  late Future<List<UserPoints>> userPoints;

  @override
  void initState() {
    super.initState();
    userPoints = fetchUserPoints();
  }

Future<List<UserPoints>> fetchUserPoints() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('requests').get();
  Map<String, int> pointsMap = {};
  Map<String, String> namesMap = {};

   for (var doc in querySnapshot.docs) {
    var data = doc.data() as Map<String, dynamic>?; 
    if (data == null) continue; 
    String userId = data.containsKey('sender_id') && data['sender_id'] != null ? data['sender_id'] as String : 'unknown';
    int points = data['points'] is int ? data['points'] as int : 0; 

    if (pointsMap.containsKey(userId)) {
      pointsMap[userId] = (pointsMap[userId] ?? 0) + points;   
    } else {
      pointsMap[userId] = points;
    }
  }

   for (var userId in pointsMap.keys) {
    var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    var userData = userDoc.data() as Map<String, dynamic>?;
    String userName = userData != null && userData['name'] != null ? userData['name'] as String : 'Unknown User';
    namesMap[userId] = userName;
  }

   List<UserPoints> userPoints = [];
  pointsMap.forEach((userId, points) {
    String userName = namesMap[userId] ?? 'Unknown User';   
    userPoints.add(UserPoints(userId: userId, points: points, name: userName));
  });

   userPoints.sort((a, b) => b.points.compareTo(a.points));
  return userPoints;
}

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text("الترتيب", textAlign: TextAlign.center),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        body: FutureBuilder<List<UserPoints>>(
          future: userPoints,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("خطأ: ${snapshot.error}"));
            }

            final pointsList = snapshot.data!;
            return ListView.separated(
              itemCount: pointsList.length,
              separatorBuilder: (_, __) => Divider(height: 2, color: Colors.grey[300]),
              itemBuilder: (context, index) {
                final userPoints = pointsList[index];
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: index < 3 ? [Colors.yellow[700]!, Colors.amber[800]!] : [Colors.white, Colors.grey[100]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 3,
                        spreadRadius: 2,
                        offset: Offset(2, 2),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index == 0 ? Colors.green : Colors.grey[400],
                      child: Text("${index + 1}", style: TextStyle(color: Colors.white)),
                    ),
                    title: Text(userPoints.name, style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text("النقاط: ${userPoints.points}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class UserPoints {
  final String userId;
  final int points;
  final String name;

  UserPoints({required this.userId, required this.points, required this.name});
}

