import '../../db/database_helper.dart';
import '../../models/inquiry.dart';
import '../../models/property.dart';
import '../../models/user.dart';

class MockData {
  static Future<void> seedPropertiesAndInquiries() async {
    final db = DatabaseHelper.instance;

    // 1️⃣ SEED USER (Jane Doe)
    final user = await _seedUser();

    // 2️⃣ SEED PROPERTIES
    final dbInstance = await db.database;
    await dbInstance.delete('properties');

    final properties = [
      Property(
        title: 'Luxury Beachfront Villa',
        description: 'Stunning villa with direct beach access and a private pool.',
        location: 'Miami, FL',
        price: 1800000,
        beds: 5,
        baths: 4.5,
        sqft: 4200,
        imageUrls: ['https://images.unsplash.com/photo-1613490493576-7fde63acd811'],
        isFavorite: true,
        // ✅ Added missing required parameters
        status: 'published',
        syncStatus: 'synced',
        lastUpdated: DateTime.now(),

      ),
      Property(
        title: 'Cozy Lakeside Cottage',
        description: 'A peaceful retreat by the lake, perfect for weekends.',
        location: 'Lake Tahoe, CA',
        price: 450000,
        beds: 3,
        baths: 2.0,
        sqft: 1500,
        imageUrls: ['https://images.unsplash.com/photo-1500382017468-9049fed747ef'],
        isFavorite: true,
        // ✅ Added missing required parameters
        status: 'published',
        syncStatus: 'failed',
        lastUpdated: DateTime.now(),

      ),
      Property(
        title: 'Modern Family Home',
        description: 'Spacious suburban home with a two-car garage.',
        location: 'Cityville, TX',
        price: 520000,
        beds: 4,
        baths: 3.0,
        sqft: 2800,
        imageUrls: ['https://images.unsplash.com/photo-1568605114967-8130f3a36994'],
        isFavorite: false,
        // ✅ Added missing required parameters
        status: 'published',
        syncStatus: 'cached',
        lastUpdated: DateTime.now(),

      ),
    ];

    for (var p in properties) {
      await db.insertProperty(p);
    }

    // 3️⃣ SEED INQUIRIES
    final allProps = await db.getAllProperties();
    await dbInstance.delete('inquiries');

    final inquiries = [
      Inquiry(
        propertyId: allProps[0].id!,
        userId: user.id!,
        message: 'I\'m interested in this villa!',
        status: 'synced',
        timestamp: DateTime.now(),
      ),
      Inquiry(
        propertyId: allProps[1].id!,
        userId: user.id!,
        message: 'Is the cottage available in December?',
        status: 'queued',
        timestamp: DateTime.now(),
      ),
    ];

    for (var i in inquiries) {
      await db.insertInquiry(i);
    }

    print('🚀 Database seeded with Mock Data successfully');
  }

  static Future<UserModel> _seedUser() async {
    final user = UserModel(
      name: 'Jane Doe',
      email: 'jane.doe@example.com',
      avatar: 'https://i.pravatar.cc/150?u=jane',
      isDarkMode: false,
      isOfflineModeOnly: true,
      createdAt: DateTime.now(),
      // Ensure UserModel doesn't have missing required fields too!
      lastGlobalSync: DateTime.now(),
    );

    await DatabaseHelper.instance.saveUser(user);
    return (await DatabaseHelper.instance.getUser())!;
  }
}