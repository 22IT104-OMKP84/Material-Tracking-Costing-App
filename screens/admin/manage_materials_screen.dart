import 'package:flutter/material.dart';
import '../../widgets/material_tile.dart';

class ManageMaterialsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> dummyMaterials = [
    {"name": "Steel", "unitCost": 10.0, "stock": 100},
    {"name": "Plastic", "unitCost": 5.0, "stock": 50},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Materials")),
      body: ListView(
        children: dummyMaterials.map((m) => MaterialTile(material: m)).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add Material
        child: Icon(Icons.add),
      ),
    );
  }
}
