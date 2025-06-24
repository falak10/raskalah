import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersScreen extends StatefulWidget {
  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _selectedUserType = 'All';
  late Stream<QuerySnapshot> _usersStream;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateUserStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المستخدمين'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchField(),
          _buildFilterDropdown(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'ابحث بواسطة اسم المستخدم',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          _updateUserStream();
        },
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedUserType,
        onChanged: (String? newValue) {
          setState(() {
            _selectedUserType = newValue!;
            _updateUserStream();
          });
        },
        items: ['All', 'user', 'recycling_center']
            .map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                ))
            .toList(),
      ),
    );
  }

Stream<QuerySnapshot> _getUserStreamByTypeAndSearch(String type, String? searchQuery) {
  CollectionReference usersRef = FirebaseFirestore.instance.collection('users');
  Query query = usersRef;

   query = query.where('type', isNotEqualTo: 'admin');

  if (type != 'All') {
    query = query.where('type', isEqualTo: type);
  }
  if (searchQuery != null && searchQuery.isNotEmpty) {
    query = query.where('name', isGreaterThanOrEqualTo: searchQuery)
                 .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
  }

  return query.snapshots();
}

  void _updateUserStream() {
    setState(() {
      _usersStream = _getUserStreamByTypeAndSearch(_selectedUserType, _searchController.text);
    });
  }

  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('حدث خطأ');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data() as Map<String, dynamic>;
            String username = data['name'] ?? ''; 
            String email = data['email'] ?? '';  
            String userType = data['type'] ?? '';  
            return ListTile(
              title: Text(username),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email),
                  Text('نوع المستخدم: $userType'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _showDeleteConfirmation(context, document.id, username),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String userId, String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد أنك تريد حذف المستخدم $username؟'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                _deleteUser(userId);
                Navigator.of(context).pop();
                _showDeleteSuccessMessage(context, username);
              },
              child: Text('حذف'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).delete().then((value) {
     }).catchError((error) {
     });
  }

  void _showDeleteSuccessMessage(BuildContext context, String username) {
    final snackBar = SnackBar(
      content: Text('تم حذف المستخدم $username بنجاح'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
