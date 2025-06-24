
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardManagementScreen extends StatefulWidget {
  final String? rewardId;

  RewardManagementScreen({this.rewardId});

  @override
  _RewardManagementScreenState createState() => _RewardManagementScreenState();
}

class _RewardManagementScreenState extends State<RewardManagementScreen> {
  final _formKey = GlobalKey<FormState>();
 final _rewardNameController = TextEditingController(text: 'كوب قهوة ');
  final _locationController = TextEditingController(text: 'respire | تنفس');
  final _websiteController = TextEditingController(text: 'https://www.respire.sa');
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.rewardId != null) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    DocumentSnapshot rewardData = await FirebaseFirestore.instance.collection('rewards').doc(widget.rewardId).get();
    _rewardNameController.text = rewardData.get('name');
    _locationController.text = rewardData.get('location');
    _websiteController.text = rewardData.get('website');
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> rewardData = {
        'name': _rewardNameController.text.trim(),
        'location': _locationController.text.trim(),
        'website': _websiteController.text.trim(),
      };

      if (widget.rewardId == null) {
        await FirebaseFirestore.instance.collection('rewards').add(rewardData);
      } else {
        await FirebaseFirestore.instance.collection('rewards').doc(widget.rewardId).update(rewardData);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم حفظ المكافأة بنجاح!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في حفظ المكافأة')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.rewardId == null ? 'إضافة مكافأة' : 'تعديل المكافأة'),
          backgroundColor: Colors.green,
        ),
        body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _rewardNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المكافأة',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.card_giftcard),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'يرجى إدخال اسم المكافأة';
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'الموقع',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'يرجى إدخال الموقع';
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _websiteController,
                      decoration: InputDecoration(
                        labelText: 'الموقع الإلكتروني',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.web),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'يرجى إدخال الموقع الإلكتروني';
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('حفظ المكافأة'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green, 
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    );
  }
}
 
class RewardsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('قائمة المكافآت'),
          backgroundColor: Colors.green,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('rewards').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                return ListTile(
                  title: Text(doc['name']),
                  subtitle: Text(doc['location']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RewardManagementScreen(rewardId: doc.id))),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => doc.reference.delete(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RewardManagementScreen())),
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}
