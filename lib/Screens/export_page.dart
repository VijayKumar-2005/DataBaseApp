import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:databaseapp/Screens/table_viewer_page.dart';
import 'package:databaseapp/Services/hive_service.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseInfoPage extends StatefulWidget {
  const DatabaseInfoPage({super.key});

  @override
  State<DatabaseInfoPage> createState() => _DatabaseInfoPageState();
}

class _DatabaseInfoPageState extends State<DatabaseInfoPage> {
  List<String> _tables = [];
  String _dbPath = '';

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    String dbName = await HiveService.getValue("databsename") ?? "sample1.db";
    if (!dbName.endsWith('.db')) dbName = '$dbName.db';
    final directory = await getDatabasesPath();
    String dbLocation = join(directory, dbName);

    final db = await openDatabase(
      dbLocation,
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE IF NOT EXISTS example(id INTEGER PRIMARY KEY)");
      },
      version: 1,
    );

    final tableList = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );

    setState(() {
      _dbPath = dbLocation;
      _tables = tableList.map((row) => row['name'].toString()).toList();
    });
    await db.close();
  }

  Future<void> _exportDatabase(BuildContext context) async {
    final file = File(_dbPath);
    if (await file.exists()) {
      try {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(_dbPath)],
            text: "Sample Database"
          )
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error sharing database: $e")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Database file not found at $_dbPath")));
    }
  }

  Future<void> _copyDatabaseToExternalStorage(BuildContext context) async {
    final file = File(_dbPath);
    if (await file.exists()) {
      final extDir = await getExternalStorageDirectory();
      final newPath = join(extDir!.path, 'sample1.db');
      await file.copy(newPath);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Database copied to: $newPath")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Database file not found to copy")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Database Info'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _tables.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tables.length + 2,
        separatorBuilder: (_, __) => const Divider(color: Colors.white24),
        itemBuilder: (context, index) {
          if (index < _tables.length) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TableViewerPage(tableName: _tables[index]),
                  ),
                );
              },
              child: ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.white70),
                title: Text(_tables[index], style: const TextStyle(color: Colors.white)),
              ),
            );
          } else if (index == _tables.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Export Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: ()=>_exportDatabase(context),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copy DB to External Storage'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _copyDatabaseToExternalStorage(context),
              ),
            );
          }
        },
      ),
    );
  }
}