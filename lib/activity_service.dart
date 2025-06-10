import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recent activities for the current user
  Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      if (_auth.currentUser == null || _auth.currentUser!.email == null) {
        throw Exception('User not logged in');
      }

      List<Map<String, dynamic>> activities = [];

      // Get recent sales (last 5)
      QuerySnapshot recentSales = await _firestore
          .collection('sales')
          .where('userEmail', isEqualTo: _auth.currentUser!.email)
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();

      for (var doc in recentSales.docs) {
        Map<String, dynamic> sale = doc.data() as Map<String, dynamic>;
        Timestamp? timestamp = sale['createdAt'] as Timestamp?;
        DateTime dateTime = timestamp?.toDate() ?? DateTime.now();

        activities.add({
          'type': 'sale',
          'icon': 'payment',
          'title': 'Payment Received',
          'subtitle':
              '\$${sale['total']?.toStringAsFixed(2) ?? '0.00'} from ${sale['customerName'] ?? 'Customer'} - ${_formatTimeAgo(dateTime)}',
          'timestamp': dateTime,
          'color': 'orange',
        });
      }

      // Get recent product additions (last 3)
      QuerySnapshot recentProducts = await _firestore
          .collection('products')
          .where('userEmail', isEqualTo: _auth.currentUser!.email)
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      for (var doc in recentProducts.docs) {
        Map<String, dynamic> product = doc.data() as Map<String, dynamic>;
        DateTime dateTime = DateTime.parse(
            product['createdAt'] ?? DateTime.now().toIso8601String());

        activities.add({
          'type': 'product',
          'icon': 'inventory',
          'title': 'New Product Added',
          'subtitle': '${product['name']} - ${_formatTimeAgo(dateTime)}',
          'timestamp': dateTime,
          'color': 'green',
        });
      }

      // Get user registration activity (only show once)
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Timestamp? createdAt = userData['createdAt'] as Timestamp?;
        if (createdAt != null) {
          DateTime dateTime = createdAt.toDate();
          // Only show if registration was recent (within last 7 days)
          if (DateTime.now().difference(dateTime).inDays <= 7) {
            activities.add({
              'type': 'user',
              'icon': 'person_add',
              'title': 'Account Created',
              'subtitle':
                  'Welcome to Search-A-Holic! - ${_formatTimeAgo(dateTime)}',
              'timestamp': dateTime,
              'color': 'purple',
            });
          }
        }
      }

      // Sort activities by timestamp (most recent first)
      activities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      // Return only the 5 most recent activities
      return activities.take(5).toList();
    } catch (e) {
      throw Exception('Failed to get activities: $e');
    }
  }

  // Format time ago string
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Log a new activity (for future use)
  Future<void> logActivity(
      String type, String title, String description) async {
    try {
      if (_auth.currentUser != null) {
        await _firestore.collection('activities').add({
          'userId': _auth.currentUser!.uid,
          'userEmail': _auth.currentUser!.email,
          'type': type,
          'title': title,
          'description': description,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      // Silent fail for activity logging
      print('Failed to log activity: $e');
    }
  }
}
