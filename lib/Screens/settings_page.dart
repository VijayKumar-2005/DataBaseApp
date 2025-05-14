import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/database_services.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final _ = await SharedPreferences.getInstance();
    setState(() {
    });
  }

  void _confirmClearTables() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Confirm Clear', style: TextStyle(color: Colors.white)),
        content: const Text('This will delete all data from all tables. Are you sure?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseService.instance.clearAllTables();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All tables cleared.')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
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
            subtitle: const Text('/data/user/0/com.example.app/databases/mydb.db',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            leading: const Icon(Icons.storage, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          ListTile(
            title: const Text('Clear All Tables', style: TextStyle(color: Colors.redAccent)),
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            onTap: _confirmClearTables,
          ),
          const Divider(color: Colors.white30),
          ListTile(
            title: const Text('About', style: TextStyle(color: Colors.white)),
            subtitle: const Text('DatabaseApp by YourName\nA sleek local SQL tester.',
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
