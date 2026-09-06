import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'image_upload_service.dart';

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
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول أولاً');
    final uid = user.uid.trim();
    if (uid.isEmpty) throw StateError('جلسة المستخدم غير صالحة. أعد تسجيل الدخول.');

    final payload = <String, dynamic>{
      'name': name.trim(),
      'year': year,
      'price': price.trim(),
      'city': city.trim(),
      'type': type.trim(),
      'sellerId': uid,
      'imageUrls': imageUrls.where((url) => url.trim().isNotEmpty).toList(),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      return await _db.collection('cars').add(payload);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw StateError('Firebase رفض إنشاء الإعلان (permission-denied). يجب نشر firestore.rules على مشروع BUKO.');
      }
      if (e.code == 'failed-precondition') {
        throw StateError('Firebase يحتاج إعداداً إضافياً (failed-precondition). تحقق من قاعدة Firestore.');
      }
      throw StateError('تعذر حفظ الإعلان في Firebase (${e.code}). ${e.message ?? ''}'.trim());
    }
  }

  Future<String> uploadCarImage(Uint8List bytes, String fileName) {
    return ImageUploadService.instance.uploadCarImage(bytes, fileName);
  }

  Future<void> createPurchaseRequest({
    required String carId,
    required String sellerId,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول أولاً');
    final uid = user.uid.trim();
    if (uid.isEmpty) throw StateError('جلسة المستخدم غير صالحة. أعد تسجيل الدخول.');
    if (sellerId.trim().isEmpty) throw StateError('بيانات البائع غير صالحة.');
    if (carId.trim().isEmpty) throw StateError('بيانات السيارة غير صالحة.');
    if (sellerId.trim() == uid) throw StateError('لا يمكنك طلب شراء سيارتك.');

    try {
      await _db.collection('purchaseRequests').add({
        'buyerId': uid,
        'carId': carId.trim(),
        'sellerId': sellerId.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw StateError('Firebase رفض إرسال الطلب (permission-denied). تحقق من firestore.rules.');
      }
      throw StateError('تعذر إرسال الطلب إلى Firebase (${e.code}). ${e.message ?? ''}'.trim());
    }
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
