import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/property.dart';
import '../models/inquiry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('properties.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Properties table
    await db.execute('''
      CREATE TABLE properties (
        id INTEGER PRIMARY KEY,
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

    // Inquiries table
    await db.execute('''
      CREATE TABLE inquiries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        propertyId INTEGER,
        message TEXT,
        status TEXT,
        timestamp TEXT
      )
    ''');
  }

  // Insert property
  Future<void> insertProperty(Property property) async {
    final db = await database;
    await db.insert('properties', property.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all properties
  Future<List<Property>> getAllProperties() async {
    final db = await database;
    final maps = await db.query('properties');
    return maps.map((map) => Property.fromMap(map)).toList();
  }

  // Insert inquiry
  Future<void> insertInquiry(Inquiry inquiry) async {
    final db = await database;
    await db.insert('inquiries', inquiry.toMap());
  }

  // Get queued inquiries
  Future<List<Inquiry>> getQueuedInquiries() async {
    final db = await database;
    final maps =
        await db.query('inquiries', where: 'status = ?', whereArgs: ['queued']);
    return maps.map((map) => Inquiry.fromMap(map)).toList();
  }

  // Update inquiry status
  Future<void> updateInquiryStatus(int id, String status) async {
    final db = await database;
    await db.update('inquiries', {'status': status},
        where: 'id = ?', whereArgs: [id]);
  }
}