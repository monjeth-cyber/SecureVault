class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final bool isEmailVerified;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isEmailVerified,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      isEmailVerified: map['isEmailVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'isEmailVerified': isEmailVerified,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    bool? isEmailVerified,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}
