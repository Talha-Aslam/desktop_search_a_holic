import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> debugProductsData() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Check if user is logged in
  if (auth.currentUser == null || auth.currentUser!.email == null) {
    print('❌ No user logged in');
    return;
  }

  String userEmail = auth.currentUser!.email!;
  print('🔍 Debugging products for user: $userEmail');
  print('');

  try {
    // Get all products for current user
    QuerySnapshot productSnapshot = await firestore
        .collection('products')
        .where('userEmail', isEqualTo: userEmail)
        .get();

    print('📦 Total products found: ${productSnapshot.docs.length}');
    print('');

    // Convert to list and sort by createdAt (same logic as activity service)
    List<QueryDocumentSnapshot> productDocs = productSnapshot.docs;
    
    print('🗂️ All products (before sorting):');
    for (int i = 0; i < productDocs.length; i++) {
      Map<String, dynamic> product = productDocs[i].data() as Map<String, dynamic>;
      print('  ${i + 1}. ${product['name']} - Created: ${product['createdAt']}');
    }
    print('');

    // Sort by createdAt (most recent first)
    productDocs.sort((a, b) {
      Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
      Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;

      DateTime dateA;
      DateTime dateB;

      try {
        if (dataA['createdAt'] is Timestamp) {
          dateA = (dataA['createdAt'] as Timestamp).toDate();
        } else {
          dateA = DateTime.parse(dataA['createdAt'] ?? DateTime.now().toIso8601String());
        }
      } catch (e) {
        dateA = DateTime.now();
      }

      try {
        if (dataB['createdAt'] is Timestamp) {
          dateB = (dataB['createdAt'] as Timestamp).toDate();
        } else {
          dateB = DateTime.parse(dataB['createdAt'] ?? DateTime.now().toIso8601String());
        }
      } catch (e) {
        dateB = DateTime.now();
      }

      return dateB.compareTo(dateA); // Most recent first
    });

    print('📅 Products sorted by date (most recent first):');
    for (int i = 0; i < productDocs.length; i++) {
      Map<String, dynamic> product = productDocs[i].data() as Map<String, dynamic>;
      
      DateTime dateTime;
      try {
        if (product['createdAt'] is Timestamp) {
          dateTime = (product['createdAt'] as Timestamp).toDate();
        } else {
          dateTime = DateTime.parse(product['createdAt'] ?? DateTime.now().toIso8601String());
        }
      } catch (e) {
        dateTime = DateTime.now();
      }
      
      print('  ${i + 1}. ${product['name']} - Created: $dateTime');
      
      // Highlight the top 2 (which would appear in activity feed)
      if (i < 2) {
        print('    ⭐ THIS PRODUCT APPEARS IN ACTIVITY FEED');
      }
    }
    print('');

    // Show why Paracetamol might be appearing
    var paracetamolProducts = productDocs.where((doc) {
      Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
      return product['name'].toString().toLowerCase().contains('paracetamol');
    }).toList();

    if (paracetamolProducts.isNotEmpty) {
      print('💊 Found ${paracetamolProducts.length} Paracetamol product(s):');
      for (var doc in paracetamolProducts) {
        Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
        DateTime dateTime;
        try {
          if (product['createdAt'] is Timestamp) {
            dateTime = (product['createdAt'] as Timestamp).toDate();
          } else {
            dateTime = DateTime.parse(product['createdAt'] ?? DateTime.now().toIso8601String());
          }
        } catch (e) {
          dateTime = DateTime.now();
        }
        
        int index = productDocs.indexOf(doc) + 1;
        print('  - ${product['name']} (Rank: #$index, Created: $dateTime)');
        
        if (index <= 2) {
          print('    ✅ This explains why it appears in "New Product Added"!');
        }
      }
    } else {
      print('🤔 No Paracetamol products found - this is unexpected!');
    }

  } catch (e) {
    print('❌ Error debugging products: $e');
  }
}

void main() async {
  await debugProductsData();
}
