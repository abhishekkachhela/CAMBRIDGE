// inventory_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> deductInventory(String itemID, int quantity) async {
    try {
      return await _firestore.runTransaction<bool>((transaction) async {
        DocumentReference itemRef = _firestore.collection("items").doc(itemID);
        DocumentSnapshot itemSnapshot = await transaction.get(itemRef);

        if (!itemSnapshot.exists) {
          throw Exception("Item not found");
        }

        int currentStock = int.parse((itemSnapshot.data() as Map<String, dynamic>)['quantityInStock'] ?? '0');

        if (currentStock < quantity) {
          throw Exception("Not enough stock available for item");
        }

        int newStock = currentStock - quantity;

        transaction.update(itemRef, {
          'quantityInStock': newStock.toString(),
        });

        return true;
      });
    } catch (e) {
      print("Error deducting inventory: $e");
      return false;
    }
  }

  Future<bool> processCartInventory(List<String> itemIDs, List<int> quantities) async {
    try {
      bool success = true;
      for (int i = 0; i < itemIDs.length; i++) {
        bool deducted = await deductInventory(itemIDs[i], quantities[i]);
        if (!deducted) {
          success = false;
          break;
        }
      }
      return success;
    } catch (e) {
      print("Error processing cart inventory: $e");
      return false;
    }
  }
}