class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final Map<String, dynamic> settings;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    required this.createdAt,
    required this.lastLoginAt,
    this.settings = const {},
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      lastLoginAt: DateTime.fromMillisecondsSinceEpoch(map['lastLoginAt'] ?? 0),
      settings: Map<String, dynamic>.from(map['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastLoginAt': lastLoginAt.millisecondsSinceEpoch,
      'settings': settings,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}