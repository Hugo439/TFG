class UserModel {
  final String uid;
  final String email;
  final String? fcmToken;
  
  UserModel({
    required this.uid, 
    required this.email,
    this.fcmToken,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }
  
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      fcmToken: map['fcmToken'],
    );
  }
}
