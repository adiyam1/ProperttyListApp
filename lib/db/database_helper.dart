import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/property.dart';
import '../models/inquiry.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('property_pal.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 5, // ✅ bumped to trigger status migration
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // ================= CREATE DATABASE =================

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE properties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        location TEXT,
        price REAL,
        imageUrls TEXT,
        status TEXT,              -- ✅ FIX
        beds INTEGER,
        baths REAL,
        sqft INTEGER,
        isFavorite INTEGER DEFAULT 0,
        syncStatus TEXT,
        lastUpdated TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE inquiries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        propertyId INTEGER,
        userId INTEGER,
        message TEXT,
        status TEXT,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        avatar TEXT,
        isDarkMode INTEGER DEFAULT 0,
        isOfflineModeOnly INTEGER DEFAULT 0,
        lastGlobalSync TEXT,
        createdAt TEXT
      )
    ''');
  }

  // ================= MIGRATIONS =================

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // v3: add property dimensions
    if (oldVersion < 3) {
      final tableInfo = await db.rawQuery('PRAGMA table_info(properties)');
      final columns = tableInfo.map((e) => e['name']).toList();

      if (!columns.contains('beds')) {
        await db.execute('ALTER TABLE properties ADD COLUMN beds INTEGER');
      }
      if (!columns.contains('baths')) {
        await db.execute('ALTER TABLE properties ADD COLUMN baths REAL');
      }
      if (!columns.contains('sqft')) {
        await db.execute('ALTER TABLE properties ADD COLUMN sqft INTEGER');
      }
    }

    // v4: add createdAt to users
    if (oldVersion < 4) {
      final tableInfo = await db.rawQuery('PRAGMA table_info(users)');
      final columns = tableInfo.map((e) => e['name']).toList();

      if (!columns.contains('createdAt')) {
        await db.execute('ALTER TABLE users ADD COLUMN createdAt TEXT');
      }
    }

    // v5: add status to properties ✅ FIX FOR YOUR ERROR
    if (oldVersion < 5) {
      final tableInfo = await db.rawQuery('PRAGMA table_info(properties)');
      final columns = tableInfo.map((e) => e['name']).toList();

      if (!columns.contains('status')) {
        await db.execute('ALTER TABLE properties ADD COLUMN status TEXT');
      }
    }
  }

  // ================= USER OPERATIONS =================

  Future<UserModel?> getUser() async {
    final db = await database;
    final maps = await db.query('users', limit: 1);
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUserTheme(int id, bool isDarkMode) async {
    final db = await database;
    await db.update(
      'users',
      {'isDarkMode': isDarkMode ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= PROPERTY OPERATIONS =================

  Future<List<Property>> getAllProperties() async {
    final db = await database;
    final maps = await db.query('properties', orderBy: 'id DESC');
    return maps.map((e) => Property.fromMap(e)).toList();
  }

  Future<void> insertProperty(Property property) async {
    final db = await database;
    await db.insert(
      'properties',
      property.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Property>> getFavorites() async {
    final db = await database;
    final maps =
    await db.query('properties', where: 'isFavorite = ?', whereArgs: [1]);
    return maps.map((e) => Property.fromMap(e)).toList();
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'properties',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= INQUIRY & SYNC =================

  Future<void> updatePropertySyncStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'properties',
      {
        'syncStatus': status,
        'lastUpdated': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> insertInquiry(Inquiry inquiry) async {
    final db = await database;
    await db.insert('inquiries', inquiry.toMap());
  }

  Future<List<Inquiry>> getQueuedInquiries() async {
    final db = await database;
    final maps = await db.query(
      'inquiries',
      where: 'status = ?',
      whereArgs: ['queued'],
    );
    return maps.map((e) => Inquiry.fromMap(e)).toList();
  }

  Future<void> updateInquiryStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'inquiries',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= CLEANUP =================

  Future<void> clearOfflineCache() async {
    final db = await database;
    await db.delete(
      'properties',
      where: 'isFavorite = ?',
      whereArgs: [0],
    );
  }
}
