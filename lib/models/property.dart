class Property {
  final int? id;
  final String title;
  final String description;
  final String location;
  final double price;
  final List<String> imageUrls;
  final String status;      // e.g., 'published', 'archived'
  final String syncStatus;  // e.g., 'synced', 'queued', 'failed', 'cached'
  final DateTime lastUpdated;
  final int beds;
  final double baths;       // Changed to double for 2.5 baths seen in UI
  final int sqft;
  final bool isFavorite;    // Added for the Favorites tab logic

  Property({
    this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.imageUrls,
    required this.status,
    required this.syncStatus,
    required this.lastUpdated,
    this.beds = 0,
    this.baths = 0.0,
    this.sqft = 0,
    this.isFavorite = false,
  });

  /// Allows updating specific fields (like syncStatus or isFavorite)
  /// without manually recreating the whole object.
  Property copyWith({
    int? id,
    String? title,
    String? description,
    String? location,
    double? price,
    List<String>? imageUrls,
    String? status,
    String? syncStatus,
    DateTime? lastUpdated,
    int? beds,
    double? baths,
    int? sqft,
    bool? isFavorite,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      price: price ?? this.price,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      syncStatus: syncStatus ?? this.syncStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      sqft: sqft ?? this.sqft,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

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
    'beds': beds,
    'baths': baths,
    'sqft': sqft,
    'isFavorite': isFavorite ? 1 : 0, // SQLite uses 0/1 for booleans
  };

  factory Property.fromMap(Map<String, dynamic> map) => Property(
    id: map['id'] as int?,
    title: map['title'] as String,
    description: map['description'] as String,
    location: map['location'] as String,
    price: (map['price'] as num).toDouble(),
    imageUrls: map['imageUrls'] != null && map['imageUrls'].toString().isNotEmpty
        ? map['imageUrls'].toString().split(',')
        : [],
    status: map['status'] as String,
    syncStatus: map['syncStatus'] as String,
    lastUpdated: DateTime.parse(map['lastUpdated'] as String),
    beds: map['beds'] as int? ?? 0,
    baths: (map['baths'] as num? ?? 0.0).toDouble(),
    sqft: map['sqft'] as int? ?? 0,
    isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
  );
}