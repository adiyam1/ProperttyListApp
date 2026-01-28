import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propert_list/core/mockData/mock_data.dart';
import '../db/database_helper.dart';
import '../core/services/sync_service.dart';

final appInitProvider = FutureProvider<void>((ref) async {
  final db = DatabaseHelper.instance;

  await db.database;

  final userCount = await db.getUsersCount();
  if (userCount == 0) {
    await MockData.seedPropertiesAndInquiries();
  }

  // Initialize background sync service
  ref.read(syncServiceProvider);

  print('App Initialization Complete');
});
