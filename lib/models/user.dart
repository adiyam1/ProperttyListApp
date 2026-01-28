class UserModel {
  final int? id;
  final String name;
  final String email;
  final String? avatar;
  final bool isDarkMode;
  final bool isOfflineModeOnly; // Added for "Offline Mode (Wi-Fi only sync)" toggle
  final DateTime? lastGlobalSync; // Added for "Last synced just now" status
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.isDarkMode = false,
    this.isOfflineModeOnly = false,
    this.lastGlobalSync,
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
      'isOfflineModeOnly': isOfflineModeOnly ? 1 : 0,
      'lastGlobalSync': lastGlobalSync?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convert Map → User
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      avatar: map['avatar'] as String?,
      isDarkMode: (map['isDarkMode'] as int? ?? 0) == 1,
      isOfflineModeOnly: (map['isOfflineModeOnly'] as int? ?? 0) == 1,
      lastGlobalSync: map['lastGlobalSync'] != null
          ? DateTime.parse(map['lastGlobalSync'] as String)
          : null,
      // Safely handle missing createdAt dates
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Copy helper (essential for toggling settings in the UI)
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? avatar,
    bool? isDarkMode,
    bool? isOfflineModeOnly,
    DateTime? lastGlobalSync,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isOfflineModeOnly: isOfflineModeOnly ?? this.isOfflineModeOnly,
      lastGlobalSync: lastGlobalSync ?? this.lastGlobalSync,
      createdAt: createdAt,
    );
  }
}