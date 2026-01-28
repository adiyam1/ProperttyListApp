import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:propert_list/providers/connectivity_provider.dart';
import 'package:propert_list/providers/inquiry_provider.dart';
import 'package:propert_list/providers/property_provider.dart';


class SyncService {
  final Ref ref;
  bool _running = false;

  SyncService(this.ref);

  Future<void> _onOnline() async {
    if (_running) return;
    _running = true;
    try {
      await _processQueuedInquiries();
      await _processQueuedProperties();
    } finally {
      _running = false;
    }
  }

  Future<void> _processQueuedInquiries() async {
    final repo = ref.read(inquiryRepositoryProvider);
    final queued = await repo.getQueuedInquiries();
    for (final iq in queued) {
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        // Randomly succeed to simulate network unreliability (dev only)
        final ok = Random().nextDouble() > 0.1;
        if (ok) {
          await repo.updateInquiryStatus(iq.id!, 'synced');
        } else {
          await repo.updateInquiryStatus(iq.id!, 'failed');
        }
      } catch (_) {
        await repo.updateInquiryStatus(iq.id!, 'failed');
      }
    }
  }

  Future<void> _processQueuedProperties() async {
    final repo = ref.read(propertyRepositoryProvider);
    final all = await repo.fetchProperties();
    final toSync = all.where((p) => p.syncStatus.toLowerCase() != 'synced');
    for (final p in toSync) {
      try {
        await Future.delayed(const Duration(milliseconds: 800));
        final ok = Random().nextDouble() > 0.15;
        if (ok) {
          await repo.updateSyncStatus(p.id!, 'synced');
        } else {
          await repo.updateSyncStatus(p.id!, 'failed');
        }
      } catch (_) {
        await repo.updateSyncStatus(p.id!, 'failed');
      }
    }
  }

  void dispose() {
    // nothing to dispose locally; provider handles lifecycle
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  final s = SyncService(ref);

  // Listen to online state and trigger sync when online
  ref.listen<bool>(isOnlineProvider, (previous, next) async {
    if (next == true) await s._onOnline();
  }, fireImmediately: true);

  ref.onDispose(() => s.dispose());
  return s;
});
