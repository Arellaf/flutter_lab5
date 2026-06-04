class UserModel {
  final String id;
  final String email;
  final String nickname;

  UserModel({
    required this.id,
    required this.email,
    required this.nickname,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      nickname: json['nickname'] ?? '',
    );
  }
}