import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/material.dart';

class InventoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'materials';

  Future<List<Material>> getMaterials() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => Material.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      debugPrint('Error getting materials: $e');
      return [];
    }
  }

  Future<void> updateMaterial(String id, Material material) async {
    try {
      await _firestore.collection(_collection).doc(id).update(material.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating material: $e');
      rethrow;
    }
  }

  Future<void> addMaterial(Material material) async {
    try {
      await _firestore.collection(_collection).add(material.toMap());
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding material: $e');
      rethrow;
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting material: $e');
      rethrow;
    }
  }
} 