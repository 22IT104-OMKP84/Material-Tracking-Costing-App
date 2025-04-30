import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_material_tracker/providers/auth_provider.dart';
import 'package:smartfab_material_tracker/screens/inventory/material_list_screen.dart';
import 'package:smartfab_material_tracker/screens/tasks/task_list_screen.dart';
import 'package:smartfab_material_tracker/screens/inventory/material_scanner.dart';

class OperatorDashboard extends StatefulWidget {
  const OperatorDashboard({super.key});

  @override
  State<OperatorDashboard> createState() => _OperatorDashboardState();
}

class _OperatorDashboardState extends State<OperatorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    MaterialListScreen(),
    TaskListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartFab Material Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.task),
            label: 'Tasks',
          ),
        ],
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5, // TODO: Replace with actual task count
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text('${index + 1}'),
            ),
            title: Text('Task ${index + 1}'),
            subtitle: Text('Material: Sample Material ${index + 1}'),
            trailing: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MaterialScanner(),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
} 