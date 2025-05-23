// models/user.dart

/// 사용자 정보를 담는 모델 클래스
class User {
  final String id;       // 사용자 고유 ID
  final String name;     // 사용자 이름
  final String email;    // 사용자 이메일
  final String phone;    // 사용자 전화번호

  /// 생성자
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  /// JSON 데이터를 User 객체로 변환하는 팩토리 메서드
  ///
  /// 백엔드에서 받은 JSON 데이터를 User 인스턴스로 생성
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),         // 정수 ID도 문자열로 변환
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  /// User 객체를 JSON 형식으로 변환
  ///
  /// 필요 시 서버에 다시 전송하거나 저장할 때 사용
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}