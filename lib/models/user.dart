// models/user.dart

/// 사용자 정보를 담는 모델 클래스
class User {
  final int userId;       // 사용자 고유 ID
  final String name;      // 사용자 이름
  final String email;     // 사용자 이메일
  final String phoneNumber; // 사용자 전화번호

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'], // Flask 기준
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    };
  }
}