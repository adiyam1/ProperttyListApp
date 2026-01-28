import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inquiry.dart';
import '../providers/inquiry_provider.dart';

class InquiriesScreen extends ConsumerWidget {
  const InquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(inquiryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Inquiries'),
      ),
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text('No inquiries yet', style: TextStyle(color: Colors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final q = list[i];
              return _InquiryTile(inquiry: q);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(inquiryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  final Inquiry inquiry;

  const _InquiryTile({required this.inquiry});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (inquiry.status.toLowerCase()) {
      case 'synced':
        statusColor = Colors.green;
        break;
      case 'queued':
        statusColor = Colors.orange;
        break;
      case 'failed':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          inquiry.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Property #${inquiry.propertyId} · ${inquiry.status}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Chip(
          label: Text(
            inquiry.status.toUpperCase(),
            style: TextStyle(fontSize: 10, color: statusColor),
          ),
          backgroundColor: statusColor.withOpacity(0.2),
        ),
      ),
    );
  }
}
