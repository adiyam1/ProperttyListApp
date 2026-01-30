import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';
import '../models/inquiry.dart';
import '../providers/favorites_provider.dart';
import '../providers/inquiry_provider.dart';
import '../providers/user_provider.dart';
import '../providers/property_provider.dart';
import '../widget/property_image.dart';
import 'add_edit_property_screen.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _deleteProperty() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete property?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(propertyRepositoryProvider).deleteProperty(widget.property.id!);
              ref.invalidate(propertyListProvider);
              ref.invalidate(favoritesProvider);
              if (!context.mounted) return;
              Navigator.pop(ctx);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Property deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final isFavorite = ref.watch(favoritesProvider.notifier).isFavorite(property.id);
    final user = ref.watch(userProvider).maybeWhen(
          data: (d) => d,
          orElse: () => null,
        );
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditPropertyScreen(property: property),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: _deleteProperty,
            ),
          ],
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(property);
            },
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE CAROUSEL (Matches visual height in mockup)
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: property.imageUrls.isEmpty ? 1 : property.imageUrls.length,
                    itemBuilder: (context, index) {
                      final url = property.imageUrls.isEmpty
                          ? 'https://via.placeholder.com/400'
                          : property.imageUrls[index];
                      return propertyImage(
                        url: url,
                        fit: BoxFit.cover,
                        height: 300,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${property.imageUrls.isEmpty ? 1 : 1}/${property.imageUrls.isEmpty ? 1 : property.imageUrls.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE & PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          property.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${property.price.toStringAsFixed(0)}ETB',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),

                  // SPECIFICATIONS (Matches the icons in propertyDetail.jpg)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _specItem(Icons.king_bed_outlined, '${property.beds} Beds'),
                        _specItem(Icons.bathtub_outlined, '${property.baths} Baths'),
                        _specItem(Icons.square_foot_rounded, '${property.sqft} sqft'),
                      ],
                    ),
                  ),
                  const Divider(),

                  // AGENT INFO SECTION (New based on mockup)
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage('https://example.com/agent.jpg'),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Adiyam Yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Property Owner', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.phone, color: Colors.blue), onPressed: () {}),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(property.description, style: const TextStyle(height: 1.5, color: Colors.black87)),

                  const SizedBox(height: 32),

                  // INQUIRY FORM
                  const Text('Send Inquiry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ask about availability...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        // Use RoundedRectangleBorder to define the shape
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (_messageController.text.isNotEmpty && user != null) {
                          final inquiry = Inquiry(
                            propertyId: property.id!,
                            userId: user.id!,
                            message: _messageController.text,
                            status: 'queued', // Defaults to queued for offline support
                            timestamp: DateTime.now(),
                          );

                          await ref.read(inquiryProvider.notifier).addInquiry(inquiry);
                          ref.invalidate(myInquiriesProvider);
                          _messageController.clear();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Message queued for sync!')),
                            );
                          }
                        }
                      },
                      child: const Text('Send Message', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}