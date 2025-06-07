class UserModel {
  String? status;
  String? message;
  UserData? data;

  UserModel({this.status, this.message, this.data});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UserData {
  User? user;
  String? token;

  UserData({this.user, this.token});

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) data['user'] = user!.toJson();
    if (token != null) data['token'] = token;
    return data;
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String? profilePicture;
  final bool role; // true = admin, false = user
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.role = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      role: json['role'] == 1 || json['role'] == true, // support int or bool
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'profile_picture': profilePicture,
    'role': role,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  Map<String, dynamic> toJsonForUpdate() => {
    'username': username,
    'email': email,
    if (profilePicture != null) 'profile_picture': profilePicture,
  };
}

class AuthResponse {
  final String token;
  final String message;
  final User user;

  AuthResponse({
    required this.token,
    required this.message,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      message: json['message'] as String? ?? 'Operation successful',
      user: User.fromJson(
        (json['user'] ?? json['data']) as Map<String, dynamic>,
      ),
    );
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String passwordConfirmation;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    'passwordConfirmation': passwordConfirmation,
  };
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
