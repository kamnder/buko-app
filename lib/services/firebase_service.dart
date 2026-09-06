import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  auth.User? get currentUser => _auth.currentUser;
  Stream<auth.User?> get authState => _auth.authStateChanges();

  Future<void> signOut() => _auth.signOut();

  Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String role,
  }) {
    return _db.collection('users').doc(uid).set({
      'name': name.trim(),
      'phone': phone.trim(),
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchCars() => _db
      .collection('cars')
      .where('status', isEqualTo: 'approved')
      .orderBy('createdAt', descending: true)
      .snapshots();

  Future<DocumentReference<Map<String, dynamic>>> submitCar({
    required String name,
    required int year,
    required String price,
    required String city,
    required String type,
    required List<String> imageUrls,
  }) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('يجب تسجيل الدخول أولاً');
    return _db.collection('cars').add({
      'name': name.trim(),
      'year': year,
      'price': price.trim(),
      'city': city.trim(),
      'type': type.trim(),
      'sellerId': uid,
      'imageUrls': imageUrls.where((url) => url.trim().isNotEmpty).toList(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Firebase Storage is intentionally not used. The method remains as a
  // compatibility shim for the existing sell screen and never uploads data.
  Future<String> uploadCarImage(List<int> bytes, String fileName) async => '';

  Future<void> createPurchaseRequest({
    required String carId,
    required String sellerId,
  }) {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('يجب تسجيل الدخول أولاً');
    return _db.collection('purchaseRequests').add({
      'buyerId': uid,
      'carId': carId,
      'sellerId': sellerId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMyRequests() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('purchaseRequests')
        .where('buyerId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
