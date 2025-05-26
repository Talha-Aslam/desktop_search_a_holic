
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  // Authentication functions
  static Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
  
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
  
  // Firestore functions
  static Future<void> addDocument(String collection, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection(collection).add(data);
  }
  
  static Future<void> setDocument(String collection, String documentId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection(collection).doc(documentId).set(data);
  }
  
  static Future<DocumentSnapshot> getDocument(String collection, String documentId) async {
    return await FirebaseFirestore.instance.collection(collection).doc(documentId).get();
  }
  
  static Future<QuerySnapshot> getCollection(String collection) async {
    return await FirebaseFirestore.instance.collection(collection).get();
  }
  
  static Future<void> updateDocument(String collection, String documentId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection(collection).doc(documentId).update(data);
  }
  
  static Future<void> deleteDocument(String collection, String documentId) async {
    await FirebaseFirestore.instance.collection(collection).doc(documentId).delete();
  }
  
  // Password reset
  static Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
  }
}
