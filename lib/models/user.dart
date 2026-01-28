/// User role for access control.
enum UserRole { admin, user }

extension UserRoleExt on UserRole {
  String get value => name;
  String get displayName => this == UserRole.admin ? 'Admin' : 'User';
  static UserRole from(String s) {
    return UserRole.values.firstWhere(
      (e) => e.name == s,
      orElse: () => UserRole.user,
    );
  }
}

class UserModel {
  final int? id;
  final String name;
  final String email;
  final String passwordHash; // Stored hashed; demo uses simple hash
  final UserRole role;
  final String? avatar;
  final bool isDarkMode;
  final bool isOfflineModeOnly;
  final DateTime? lastGlobalSync;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.role = UserRole.user,
    this.avatar,
    this.isDarkMode = false,
    this.isOfflineModeOnly = false,
    this.lastGlobalSync,
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'role': role.value,
      'avatar': avatar,
      'isDarkMode': isDarkMode ? 1 : 0,
      'isOfflineModeOnly': isOfflineModeOnly ? 1 : 0,
      'lastGlobalSync': lastGlobalSync?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String? ?? '',
      role: UserRoleExt.from(map['role'] as String? ?? 'user'),
      avatar: map['avatar'] as String?,
      isDarkMode: (map['isDarkMode'] as int? ?? 0) == 1,
      isOfflineModeOnly: (map['isOfflineModeOnly'] as int? ?? 0) == 1,
      lastGlobalSync: map['lastGlobalSync'] != null
          ? DateTime.parse(map['lastGlobalSync'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    UserRole? role,
    String? avatar,
    bool? isDarkMode,
    bool? isOfflineModeOnly,
    DateTime? lastGlobalSync,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isOfflineModeOnly: isOfflineModeOnly ?? this.isOfflineModeOnly,
      lastGlobalSync: lastGlobalSync ?? this.lastGlobalSync,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
