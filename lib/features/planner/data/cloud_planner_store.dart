import 'package:cloud_firestore/cloud_firestore.dart';

import 'planner_repository.dart';

/// Mirrors one user's planner locally and in their private Firestore document.
///
/// Local persistence keeps the app usable without a network connection. The
/// Firestore copy is restored after sign-in and updated after every change.
class CloudPlannerStore implements PlannerStore {
  CloudPlannerStore({
    required this.ownerId,
    required this.localStore,
    FirebaseFirestore? firestore,
  }) : _document = (firestore ?? FirebaseFirestore.instance)
           .collection('users')
           .doc(ownerId)
           .collection('planner')
           .doc('state');

  final String ownerId;
  final PlannerStore localStore;
  final DocumentReference<Map<String, dynamic>> _document;

  @override
  Future<PlannerSnapshot?> load() async {
    final local = await localStore.load();
    try {
      final remote = await _document.get();
      final data = remote.data();
      if (data == null || data['ownerId'] != ownerId) return local;
      final planner = data['planner'];
      if (planner is! Map<String, dynamic>) return local;
      final snapshot = PlannerRepository.snapshotFromJson(planner);
      await localStore.save(snapshot);
      return snapshot;
    } on FirebaseException {
      return local;
    }
  }

  @override
  Future<void> save(PlannerSnapshot snapshot) async {
    await localStore.save(snapshot);
    try {
      await _document.set({
        'ownerId': ownerId,
        'planner': PlannerRepository.snapshotToJson(snapshot),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      // The local copy remains the offline fallback; the next change retries.
    }
  }
}
