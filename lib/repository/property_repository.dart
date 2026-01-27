import '../db/database_helper.dart';
import '../models/property.dart';

class PropertyRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Property>> fetchProperties() => dbHelper.getAllProperties();

  Future<void> saveProperty(Property property) =>
      dbHelper.insertProperty(property);
}