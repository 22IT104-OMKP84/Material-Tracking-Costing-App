import 'package:flutter/material.dart';
import 'manage_materials_screen.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Dashboard")),
      body: ListView(
        children: [
          ListTile(
            title: Text("Manage Materials"),
            trailing: Icon(Icons.edit),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ManageMaterialsScreen()),
                ),
          ),
          ListTile(
            title: Text("View Reports"),
            trailing: Icon(Icons.analytics),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
