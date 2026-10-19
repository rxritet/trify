class AppUser {
  const AppUser({
    required this.id,
    required this.plannerOwnerId,
    this.firebaseUid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  final int id;

  /// Stable namespace for the user's private planning data.
  final String plannerOwnerId;
  final String? firebaseUid;
  final String name;
  final String email;
  final DateTime createdAt;

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
    id: map['id']! as int,
    plannerOwnerId: 'local-${map['id']! as int}',
    name: map['name']! as String,
    email: map['email']! as String,
    createdAt: DateTime.parse(map['created_at']! as String),
  );

  factory AppUser.fromGoogle({
    required String uid,
    required String email,
    required String? displayName,
  }) => AppUser(
    id: uid.hashCode,
    plannerOwnerId: 'firebase-$uid',
    firebaseUid: uid,
    name: displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : 'Путешественник',
    email: email,
    createdAt: DateTime.now(),
  );
}
