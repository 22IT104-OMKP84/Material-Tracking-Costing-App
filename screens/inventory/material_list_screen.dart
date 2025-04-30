import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_material_tracker/providers/inventory_provider.dart';
import 'package:smartfab_material_tracker/models/material.dart' as app_material;

class MaterialListScreen extends StatefulWidget {
  const MaterialListScreen({super.key});

  @override
  State<MaterialListScreen> createState() => _MaterialListScreenState();
}

class _MaterialListScreenState extends State<MaterialListScreen> {
  final _searchController = TextEditingController();
  String _filter = 'all';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<InventoryProvider>(context, listen: false).loadMaterials();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading materials: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<app_material.Material> _getFilteredMaterials() {
    final inventoryProvider = Provider.of<InventoryProvider>(context);
    var materials = inventoryProvider.materials;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      materials = materials.where((material) {
        return material.name.toLowerCase().contains(searchTerm) ||
            material.description.toLowerCase().contains(searchTerm);
      }).toList();
    }

    // Apply stock level filter
    switch (_filter) {
      case 'low':
        materials = materials.where((material) {
          return material.currentStock <= material.minStock;
        }).toList();
        break;
      case 'medium':
        materials = materials.where((material) {
          return material.currentStock > material.minStock &&
              material.currentStock < material.maxStock * 0.7;
        }).toList();
        break;
      case 'high':
        materials = materials.where((material) {
          return material.currentStock >= material.maxStock * 0.7;
        }).toList();
        break;
    }

    return materials;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final materials = _getFilteredMaterials();

    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search materials...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text('All'),
                    ),
                    DropdownMenuItem(
                      value: 'low',
                      child: Text('Low Stock'),
                    ),
                    DropdownMenuItem(
                      value: 'medium',
                      child: Text('Medium Stock'),
                    ),
                    DropdownMenuItem(
                      value: 'high',
                      child: Text('High Stock'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filter = value!;
                    });
                  },
                ),
              ],
            ),
          ),

          // Material List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMaterials,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final material = materials[index];
                        return MaterialCard(material: material);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add material dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class MaterialCard extends StatelessWidget {
  final app_material.Material material;

  const MaterialCard({
    super.key,
    required this.material,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = material.currentStock / material.maxStock;
    final isLowStock = material.currentStock <= material.minStock;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          // TODO: Show material details
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      material.name,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  if (isLowStock)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Low Stock',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                material.description,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  isLowStock
                      ? Colors.red
                      : progress > 0.7
                          ? Colors.green
                          : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${material.currentStock} ${material.unit}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    '${material.costPerUnit.toStringAsFixed(2)}/unit',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 