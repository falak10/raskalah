import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wastmanagement/home.dart';
import 'package:wastmanagement/main_page.dart';

class UserRewardsScreen extends StatefulWidget {
  @override
  _UserRewardsScreenState createState() => _UserRewardsScreenState();
}

class _UserRewardsScreenState extends State<UserRewardsScreen> {
  final Stream<QuerySnapshot> _rewardsStream = FirebaseFirestore.instance.collection('rewards').snapshots();

  void _showConfirmationDialog(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد المكافأة', textAlign: TextAlign.center),
          content: Text('تأكد أنك في موقع استلام المكافأة قبل التأكيد... سنعرض كود الخصم ولمدة دقيقتين عند التأكيد', textAlign: TextAlign.right),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('تأكيد'),
              onPressed: () {
                Navigator.of(context).pop();
                _openRewardTimerDialog(reward);
              },
            ),
          ],
        );
      },
    );
  }

  void _openRewardTimerDialog(Map<String, dynamic> reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RewardTimerDialog(reward: reward);
      },
    );
  }

   void _handleBackNavigation(BuildContext context) {

    Navigator.of(context).pop();


    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainScreen()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المكافآت المتاحة'),
          backgroundColor: Colors.green,
          centerTitle: true,
          leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => _handleBackNavigation(context),
        ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _rewardsStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('حدث خطأ');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>? ?? {};
                return ListTile(
                  title: Text(data['name'] ?? 'No name provided', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${data['location'] ?? 'No location'} | ${data['website'] ?? 'No website'}'),
                  onTap: () => _checkAndOpenDialog(data),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  void _checkAndOpenDialog(Map<String, dynamic> reward) async {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
  final requestsRef = FirebaseFirestore.instance.collection('requests');

  final querySnapshot = await requestsRef.where('sender_id', isEqualTo: userId).get();
  int totalOfPointsFromRequests = querySnapshot.docs.fold(0, (total, doc) => total + (doc.data()['points'] as int? ?? 0));

  final userSnapshot = await userRef.get();
  int pointsFromUsersThisDoc = userSnapshot.data()?['points'] as int? ?? 0;

  final result = totalOfPointsFromRequests - pointsFromUsersThisDoc;

  if (result >= 100) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد المكافأة', textAlign: TextAlign.center),
          content: Text('تاكد انك في موقع استلام المكافأة قبل التاكيد… بنعرض كود الخصم ولمدة دقيقتين عند التاكيد',textAlign: TextAlign.right,),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('تأكيد'),
              onPressed: () {
                Navigator.of(context).pop();
                _openRewardTimerDialog(reward);
              },
            ),
          ],
        );
      },
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ليس لديك نقاط كافية')));
  }
}

}

class RewardTimerDialog extends StatefulWidget {
  final Map<String, dynamic> reward;

  RewardTimerDialog({required this.reward});

  @override
  _RewardTimerDialogState createState() => _RewardTimerDialogState();
}

class _RewardTimerDialogState extends State<RewardTimerDialog> {
  late Timer _timer;
  int _remainingSeconds = 120;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          _addPointsAndClose();
        }
      });
    });
  }

 

void _addPointsAndClose() {
  final userRef = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid);

  FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentSnapshot snapshot = await transaction.get(userRef);
    Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>? ?? {};
    
    int currentPoints = userData.containsKey('points') ? userData['points'] as int : 0;

    transaction.update(userRef, {'points': currentPoints + 100});
  }).then((result) {
    Navigator.of(context).pop();
  }).catchError((error) {
    print("Failed to update points: $error");
  });
}

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('مبروك! لقد حصلت على المكافأة من ${widget.reward['location']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),textAlign: TextAlign.right,),
            SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: (_remainingSeconds / 120.0),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    backgroundColor: Colors.green[100],
                    strokeWidth: 10,
                  ),
                ),
                Text('${_remainingSeconds}s', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                _timer.cancel();
                _addPointsAndClose();
              },
              child: Text('إلغاء', style: TextStyle(color: Colors.red, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
