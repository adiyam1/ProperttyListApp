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

  Map<String, dynamic> toMap() => {
    'id': id,
    'propertyId': propertyId,
    'userId': userId,
    'message': message,
    'status': status,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Inquiry.fromMap(Map<String, dynamic> map) => Inquiry(
    id: map['id'],
    propertyId: map['propertyId'],
    userId: map['userId'],
    message: map['message'],
    status: map['status'],
    timestamp: DateTime.parse(map['timestamp']),
  );
}
