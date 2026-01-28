import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propert_list/core/mockData/mock_data.dart';
import '../db/database_helper.dart';

final appInitProvider = FutureProvider<void>((ref) async {
  final db = DatabaseHelper.instance;

  // 1️⃣ Ensure Database is initialized and migrated to the latest version
  await db.database;

  // 2️⃣ Check for existing user or properties
  final existingUser = await db.getUser();
  final existingProperties = await db.getAllProperties();

  // 3️⃣ Seed Mock Data if the app is fresh
  // This populates the Luxury Villa, the failed Cottage, and Jane Doe's profile
  if (existingUser == null || existingProperties.isEmpty) {
    await MockData.seedPropertiesAndInquiries();
  }

  // 4️⃣ Optional: Perform a 'silent' sync check on startup
  // to update those 'Last Synced' labels seen in the Profile UI
  print('🚀 App Initialization Complete');
});