import '../../core/utils/auth_util.dart';
import '../../db/database_helper.dart';
import '../../models/inquiry.dart';
import '../../models/property.dart';
import '../../models/user.dart';
import 'dart:math';

class MockData {
  // Default admin: admin@example.com
  // Password: generated at seed time (printed to console) for development only.
  static const adminEmail = 'admin@example.com';

  //Default user: user@example.com
  //Password: generated at seed time (printed to console) for development only.
  static const userEmail = 'user@example.com';

  static Future<void> seedPropertiesAndInquiries() async {
    final db = DatabaseHelper.instance;

    // 1️ SEED ADMIN USER
    final user = await _seedAdminUser();
    await _seedRegularUser();

    // 2️ SEED PROPERTIES
    final dbInstance = await db.database;
    await dbInstance.delete('properties');

    // Use local assets (material provided: assets/images)
    final properties = [
      Property(
        title: 'Luxury Beachfront Villa',
        description:
            'Stunning villa with direct beach access and a private pool.',
        location: 'Miami, FL',
        price: 1800000,
        beds: 5,
        baths: 4.5,
        sqft: 4200,
        imageUrls: ['assets/images/villa1.png', 'assets/images/villa2.png'],
        isFavorite: true,
        status: 'published',
        syncStatus: 'synced',
        lastUpdated: DateTime.now(),
      ),
      Property(
        title: 'Cozy Lakeside Cottage',
        description: 'A peaceful retreat by the lake, perfect for weekends.',
        location: 'Bahir Dar',
        price: 450000,
        beds: 3,
        baths: 2.0,
        sqft: 1500,
        imageUrls: [
          'assets/images/cozy_house1.png',
          'assets/images/cozy_house2.png',
        ],
        isFavorite: true,
        status: 'published',
        syncStatus: 'failed',
        lastUpdated: DateTime.now(),
      ),
      Property(
        title: 'Modern Family Home',
        description: 'Spacious suburban home with a two-car garage.',
        location: 'Addis Ababa',
        price: 520000,
        beds: 4,
        baths: 3.0,
        sqft: 2800,
        imageUrls: ['assets/images/villa3.png'],
        isFavorite: false,
        status: 'published',
        syncStatus: 'cached',
        lastUpdated: DateTime.now(),
      ),
    ];

    for (var p in properties) {
      await db.insertProperty(p);
    }

    // 3️ SEED INQUIRIES
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

    print('Database seeded with Mock Data successfully');
  }

  static Future<UserModel> _seedAdminUser() async {
    final generatedPassword = _generatePassword();
    print('Mock admin password: $generatedPassword');

    final user = UserModel(
      name: 'Admin',
      email: adminEmail,
      passwordHash: hashPassword(generatedPassword),
      role: UserRole.admin,
      avatar: 'assets/images/yod.png',
      isDarkMode: false,
      isOfflineModeOnly: false,
      lastGlobalSync: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await DatabaseHelper.instance.saveUser(user);
    final saved = await DatabaseHelper.instance.getUserByEmail(adminEmail);
    return saved!;
  }

  static Future<void> _seedRegularUser() async {
    final existing = await DatabaseHelper.instance.getUserByEmail(userEmail);
    if (existing != null) return;

    final generatedPassword = _generatePassword();
    print('Mock user password: $generatedPassword');

    final user = UserModel(
      name: 'Demo User',
      email: userEmail,
      passwordHash: hashPassword(generatedPassword),
      role: UserRole.user,
      avatar: 'assets/images/yod.png',
      isDarkMode: false,
      isOfflineModeOnly: false,
      lastGlobalSync: null,
      createdAt: DateTime.now(),
    );
    await DatabaseHelper.instance.saveUser(user);
  }

  static String _generatePassword([int length = 12]) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()-_=+';
    final rnd = Random.secure();
    return List.generate(
      length,
      (_) => chars[rnd.nextInt(chars.length)],
    ).join();
  }
}
