import '../db/database_helper.dart';
import '../models/inquiry.dart';

class InquiryRepository {
  final dbHelper = DatabaseHelper.instance;

  /// Saves a new inquiry (usually with 'queued' status when offline)
  Future<void> saveInquiry(Inquiry inquiry) async {
    await dbHelper.insertInquiry(inquiry);
  }

  /// Fetches only inquiries waiting to be sent
  Future<List<Inquiry>> getQueuedInquiries() async {
    return await dbHelper.getQueuedInquiries();
  }

  /// Fetches all inquiries to display in a history or favorites list
  Future<List<Inquiry>> getAllInquiries() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('inquiries', orderBy: 'timestamp DESC');
    return maps.map((e) => Inquiry.fromMap(e)).toList();
  }

  /// Updates status between 'queued', 'synced', and 'failed'
  /// This drives the red/green badges seen in the UI
  Future<void> updateInquiryStatus(int id, String status) async {
    await dbHelper.updateInquiryStatus(id, status);
  }

  /// Deletes an inquiry (useful for the 'Clear Offline Data' action)
  Future<void> deleteInquiry(int id) async {
    final db = await dbHelper.database;
    await db.delete(
      'inquiries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}