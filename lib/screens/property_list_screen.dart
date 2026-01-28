import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propert_list/widget/property_card.dart';

import '../providers/property_provider.dart';
import '../providers/app_init_provider.dart';
import '../providers/connectivity_provider.dart'; // New import
import 'favorites_screen.dart';
import 'offline_indicator.dart';
import 'profile_screen.dart';

class PropertyListScreen extends ConsumerWidget {
  const PropertyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initState = ref.watch(appInitProvider);
    final isOnline = ref.watch(isOnlineProvider); // Tracks network/settings status

    return initState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        body: Center(child: Text('Initialization error: $err')),
      ),
      data: (_) {
        final propertyListAsync = ref.watch(propertyListProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('PropertyPal'),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            ],
          ),
          body: Column(
            children: [
              // 1️⃣ Offline Banner (Matches offline indicator.jpg)
              OfflineIndicator(isOnline: isOnline),

              Expanded(
                child: propertyListAsync.when(
                  data: (properties) {
                    if (properties.isEmpty) {
                      return const Center(child: Text('No properties available'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: properties.length + 1,
                      itemBuilder: (context, index) {
                        // 2️⃣ Header section from home.jpg
                        if (index == 0) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Properties for you',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        final property = properties[index - 1];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: PropertyCard(property: property),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(
                    child: ElevatedButton(
                      onPressed: () => ref.refresh(propertyListProvider),
                      child: const Text('Retry'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favorites'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
            ],
            onTap: (index) {
              if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
              } else if (index == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }
            },
          ),
        );
      },
    );
  }
}