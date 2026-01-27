import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/property.dart';
import '../models/inquiry.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  // ================= DATABASE =================

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('properties.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2, // 🔥 bumped version
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // ================= CREATE =================

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE properties (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        location TEXT,
        price REAL,
        imageUrls TEXT,
        status TEXT,
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
        isDarkMode INTEGER,
        createdAt TEXT
      )
    ''');
  }

  // ================= MIGRATION =================

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          email TEXT,
          avatar TEXT,
          isDarkMode INTEGER,
          createdAt TEXT
        )
      ''');

      await db.execute('''
        ALTER TABLE inquiries ADD COLUMN userId INTEGER
      ''');
    }
  }

  // ================= PROPERTIES =================

  Future<void> insertProperty(Property property) async {
    final db = await database;
    await db.insert(
      'properties',
      property.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Property>> getAllProperties() async {
    final db = await database;
    final maps = await db.query('properties');
    return maps.map((e) => Property.fromMap(e)).toList();
  }

  // ================= INQUIRIES =================

  Future<void> insertInquiry(Inquiry inquiry) async {
    final db = await database;
    await db.insert(
      'inquiries',
      inquiry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  // ================= USERS =================

  Future<void> saveUser(UserModel user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  Future<void> updateUserTheme(int userId, bool isDarkMode) async {
    final db = await database;
    await db.update(
      'users',
      {'isDarkMode': isDarkMode ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('users');
  }
}
