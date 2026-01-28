import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/property.dart';
import '../db/database_helper.dart';

class FavoritesNotifier extends StateNotifier<List<Property>> {
  final DatabaseHelper _db = DatabaseHelper.instance;

  FavoritesNotifier() : super([]) {
    _loadFavorites();
  }

  /// Initial load from SQLite to populate the Favorites screen (fav.jpg)
  Future<void> _loadFavorites() async {
    final favs = await _db.getFavorites();
    state = favs;
  }

  /// Toggles favorite status and persists it to the local database
  Future<void> toggleFavorite(Property property) async {
    final isCurrentlyFav = state.any((p) => p.id == property.id);

    // 1. Update SQLite
    await _db.toggleFavorite(property.id!, !isCurrentlyFav);

    // 2. Update Local State for immediate UI response
    if (isCurrentlyFav) {
      state = state.where((p) => p.id != property.id).toList();
    } else {
      // Add the property to the list with the updated isFavorite flag
      state = [...state, property.copyWith(isFavorite: true)];
    }
  }

  /// Helper to check status for the heart icon on the detail screen
  bool isFavorite(int? id) {
    return state.any((p) => p.id == id);
  }

  /// Refreshes the list to capture syncStatus changes (e.g., Queued -> Synced)
  Future<void> refresh() async => await _loadFavorites();
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<Property>>(
      (ref) => FavoritesNotifier(),
);