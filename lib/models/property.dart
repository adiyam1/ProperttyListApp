class Property {
  final int id;
  final String title;
  final String description;
  final String location;
  final double price;
  final List<String> imageUrls;
  final String status; // published/archived
  final String syncStatus; // queued/synced/failed
  final DateTime lastUpdated;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.imageUrls,
    required this.status,
    required this.syncStatus,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'price': price,
        'imageUrls': imageUrls.join(','),
        'status': status,
        'syncStatus': syncStatus,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory Property.fromMap(Map<String, dynamic> map) => Property(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        location: map['location'],
        price: map['price'],
        imageUrls: map['imageUrls'].split(','),
        status: map['status'],
        syncStatus: map['syncStatus'],
        lastUpdated: DateTime.parse(map['lastUpdated']),
      );
}