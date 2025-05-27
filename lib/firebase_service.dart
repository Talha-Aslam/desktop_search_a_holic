import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Store user data in Firestore
  Future<void> storeUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      rethrow;
    }
  }

  // Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Test Firebase connection
  Future<bool> testFirebaseConnection() async {
    try {
      // Try to perform a simple read operation
      await _firestore.collection('test').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Product-related methods
  
  // Add a new product to Firestore
  Future<String> addProduct(Map<String, dynamic> productData) async {
    try {
      DocumentReference docRef = await _firestore.collection('products').add(productData);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all products from Firestore
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('products').get();
      
      List<Map<String, dynamic>> products = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> productData = Map<String, dynamic>.from(doc.data() as Map);
        productData['id'] = doc.id; // Add document ID to the product data
        products.add(productData);
      }
      
      return products;
    } catch (e) {
      rethrow;
    }
  }

  // Get products stream for real-time updates
  Stream<List<Map<String, dynamic>>> getProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      List<Map<String, dynamic>> products = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> productData = Map<String, dynamic>.from(doc.data() as Map);
        productData['id'] = doc.id;
        products.add(productData);
      }
      return products;
    });
  }

  // Update a product in Firestore
  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      await _firestore.collection('products').doc(productId).update(productData);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a product from Firestore
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get a single product by ID
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        Map<String, dynamic> productData = Map<String, dynamic>.from(doc.data() as Map);
        productData['id'] = doc.id;
        return productData;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
