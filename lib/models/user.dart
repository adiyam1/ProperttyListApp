class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? avatar;
  final bool isDarkMode;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.isDarkMode = false,
    required this.createdAt,
  });

  /// Convert User → Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'isDarkMode': isDarkMode ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert Map → User
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      avatar: map['avatar'],
      isDarkMode: map['isDarkMode'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// Copy helper (useful for updates)
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    bool? isDarkMode,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      createdAt: createdAt,
    );
  }
}
