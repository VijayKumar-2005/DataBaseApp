import 'package:databaseapp/Services/database_services.dart';
import 'package:databaseapp/Services/hive_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _databaseName = '';
  String _databaselocation = '';
  final TextEditingController _databaseNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDatabaseName();
    _loadThemePreference();
    _loadDatabaseLocation();
  }

  Future<void> _loadDatabaseName() async {
    String dbName = await HiveService.getValue("databsename") ?? "Default Name";
    setState(() {
      _databaseName = dbName;
      _databaseNameController.text = _databaseName;
    });
  }

  Future<void> _loadThemePreference() async {
    final _ = await SharedPreferences.getInstance();
  }

  Future<void> _loadDatabaseLocation() async {
    String dbName = _databaseName;
    String dbLocation = await DatabaseService.instance.getDatabaseLocation(dbName);
    setState(() {
      _databaselocation = dbLocation;
    });
  }

  Future<void> _saveDatabaseName() async {
    String newDatabaseName = _databaseNameController.text;
    await HiveService.putValue("databsename", newDatabaseName);
    DatabaseService.instance.changeDatabaseName(newDatabaseName);
    await DatabaseService.instance.database;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Database name updated!')),
    );
    await _loadDatabaseLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Settings'),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('Database Path', style: TextStyle(color: Colors.white)),
            subtitle: Text(_databaselocation,
                style: const TextStyle(color: Colors.white54, fontSize: 12)),
            leading: const Icon(Icons.storage, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: TextField(
              controller: _databaseNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Database Name',
                labelStyle: const TextStyle(color: Colors.blueAccent),
                border: OutlineInputBorder(),
              ),
              onChanged: (newValue) {
                setState(() {
                  _databaseName = newValue;
                });
              },
            ),
            leading: const Icon(Icons.dataset_rounded, color: Colors.white60),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white60),
              onPressed: _saveDatabaseName,
            ),
          ),
          const Divider(color: Colors.white30),
          ListTile(
            title: const Text('About', style: TextStyle(color: Colors.white)),
            subtitle: const Text('DatabaseApp by Vijaykumar Pandian\nA sleek local SQL tester and a \npassionate App/Game Developer.',
                style: TextStyle(color: Colors.white60)),
            leading: const Icon(Icons.info_outline, color: Colors.white70),
          ),
          const ListTile(
            title: Text('Version', style: TextStyle(color: Colors.white)),
            subtitle: Text('1.0.0', style: TextStyle(color: Colors.white54)),
            leading: Icon(Icons.verified, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
