/// Firebase-ready data contract.
/// Next step: implement this contract with Firebase Auth + Firestore.
abstract class BukoBackend {
  Future<void> signInWithPhone(String phone, String password);
  Future<void> createUser({required String name, required String phone, required String role});
  Future<void> submitCarAd(Map<String, dynamic> data);
  Future<void> submitPurchaseRequest(Map<String, dynamic> data);
  Stream<List<Map<String, dynamic>>> watchUsers();
  Stream<List<Map<String, dynamic>>> watchPendingAds();
  Stream<List<Map<String, dynamic>>> watchPurchaseRequests();
}
