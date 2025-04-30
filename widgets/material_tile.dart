import 'package:flutter/material.dart';

class MaterialTile extends StatelessWidget {
  final Map<String, dynamic> material;
  MaterialTile({required this.material});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        title: Text(material['name']),
        subtitle: Text(
          "Cost: ₹${material['unitCost']} | Stock: ${material['stock']}",
        ),
        trailing: Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
