import 'package:databaseapp/Services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../Services/hive_service.dart';

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
    String dbName = await HiveService.getValue("databsename") ?? "Default Name";
    String dbLocation = await DatabaseService.instance.getDatabaseLocation(dbName);
    final db = await DatabaseService.instance.database;

    final tableList = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';");

    setState(() {
      _dbPath = dbLocation;
      _tables = tableList.map((row) => row['name'].toString()).toList();
    });
  }

  Future<void> _exportDatabase() async {
    if (_dbPath.isNotEmpty) {
      ShareResult sr = await SharePlus.instance.share(ShareParams(
        files: [
          XFile(_dbPath)
        ],
      ));
      ScaffoldMessenger.of(context).showSnackBar(getResultSnackBar(sr));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database path not found')),
      );
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
        itemCount: _tables.length + 1,
        separatorBuilder: (_, __) => const Divider(color: Colors.white24),
        itemBuilder: (context, index) {
          if (index < _tables.length) {
            return ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.white70),
              title: Text(
                _tables[index],
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else {
            // Export Button
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Export Database'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _exportDatabase,
              ),
            );
          }
        },
      ),
    );
  }
  SnackBar getResultSnackBar(ShareResult result) {
    return SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Share result: ${result.status}"),
          if (result.status == ShareResultStatus.success)
            Text("Shared to: ${result.raw}")
        ],
      ),
    );
  }
}
