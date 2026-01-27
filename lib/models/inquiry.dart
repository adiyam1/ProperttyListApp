class Inquiry {
  final int id;
  final int propertyId;
  final String message;
  final String status; // queued/synced/failed
  final DateTime timestamp;

  Inquiry({
    required this.id,
    required this.propertyId,
    required this.message,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'propertyId': propertyId,
        'message': message,
        'status': status,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Inquiry.fromMap(Map<String, dynamic> map) => Inquiry(
        id: map['id'],
        propertyId: map['propertyId'],
        message: map['message'],
        status: map['status'],
        timestamp: DateTime.parse(map['timestamp']),
      );
}