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
      // Add user email to product data
      if (_auth.currentUser != null) {
        productData['userEmail'] = _auth.currentUser!.email;
      }
      
      DocumentReference docRef = await _firestore.collection('products').add(productData);
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Get all products from Firestore (filtered by current user)
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw Exception('User not logged in');
      }
      
      // Filter products by current user's email
      QuerySnapshot querySnapshot = await _firestore
          .collection('products')
          .where('userEmail', isEqualTo: _auth.currentUser!.email)
          .get();
      
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

  // Get products stream for real-time updates (filtered by current user)
  Stream<List<Map<String, dynamic>>> getProductsStream() {
    // Check if user is logged in
    if (_auth.currentUser == null || _auth.currentUser!.email == null) {
      return Stream.value([]); // Return empty stream if no user
    }
    
    return _firestore
        .collection('products')
        .where('userEmail', isEqualTo: _auth.currentUser!.email)
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> products = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> productData = Map<String, dynamic>.from(doc.data() as Map);
        productData['id'] = doc.id;
        products.add(productData);
      }
      return products;
    });
  }

  // Update a product in Firestore (only if it belongs to current user)
  Future<void> updateProduct(String productId, Map<String, dynamic> productData) async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw Exception('User not logged in');
      }
      
      // First, verify that the product belongs to the current user
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        throw Exception('Product not found');
      }
      
      Map<String, dynamic> existingData = Map<String, dynamic>.from(doc.data() as Map);
      if (existingData['userEmail'] != _auth.currentUser!.email) {
        throw Exception('Access denied - product does not belong to current user');
      }
      
      // Add updated timestamp and ensure userEmail is preserved
      productData['updatedAt'] = DateTime.now().toIso8601String();
      productData['userEmail'] = _auth.currentUser!.email;
      
      await _firestore.collection('products').doc(productId).update(productData);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a product from Firestore (only if it belongs to current user)
  Future<void> deleteProduct(String productId) async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw Exception('User not logged in');
      }
      
      // First, verify that the product belongs to the current user
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (!doc.exists) {
        throw Exception('Product not found');
      }
      
      Map<String, dynamic> existingData = Map<String, dynamic>.from(doc.data() as Map);
      if (existingData['userEmail'] != _auth.currentUser!.email) {
        throw Exception('Access denied - product does not belong to current user');
      }
      
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get a single product by ID (only if it belongs to current user)
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      // Check if user is logged in
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw Exception('User not logged in');
      }
      
      DocumentSnapshot doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        Map<String, dynamic> productData = Map<String, dynamic>.from(doc.data() as Map);
        
        // Check if the product belongs to the current user
        if (productData['userEmail'] == _auth.currentUser!.email) {
          productData['id'] = doc.id;
          return productData;
        } else {
          // Product doesn't belong to current user
          throw Exception('Product not found or access denied');
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
