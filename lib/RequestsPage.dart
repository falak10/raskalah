import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('طلبات الزيارة'),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('requests')
              .where('center_id',
                  isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(child: Text("حدث خطأ في جلب البيانات!"));
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text("لا يوجد طلبات"));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot requestDoc = snapshot.data!.docs[index];
                bool isDone = requestDoc['status'] == 'done';

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(requestDoc['sender_id'])
                      .get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return ListTile(
                        title: Text("جاري تحميل بيانات المستخدم..."),
                        subtitle: LinearProgressIndicator(),
                      );
                    }

                    if (!userSnapshot.hasData) {
                      return ListTile(
                        title: Text("معلومات المستخدم غير متوفرة"),
                      );
                    }

                    Map<String, dynamic> userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: isDone
                              ? Colors.green
                              : Theme.of(context).primaryColor,
                          child: Text(userData['name'] ?? '?',
                              style: TextStyle(color: Colors.white)),
                        ),
                        title: Text(
                          userData['name'] ?? 'اسم غير متوفر',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                            'البريد الإلكتروني: ${userData['email'] ?? 'غير متوفر'}\n'
                            'الهاتف: ${userData['phone'] ?? 'غير متوفر'}',
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.6))),
                        trailing: isDone
                            ? Icon(Icons.check, color: Colors.green, size: 24)
                            : Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => showUserDetailDialog(context, userData,
                            requestDoc['sender_id'], requestDoc.id),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void showUserDetailDialog(BuildContext context, Map<String, dynamic> userData,
      String userId, String requestId) {
    Map<String, TextEditingController> weightControllers = {};
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(userData['name'] ?? 'اسم غير متوفر',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          content: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('classifications')
                .where('user_id', isEqualTo: userId)
                .where('status', isEqualTo: 'pending')
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text("Error fetching data");
              }
              if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                return Text("لا توجد سجلات");
              }
              Map<String, int> classificationsCount = {};
              snapshot.data!.docs.forEach((doc) {
                String type = doc['classification'];
                classificationsCount[type] =
                    (classificationsCount[type] ?? 0) + 1;
                weightControllers[type] =
                    TextEditingController(); 

              });

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Email: ${userData['email'] ?? 'غير متوفر'}',
                        style: TextStyle(color: Colors.black)),
                    Text('Phone: ${userData['phone'] ?? 'غير متوفر'}',
                        style: TextStyle(color: Colors.black)),
                    Divider(),
                    ...classificationsCount.entries.map((e) {
                      return Row(
                        children: <Widget>[
                          Expanded(
                              child: Text('${e.key}: ${e.value} وحدة',
                                  style: TextStyle(color: Colors.blueGrey))),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: weightControllers[e.key],
                              decoration: InputDecoration(labelText: 'Kg'),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('قبول الكمية'),
              onPressed: () {
                if (validateInputs(weightControllers)) {
                  acceptClassifications(userId, requestId, weightControllers);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('قم بملئ الاوزان لكل نوع')));
                }
              },
            ),
            TextButton(
              child: Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool validateInputs(Map<String, TextEditingController> controllers) {
    for (var controller in controllers.values) {
      if (controller.text.isEmpty || double.tryParse(controller.text) == null) {
        return false;
      }
    }
    return true;
  }

  void acceptClassifications(String userId, String requestId,
      Map<String, TextEditingController> weightControllers) {
    double totalWeight = 0.0;  
    int totalPoints =
        0;  
    Map<String, int> pointsPerKg = {
      'بلاستيك': 5,
      'معادن': 3,
      'زجاج': 3,
      'كرتون': 5,
      'ورق': 6,
      'قمامة': 1
    };

     weightControllers.forEach((type, controller) {
      double weight = double.tryParse(controller.text) ?? 0.0;
      if (weight > 0) {
        totalWeight += weight;  
        totalPoints +=
            (weight * (pointsPerKg[type] ?? 0)).toInt();  
      }
    });

    if (totalPoints > 0) {

      FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({'status': 'done', 'points': totalPoints});


      FirebaseFirestore.instance
          .collection('classifications')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get()
          .then((QuerySnapshot classificationSnapshot) {
        for (var doc in classificationSnapshot.docs) {
          doc.reference.update({'status': 'done'});
        }
      });

     var cusid =  FirebaseAuth.instance.currentUser?.uid;
      FirebaseFirestore.instance
          .collection('users')
          .doc(cusid)
          .get()
          .then((DocumentSnapshot userDoc) {
        if (userDoc.exists) {
          double existingWeight = (userDoc.data()
                  as Map<String, dynamic>)['total_weight_accepted'] ??
              0.0;
          FirebaseFirestore.instance
              .collection('users')
              .doc(cusid)
              .update({'total_weight_accepted': existingWeight + totalWeight});
        }
      });
    }
  }
}
