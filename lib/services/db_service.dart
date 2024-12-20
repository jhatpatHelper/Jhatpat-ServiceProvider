import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> fetchCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('categories').get();
      return snapshot.docs.map((doc) => doc['name'].toString()).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<DocumentReference> saveServiceProvider(Map<String, dynamic> data) async {
    try {
      return await _firestore.collection('service-providers').add(data);
    } catch (e) {
      print("Error saving service provider: $e");
      rethrow;
    }
  }

  Future<void> updateCategoryProviderList(String categoryName, String providerId) async {
    try {
      QuerySnapshot categorySnapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: categoryName)
          .get();

      if (categorySnapshot.docs.isNotEmpty) {
        DocumentReference categoryRef = categorySnapshot.docs.first.reference;
        await categoryRef.update({
          'ProviderList': FieldValue.arrayUnion([providerId]),
        });
      }
    } catch (e) {
      print("Error updating category provider list: $e");
      rethrow;
    }
  }
}
