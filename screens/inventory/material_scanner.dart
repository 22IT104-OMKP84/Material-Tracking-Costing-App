import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smartfab_material_tracker/providers/inventory_provider.dart';
import 'package:smartfab_material_tracker/models/material.dart';

class MaterialScanner extends StatefulWidget {
  const MaterialScanner({super.key});

  @override
  State<MaterialScanner> createState() => _MaterialScannerState();
}

class _MaterialScannerState extends State<MaterialScanner> {
  String _scanResult = 'Not Scanned';
  bool _isLoading = false;
  Material? _scannedMaterial;

  Future<void> _scanBarcode() async {
    setState(() {
      _isLoading = true;
      _scannedMaterial = null;
    });

    try {
      final result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Line color
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.BARCODE, // Scan mode
      );

      if (!mounted) return;

      if (result == '-1') {
        setState(() {
          _scanResult = 'Scan cancelled';
          _isLoading = false;
        });
      } else {
        setState(() {
          _scanResult = result;
        });
        
        // Search for the material in the inventory provider
        final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
        final materials = await inventoryProvider.getMaterials();
        final material = materials.firstWhere(
          (m) => m.barcode == result,
          orElse: () => null,
        );
        
        if (!mounted) return;
        
        if (material != null) {
          setState(() {
            _scannedMaterial = material;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scanning: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Material'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _scanBarcode,
                child: const Text('Scan Barcode'),
              ),
            const SizedBox(height: 20),
            Text(
              'Scan Result: $_scanResult',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_scannedMaterial != null) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _scannedMaterial!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Barcode: ${_scannedMaterial!.barcode}'),
                      Text('Quantity: ${_scannedMaterial!.quantity}'),
                      Text('Unit: ${_scannedMaterial!.unit}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => MaterialDetailsDialog(
                              materialId: _scannedMaterial!.id,
                              onUpdate: (quantity) async {
                                final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
                                await inventoryProvider.updateMaterial(
                                  _scannedMaterial!.id,
                                  _scannedMaterial!.copyWith(quantity: quantity),
                                );
                                Navigator.of(context).pop();
                              },
                            ),
                          );
                        },
                        child: const Text('Update Stock'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MaterialDetailsDialog extends StatefulWidget {
  final String materialId;
  final Function(double) onUpdate;

  const MaterialDetailsDialog({
    super.key,
    required this.materialId,
    required this.onUpdate,
  });

  @override
  State<MaterialDetailsDialog> createState() => _MaterialDetailsDialogState();
}

class _MaterialDetailsDialogState extends State<MaterialDetailsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
      });

      final quantity = double.parse(_quantityController.text);
      await widget.onUpdate(quantity);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating material: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Material Stock'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity used',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid quantity';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _handleUpdate,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }
} 