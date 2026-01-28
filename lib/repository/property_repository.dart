import '../db/database_helper.dart';
import '../models/property.dart';

class PropertyRepository {
  final dbHelper = DatabaseHelper.instance;

  /// Fetches all properties stored locally.
  /// Used for the main list in home.jpg.
  Future<List<Property>> fetchProperties() async {
    return await dbHelper.getAllProperties();
  }

  /// Fetches only favorite properties for the fav.jpg screen.
  Future<List<Property>> fetchFavorites() async {
    return await dbHelper.getFavorites();
  }

  /// Saves or updates a property.
  /// Useful when caching data for offline use.
  Future<void> saveProperty(Property property) async {
    await dbHelper.insertProperty(property);
  }

  /// Toggles the favorite status (0 or 1) in the DB.
  /// Directly supports the heart icon in propertyDetail.jpg.
  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await dbHelper.toggleFavorite(id, isFavorite);
  }

  /// Updates the sync badge (Synced, Cached, Failed, Queued).
  /// This drives the visual indicators seen in your UI screenshots.
  Future<void> updateSyncStatus(int id, String status) async {
    await dbHelper.updatePropertySyncStatus(id, status);
  }

  /// Clears non-favorite properties to free up space.
  /// Matches the 'Clear Offline Data' button in profile & setting.jpg.
  Future<void> clearCache() async {
    await dbHelper.clearOfflineCache();
  }
}