import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inquiry.dart';
import '../providers/inquiry_provider.dart';
import '../providers/auth_provider.dart';

class MyInquiriesScreen extends ConsumerWidget {
  const MyInquiriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).maybeWhen(
          data: (d) => d,
          orElse: () => null,
        );
    final async = ref.watch(myInquiriesProvider);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Inquiries')),
        body: const Center(child: Text('Sign in to view your inquiries')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inquiries'),
      ),
      body: async.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No inquiries yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send a message from a property detail to see it here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final q = list[i];
              return _MyInquiryTile(inquiry: q);
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
                onPressed: () => ref.invalidate(myInquiriesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyInquiryTile extends StatelessWidget {
  final Inquiry inquiry;

  const _MyInquiryTile({required this.inquiry});

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
