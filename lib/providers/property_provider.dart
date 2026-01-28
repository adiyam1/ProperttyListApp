import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/property.dart';
import '../repository/property_repository.dart';

final propertyRepositoryProvider = Provider((ref) => PropertyRepository());

class PropertyNotifier extends StateNotifier<AsyncValue<List<Property>>> {
  final PropertyRepository _repo;

  PropertyNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadProperties();
  }

  // Fetches properties from local SQLite.
  // Displays the 'Cached' or 'Synced' states seen in home.jpg
  Future<void> loadProperties() async {
    state = const AsyncValue.loading();
    try {
      final properties = await _repo.fetchProperties();
      state = AsyncValue.data(properties);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Updates a property's status locally (e.g., when a background sync finishes)
  void updatePropertyInState(Property updatedProperty) {
    state.whenData((properties) {
      state = AsyncValue.data([
        for (final p in properties)
          if (p.id == updatedProperty.id) updatedProperty else p
      ]);
    });
  }
}

// The main provider for the Property List UI
final propertyListProvider =
StateNotifierProvider<PropertyNotifier, AsyncValue<List<Property>>>((ref) {
  return PropertyNotifier(ref.watch(propertyRepositoryProvider));
});

// A specific provider for the Favorites Screen (fav.jpg)
// Filters properties where isFavorite is true
final favoritePropertiesProvider = Provider<List<Property>>((ref) {
  final allProps = ref.watch(propertyListProvider);
  return allProps.maybeWhen(
    data: (list) => list.where((p) => p.isFavorite).toList(),
    orElse: () => [],
  );
});