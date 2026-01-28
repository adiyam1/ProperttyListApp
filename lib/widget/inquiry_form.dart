import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inquiry.dart';
import '../providers/inquiry_provider.dart';
import '../providers/user_provider.dart';

class InquiryForm extends ConsumerStatefulWidget {
  final int propertyId;
  const InquiryForm({super.key, required this.propertyId});

  @override
  ConsumerState<InquiryForm> createState() => _InquiryFormState();
}

class _InquiryFormState extends ConsumerState<InquiryForm> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitInquiry() async {
    final messageText = _controller.text.trim();
    if (messageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final user = ref.read(userProvider).maybeWhen(
          data: (d) => d,
          orElse: () => null,
        );

    if (user == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send messages')),
      );
      return;
    }

    final inquiry = Inquiry(
      propertyId: widget.propertyId,
      userId: user.id!,
      message: messageText,
      status: 'queued', // Default state for offline-first
      timestamp: DateTime.now(),
    );

    await ref.read(inquiryProvider.notifier).addInquiry(inquiry);
    ref.invalidate(myInquiriesProvider);

    if (mounted) {
      setState(() => _isSubmitting = false);
      _controller.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message saved offline and queued for sync'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.blueAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Send Inquiry',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "I'm interested in this property...",
            filled: true,
            fillColor: Colors.grey[100], // Matches propertyDetail.jpg
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitInquiry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Matches the blue button in UI
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'Send Message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}