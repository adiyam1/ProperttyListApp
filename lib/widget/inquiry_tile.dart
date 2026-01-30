import 'package:flutter/material.dart';
import 'package:propert_list/models/inquiry.dart';

class InquiryTile extends StatelessWidget {
  final Inquiry inquiry;

  const InquiryTile({super.key, required this.inquiry});

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
