import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'hive_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  String _databaseName = '';
  static const _databaseVersion = 1;
  Database? _database;

  Future<void> initialize() async {
    _databaseName = await _getDatabaseNameFromHive() ?? "user_database.db";
  }

  Future<String?> _getDatabaseNameFromHive() async {
    return await HiveService.getValue("databsename");
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }

  Future<List<String>> executeQuery(String sql) async {
    final db = await database;
    final results = <String>[];

    final statements = sql
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    for (var statement in statements) {
      final lowered = statement.toLowerCase();

      try {
        if (lowered == 'tables') {
          final result = await db.rawQuery(
              "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';"
          );
          results.add(result.isNotEmpty
              ? result.map((row) => row['name'].toString()).join('\n')
              : 'No tables found.');
        } else if (lowered.startsWith('select') || lowered.startsWith('pragma')) {
          final rows = await db.rawQuery(statement);
          results.add(rows.isNotEmpty
              ? rows.map((row) => _formatRow(row)).join('\n')
              : '(No rows returned)');
        } else if (lowered.startsWith('insert')) {
          final count = await db.rawInsert(statement);
          results.add('Insert executed successfully. Affected rows: ${count > 0 ? 1 : 0}');
        } else if (lowered.startsWith('update')) {
          final count = await db.rawUpdate(statement);
          results.add('Update executed successfully. Affected rows: $count');
        } else if (lowered.startsWith('delete')) {
          final count = await db.rawDelete(statement);
          results.add('Delete executed successfully. Affected rows: $count');
        } else {
          await db.execute(statement);
          results.add('Query executed successfully: $statement');
        }
      } catch (e) {
        results.add('Error executing "$statement": $e');
      }
    }

    return results;
  }

  String _formatRow(Map<String, dynamic> row) {
    return row.entries.map((e) => '${e.key}: ${e.value}').join(' | ');
  }

  Future<void> changeDatabaseName(String name) async {
    await close();
    _databaseName = name;
    _database = null;
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> clearAllTables() async {
    final db = await database;
    final names = await executeQuery("tables");

    final allNames = names
        .expand((name) => name.split('\n'))
        .map((name) => name.trim())
        .where((name) =>
    name.isNotEmpty &&
        name != 'android_metadata' &&
        name != 'sqlite_sequence')
        .toList();

    for (final table in allNames) {
      await db.rawDelete('DELETE FROM "$table"');
    }
  }

  Future<String> getDatabaseLocation(String dbName) async {
    final directory = await getDatabasesPath();
    return join(directory,dbName);
  }

  Future<void> deleteTable(String tableName) async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS "$tableName"');
  }
}
