import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';
import '../providers/favorites_provider.dart';
import '../screens/property_detail_screen.dart';
import '../db/database_helper.dart';
import 'property_image.dart';

class PropertyCard extends ConsumerStatefulWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  ConsumerState<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends ConsumerState<PropertyCard> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final isFavorite =
    ref.watch(favoritesProvider).any((p) => p.id == widget.property.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PropertyDetailScreen(property: widget.property),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE + BADGES 
            Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: propertyImage(
                    url: widget.property.imageUrls.isNotEmpty
                        ? widget.property.imageUrls.first
                        : 'https://via.placeholder.com/400',
                    fit: BoxFit.cover,
                    height: 200,
                  ),
                ),

                //  SYNC BADGE
                Positioned(
                  top: 12,
                  left: 12,
                  child: GestureDetector(
                    onTap: _isSyncing ? null : _handleSyncTap,
                    child: _buildSyncBadge(
                      _isSyncing ? 'syncing' : widget.property.syncStatus,
                    ),
                  ),
                ),

                //  FAVORITE
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () =>
                        favoritesNotifier.toggleFavorite(widget.property),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 18,
                      child: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color:
                        isFavorite ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // DETAILS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE + PRICE
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.property.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${widget.property.price.toStringAsFixed(0)}ETB',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // LOCATION
                  Text(
                    widget.property.location,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // STATUS (Available / Sold / Rented)
                  _buildPropertyStatus(widget.property.status),

                  const SizedBox(height: 12),

                  // SPECS
                  Row(
                    children: [
                      _specIcon(
                        Icons.king_bed_outlined,
                        '${widget.property.beds ?? 0} Beds',
                      ),
                      const SizedBox(width: 16),
                      _specIcon(
                        Icons.bathtub_outlined,
                        '${widget.property.baths ?? 0} Baths',
                      ),
                      const SizedBox(width: 16),
                      _specIcon(
                        Icons.square_foot_rounded,
                        '${widget.property.sqft ?? 0} sqft',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SYNC HANDLER 

  Future<void> _handleSyncTap() async {
    if (widget.property.syncStatus == 'synced') return;

    setState(() => _isSyncing = true);

    try {
      // mark as queued
      await DatabaseHelper.instance.updatePropertySyncStatus(
        widget.property.id!,
        'queued',
      );

      // simulate API sync
      await Future.delayed(const Duration(seconds: 2));

      // mark as synced
      await DatabaseHelper.instance.updatePropertySyncStatus(
        widget.property.id!,
        'synced',
      );
    } catch (_) {
      await DatabaseHelper.instance.updatePropertySyncStatus(
        widget.property.id!,
        'failed',
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  // UI HELPERS 

  Widget _buildSyncBadge(String? status) {
    Color color;
    String label;

    switch (status?.toLowerCase()) {
      case 'synced':
        color = Colors.green;
        label = 'SYNCED';
        break;
      case 'failed':
        color = Colors.red;
        label = 'FAILED';
        break;
      case 'queued':
        color = Colors.orange;
        label = 'QUEUED';
        break;
      case 'syncing':
        color = Colors.blue;
        label = 'SYNCING';
        break;
      default:
        color = Colors.blueGrey;
        label = 'CACHED';
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status == 'syncing') ...[
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyStatus(String? status) {
    final normalized = status?.toLowerCase() ?? 'available';

    Color color;
    switch (normalized) {
      case 'sold':
        color = Colors.red;
        break;
      case 'rented':
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }

    return Text(
      status?.toUpperCase() ?? 'AVAILABLE',
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _specIcon(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
