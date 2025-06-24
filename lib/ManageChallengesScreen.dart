import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:wastmanagement/AddChallengeScreen.dart';
import 'dart:ui' as ui;

import 'package:wastmanagement/EditChallengeScreen.dart';

class ManageChallengesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة التحديات'),
          centerTitle: true,
        ),
        body: ChallengesList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddChallengeScreen()),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ChallengesList extends StatelessWidget {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('challenges').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("خطأ: ${snapshot.error}"));
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final challengeData = documents[index].data() as Map<String, dynamic>;
            final title = challengeData['title'] ?? '';
            final startDate = dateFormat.format(DateTime.parse(challengeData['startDate'] ?? ''));
            final endDate = dateFormat.format(DateTime.parse(challengeData['endDate'] ?? ''));
            return ListTile(
              title: Text(title),
              subtitle: Text('تاريخ البداية: $startDate, تاريخ النهاية: $endDate'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditChallengeScreen(challengeId: documents[index].id,),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteConfirmationDialog(context, documents[index].id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String challengeId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('حذف التحدي'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('هل أنت متأكد من أنك تريد حذف هذا التحدي؟'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('حذف'),
              onPressed: () {
                _deleteChallenge(challengeId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteChallenge(String challengeId) {
    FirebaseFirestore.instance.collection('challenges').doc(challengeId).delete();
  }
}
