class Material {
  final String id;
  final String name;
  final String barcode;
  final double quantity;
  final String unit;
  final double unitCost;

  Material({
    required this.id,
    required this.name,
    required this.barcode,
    required this.quantity,
    required this.unit,
    required this.unitCost,
  });

  Material copyWith({
    String? id,
    String? name,
    String? barcode,
    double? quantity,
    String? unit,
    double? unitCost,
  }) {
    return Material(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'quantity': quantity,
      'unit': unit,
      'unitCost': unitCost,
    };
  }

  factory Material.fromMap(Map<String, dynamic> map) {
    return Material(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      barcode: map['barcode'] ?? '',
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      unitCost: map['unitCost']?.toDouble() ?? 0.0,
    );
  }
} 