import 'package:flutter/material.dart';
import 'admin/dashboard_screen.dart';
import 'operator/scan_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _roleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SmartFab Login")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _roleController,
              decoration: InputDecoration(
                labelText: "Enter role (admin/operator)",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Login"),
              onPressed: () {
                final role = _roleController.text.toLowerCase();
                if (role == 'admin') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DashboardScreen()),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ScanScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
