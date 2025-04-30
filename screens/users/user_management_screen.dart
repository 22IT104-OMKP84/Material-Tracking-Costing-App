import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_material_tracker/providers/auth_provider.dart' as app_auth;
import 'package:smartfab_material_tracker/screens/users/add_user_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _updateUserRole(String userId, String role) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'role': role});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user role: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      // Delete user from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      
      // Delete user from Firebase Auth (only if it's not the current user)
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser?.uid != userId) {
        // Note: Deleting users from Firebase Auth requires admin privileges
        // This should be handled by a Cloud Function or backend service
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User data deleted from Firestore. Firebase Auth deletion requires admin privileges.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<app_auth.AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search users',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data!.docs.where((doc) {
                  final email = doc['email'] as String;
                  final searchQuery = _searchController.text.toLowerCase();
                  return email.toLowerCase().contains(searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user['email']),
                      subtitle: Text('Role: ${user['role']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _updateUserRole(user.id, user['role']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteUser(user.id),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddUserDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
} 