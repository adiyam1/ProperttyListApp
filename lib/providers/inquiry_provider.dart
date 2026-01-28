import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/inquiry.dart';
import '../repository/inquiry_repository.dart';

final inquiryRepositoryProvider = Provider((ref) => InquiryRepository());

class InquiryNotifier extends StateNotifier<AsyncValue<List<Inquiry>>> {
  final InquiryRepository _repo;

  InquiryNotifier(this._repo) : super(const AsyncValue.loading()) {
    fetchInquiries();
  }

  /// Loads all inquiries to show their status (Queued, Synced, Failed)
  Future<void> fetchInquiries() async {
    state = const AsyncValue.loading();
    try {
      final inquiries = await _repo.getAllInquiries();
      state = AsyncValue.data(inquiries);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Adds a new inquiry (e.g., from the 'Send Message' button in propertyDetail.jpg)
  Future<void> addInquiry(Inquiry inquiry) async {
    await _repo.saveInquiry(inquiry);
    await fetchInquiries(); // Refresh the list
  }

  /// Updates status (e.g., when the background sync succeeds)
  Future<void> updateStatus(int id, String newStatus) async {
    await _repo.updateInquiryStatus(id, newStatus);
    await fetchInquiries();
  }
}

/// The main provider to watch for inquiry updates across the app
final inquiryProvider =
StateNotifierProvider<InquiryNotifier, AsyncValue<List<Inquiry>>>((ref) {
  return InquiryNotifier(ref.watch(inquiryRepositoryProvider));
});

/// A filtered provider specifically for the "Queued" badge in the UI
final queuedInquiryCountProvider = Provider<int>((ref) {
  final state = ref.watch(inquiryProvider);
  return state.maybeWhen(
    data: (list) => list.where((i) => i.status == 'queued').length,
    orElse: () => 0,
  );
});