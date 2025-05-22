import 'package:cloud_firestore/cloud_firestore.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).add(data);
  }

  Future<void> setDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).doc(docId).set(data);
  }

  Future<void> updateDocument(String collectionPath, String docId, Map<String, dynamic> data) async {
    await _db.collection(collectionPath).doc(docId).update(data);
  }

  Future<void> deleteDocument(String collectionPath, String docId) async {
    await _db.collection(collectionPath).doc(docId).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String collectionPath, String docId) async {
    return await _db.collection(collectionPath).doc(docId).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream(String collectionPath) {
    return _db.collection(collectionPath).snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getCollectionOnce(String collectionPath) async {
    return await _db.collection(collectionPath).get();
  }
}
