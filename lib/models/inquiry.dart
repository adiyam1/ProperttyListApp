class Inquiry {
  final int? id;
  final int propertyId;
  final int userId;
  final String message;
  final String status;
  final DateTime timestamp;

  Inquiry({
    this.id,
    required this.propertyId,
    required this.userId,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  //Helper to create a new instance with updated fields.
  //Useful when the network sync finishes and you need to update status to 'synced'.
  Inquiry copyWith({
    int? id,
    int? propertyId,
    int? userId,
    String? message,
    String? status,
    DateTime? timestamp,
  }) {
    return Inquiry(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'propertyId': propertyId,
    'userId': userId,
    'message': message,
    'status': status,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Inquiry.fromMap(Map<String, dynamic> map) => Inquiry(
    id: map['id'] as int?,
    propertyId: map['propertyId'] as int,
    userId: map['userId'] as int,
    message: map['message'] as String,
    status: map['status'] as String,
    timestamp: DateTime.parse(map['timestamp'] as String),
  );
}