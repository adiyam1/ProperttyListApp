import '../db/database_helper.dart';
import '../models/inquiry.dart';

class InquiryRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> saveInquiry(Inquiry inquiry) => dbHelper.insertInquiry(inquiry);

  Future<List<Inquiry>> getQueuedInquiries() => dbHelper.getQueuedInquiries();

  Future<void> updateStatus(int id, String status) =>
      dbHelper.updateInquiryStatus(id, status);
}